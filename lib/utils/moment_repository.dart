import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MomentRepository {
  static final MomentRepository _instance = MomentRepository._internal();

  factory MomentRepository() => _instance;

  MomentRepository._internal();

  static const String _entryBoxName = 'notekar_entries_v1';
  static const String _trashBoxName = 'notekar_trash_v1';
  static const String _nextIdKey = 'notekar.nextId';
  static const String _legacyEntriesKey = 'notekar.entries';

  late Box<dynamic> _box;
  late Box<dynamic> _trashBox;
  late SharedPreferences _prefs;
  final _logger = AppLogger();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> ensureInitialized({SharedPreferences? preloadedPrefs}) async {
    if (_isInitialized) return;
    await initialize(preloadedPrefs: preloadedPrefs);
  }

  // In-memory cache to boost read performance
  List<Moment>? _cachedMoments;
  List<Moment>? _cachedTrashMoments;
  Map<int, Moment>? _momentIdIndex;

  Future<List<int>?> _getOrGenerateEncryptionKey() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
    );
    try {
      final base64Key = await secureStorage.read(key: 'hive_secure_key');
      if (base64Key != null) {
        return base64.decode(base64Key);
      }

      // Check if we need to migrate plain text boxes
      final hasOldData =
          await Hive.boxExists(_entryBoxName) ||
          await Hive.boxExists(_trashBoxName);
      Map<dynamic, dynamic>? oldEntries;
      Map<dynamic, dynamic>? oldTrash;

      if (hasOldData) {
        try {
          final box = await Hive.openBox<dynamic>(_entryBoxName);
          final trashBox = await Hive.openBox<dynamic>(_trashBoxName);
          oldEntries = Map<dynamic, dynamic>.from(box.toMap());
          oldTrash = Map<dynamic, dynamic>.from(trashBox.toMap());
          await box.close();
          await trashBox.close();
        } catch (e, stack) {
          _logger.error(
            'Failed to read old plain text data for migration',
            e,
            stack,
          );
        }
      }

      final newKey = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'hive_secure_key',
        value: base64.encode(newKey),
      );

      if (oldEntries != null || oldTrash != null) {
        // Re-write to encrypted boxes after key generation
        final cipher = HiveAesCipher(newKey);
        final box = await Hive.openBox<dynamic>(
          _entryBoxName,
          encryptionCipher: cipher,
        );
        final trashBox = await Hive.openBox<dynamic>(
          _trashBoxName,
          encryptionCipher: cipher,
        );
        if (oldEntries != null) await box.putAll(oldEntries);
        if (oldTrash != null) await trashBox.putAll(oldTrash);
        await box.close();
        await trashBox.close();
      }

      return newKey;
    } catch (e, stack) {
      _logger.error(
        'Secure storage failure, falling back to unencrypted or cached key',
        e,
        stack,
      );
      final fallbackBase64 = _prefs.getString('hive_fallback_key');
      if (fallbackBase64 != null) {
        return base64.decode(fallbackBase64);
      }
      final fallbackKey = Hive.generateSecureKey();
      await _prefs.setString('hive_fallback_key', base64.encode(fallbackKey));
      return fallbackKey;
    }
  }

  static const String _autoSnapshotKey = 'notekar.auto_rolling_snapshot';
  static const String _lastSnapshotTimeKey = 'notekar.last_auto_snapshot_ms';
  static const String keyCorruptedFlag = 'notekar.database_corrupted_flag';
  static const String keyRecoveredFromSnapshot =
      'notekar.database_recovered_from_snapshot';

  Future<void> _emergencyBackupCorruptedBox(String boxName) async {
    try {
      String? dataDirPath;
      try {
        const channel = MethodChannel('notekar/files');
        dataDirPath = await channel.invokeMethod<String>('appDataDir');
      } catch (_) {}
      dataDirPath ??= Directory.systemTemp.path;

      final dir = Directory(dataDirPath);
      if (!dir.existsSync()) return;

      final backupDir = Directory(
        '${dir.path}${Platform.pathSeparator}corrupted_backups',
      );
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final files = dir.listSync();
      for (final f in files) {
        if (f is File && f.path.contains(boxName)) {
          final fileName = f.uri.pathSegments.last;
          final dest = File(
            '${backupDir.path}${Platform.pathSeparator}${timestamp}_$fileName',
          );
          f.copySync(dest.path);
          _logger.warn('Emergency copy of corrupted box created: ${dest.path}');
        }
      }
    } catch (e, stack) {
      _logger.error(
        'Failed to create emergency backup of corrupted box $boxName',
        e,
        stack,
      );
    }
  }

  Future<void> _attemptSnapshotRestore(Box<dynamic> box) async {
    try {
      final snapshotRaw = _prefs.getString(_autoSnapshotKey);
      if (snapshotRaw == null || snapshotRaw.isEmpty) return;
      final decoded = jsonDecode(snapshotRaw);
      if (decoded is List && decoded.isNotEmpty) {
        final Map<int, dynamic> entries = {};
        int maxId = 0;
        for (final item in decoded) {
          if (item is Map) {
            final m = Moment.fromJson(Map<String, dynamic>.from(item));
            entries[m.id] = m.toJson();
            if (m.id > maxId) maxId = m.id;
          }
        }
        if (entries.isNotEmpty) {
          await box.putAll(entries);
          await _prefs.setInt(_nextIdKey, maxId + 1);
          await _prefs.setBool(keyRecoveredFromSnapshot, true);
          _logger.info(
            'Successfully restored ${entries.length} moments from rolling snapshot after corruption',
          );
        }
      }
    } catch (e, stack) {
      _logger.error(
        'Failed restoring from snapshot after corruption',
        e,
        stack,
      );
    }
  }

  Future<void> triggerAutoSnapshotIfNeeded({bool force = false}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastMs = _prefs.getInt(_lastSnapshotTimeKey) ?? 0;
      if (!force && now - lastMs < const Duration(hours: 6).inMilliseconds) {
        return;
      }

      final moments = getAllMoments();
      if (moments.isEmpty) return;

      final jsonList = moments.map((m) => m.toJson()).toList();
      await _prefs.setString(_autoSnapshotKey, jsonEncode(jsonList));
      await _prefs.setInt(_lastSnapshotTimeKey, now);
      _logger.info('Auto-snapshot updated with ${moments.length} moments');
    } catch (e, stack) {
      _logger.error('Failed generating auto-snapshot', e, stack);
    }
  }

  Future<void> initialize({SharedPreferences? preloadedPrefs}) async {
    if (_isInitialized) return;
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();

    final encryptionKey = await _getOrGenerateEncryptionKey();
    final cipher = encryptionKey != null ? HiveAesCipher(encryptionKey) : null;

    // Database Corruption Recovery Wrapper with Emergency Pre-wipe Backups
    try {
      _box = await Hive.openBox<dynamic>(
        _entryBoxName,
        encryptionCipher: cipher,
      );
    } catch (e, stack) {
      _logger.error(
        'Failed to open entry box due to corruption. Creating emergency backup & recreating...',
        e,
        stack,
      );
      await _emergencyBackupCorruptedBox(_entryBoxName);
      await _prefs.setBool(keyCorruptedFlag, true);
      await _prefs.setString(
        'notekar.last_corrupted_time',
        DateTime.now().toIso8601String(),
      );
      try {
        await Hive.deleteBoxFromDisk(_entryBoxName);
        _box = await Hive.openBox<dynamic>(
          _entryBoxName,
          encryptionCipher: cipher,
        );
        // Attempt automatic restore from rolling snapshot if available
        await _attemptSnapshotRestore(_box);
      } catch (innerE, innerStack) {
        _logger.error(
          'Failed to recreate corrupted entry box.',
          innerE,
          innerStack,
        );
        rethrow;
      }
    }

    try {
      _trashBox = await Hive.openBox<dynamic>(
        _trashBoxName,
        encryptionCipher: cipher,
      );
    } catch (e, stack) {
      _logger.error(
        'Failed to open trash box due to corruption. Creating emergency backup & recreating...',
        e,
        stack,
      );
      await _emergencyBackupCorruptedBox(_trashBoxName);
      try {
        await Hive.deleteBoxFromDisk(_trashBoxName);
        _trashBox = await Hive.openBox<dynamic>(
          _trashBoxName,
          encryptionCipher: cipher,
        );
      } catch (innerE, innerStack) {
        _logger.error(
          'Failed to recreate corrupted trash box.',
          innerE,
          innerStack,
        );
        rethrow;
      }
    }

    _isInitialized = true;

    unawaited(
      Future(() async {
        await _autoPurgeOldTrash();
        if (_box.length > 300) {
          unawaited(_box.compact());
        }
        if (_trashBox.length > 300) {
          unawaited(_trashBox.compact());
        }
      }),
    );

    // Pre-populate the cache in the background for zero-delay read paths
    unawaited(
      Future(() {
        getAllMoments();
        getTrashMoments();
        triggerAutoSnapshotIfNeeded();
      }),
    );

    _logger.info(
      'MomentRepository initialized with ${_box.length} entries, ${_trashBox.length} trash entries',
    );
  }

  Future<void> _autoPurgeOldTrash() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final thirtyDaysAgo = now - const Duration(days: 30).inMilliseconds;
      final keysToRemove = <dynamic>[];

      for (final key in _trashBox.keys) {
        final raw = _trashBox.get(key);
        if (raw is Map) {
          final timestamp = raw['timestamp'];
          if (timestamp is num && timestamp < thirtyDaysAgo) {
            keysToRemove.add(key);
          }
        }
      }

      if (keysToRemove.isNotEmpty) {
        await _trashBox.deleteAll(keysToRemove);
        _cachedTrashMoments = null; // Invalidate cache
        _logger.info(
          'Auto-purged ${keysToRemove.length} trash entries older than 30 days',
        );
      }
    } catch (e, stack) {
      _logger.error('Failed auto-purging old trash entries', e, stack);
    }
  }

  List<Moment> getAllMoments() {
    if (_cachedMoments != null) {
      return _cachedMoments!;
    }
    if (!_isInitialized) {
      return [];
    }
    try {
      final moments = _box.values
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedMoments = moments;
      _momentIdIndex = {for (final m in moments) m.id: m};
      SearchIndexService.instance.buildIndex(moments);
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load moments from Hive', e, stack);
      return [];
    }
  }

  /// O(1) direct lookup of a moment by its unique ID via the secondary index.
  Moment? getMomentById(int id) {
    if (_momentIdIndex != null) {
      return _momentIdIndex![id];
    }
    getAllMoments();
    return _momentIdIndex?[id];
  }

  /// High-performance O(log N) binary range slicing for timestamp queries.
  ///
  /// Extracts all moments between [startMs] and [endMs] inclusive,
  /// leveraging the descending sorted timestamp array without full linear table scans.
  List<Moment> getMomentsBetween(int startMs, int endMs) {
    final moments = getAllMoments();
    if (moments.isEmpty || startMs > endMs) return const [];

    // Binary search for the first element with timestamp <= endMs
    int low = 0;
    int high = moments.length - 1;
    int startIdx = moments.length;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (moments[mid].timestamp <= endMs) {
        startIdx = mid;
        high = mid - 1; // look for earlier (higher timestamp) matching index
      } else {
        low = mid + 1;
      }
    }

    if (startIdx >= moments.length || moments[startIdx].timestamp < startMs) {
      return const [];
    }

    // Binary search for the last element with timestamp >= startMs
    low = startIdx;
    high = moments.length - 1;
    int endIdx = startIdx;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (moments[mid].timestamp >= startMs) {
        endIdx = mid;
        low = mid + 1; // look for later (lower timestamp) matching index
      } else {
        high = mid - 1;
      }
    }

    return moments.sublist(startIdx, endIdx + 1);
  }

  /// Guaranteed OS maintenance routine: updates rolling snapshot, purges old trash,
  /// and compacts storage boxes.
  Future<void> performDailyMaintenance() async {
    try {
      _logger.info('Performing daily background maintenance...');
      await triggerAutoSnapshotIfNeeded(force: true);
      await _autoPurgeOldTrash();
      if (_box.length > 200) {
        await _box.compact();
      }
      if (_trashBox.length > 200) {
        await _trashBox.compact();
      }
      _logger.info('Daily background maintenance completed successfully');
    } catch (e, stack) {
      _logger.error('Failed executing daily background maintenance', e, stack);
    }
  }

  List<Moment> getTrashMoments() {
    if (_cachedTrashMoments != null) {
      return _cachedTrashMoments!;
    }
    if (!_isInitialized) {
      return [];
    }
    try {
      final moments = <Moment>[];
      for (final value in _trashBox.values) {
        if (value is Map) {
          try {
            moments.add(Moment.fromJson(Map<String, dynamic>.from(value)));
          } catch (_) {
            _logger.error('Failed to parse trash moment from Map');
          }
        } else if (value is Moment) {
          moments.add(value);
        }
      }
      moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedTrashMoments = moments;
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load trash moments from Hive', e, stack);
      return [];
    }
  }

  Future<void> saveMoment(Moment moment) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      await _box.put(moment.id, moment.toJson());
      final currentNextId = _prefs.getInt(_nextIdKey) ?? 0;
      if (moment.id >= currentNextId) {
        await _prefs.setInt(_nextIdKey, moment.id + 1);
      }
      // Update local cache and secondary indices
      if (_cachedMoments != null) {
        _cachedMoments!.removeWhere((m) => m.id == moment.id);
        _cachedMoments!.add(moment);
        _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      _momentIdIndex?[moment.id] = moment;
      SearchIndexService.instance.indexMoment(moment);
    } catch (e, stack) {
      _logger.error('Failed to save moment ${moment.id}', e, stack);
      rethrow;
    }
  }

  Future<void> deleteMoment(int id) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      final raw = _box.get(id);
      if (raw != null) {
        Map<String, dynamic>? jsonMap;
        if (raw is Map) {
          jsonMap = Map<String, dynamic>.from(raw);
        } else if (raw is Moment) {
          jsonMap = raw.toJson();
        }
        if (jsonMap != null) {
          await _trashBox.put(id, jsonMap);
          // Update trash cache
          if (_cachedTrashMoments != null) {
            final moment = Moment.fromJson(jsonMap);
            _cachedTrashMoments!.removeWhere((m) => m.id == id);
            _cachedTrashMoments!.add(moment);
            _cachedTrashMoments!.sort(
              (a, b) => b.timestamp.compareTo(a.timestamp),
            );
          }
        }
      }
      await _box.delete(id);
      // Update entries cache and secondary indices
      if (_cachedMoments != null) {
        _cachedMoments!.removeWhere((m) => m.id == id);
      }
      _momentIdIndex?.remove(id);
      SearchIndexService.instance.unindexMoment(id);
    } catch (e, stack) {
      _logger.error('Failed to delete moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> restoreTrashMoment(int id) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      final raw = _trashBox.get(id);
      if (raw != null) {
        Map<String, dynamic>? jsonMap;
        if (raw is Map) {
          jsonMap = Map<String, dynamic>.from(raw);
        } else if (raw is Moment) {
          jsonMap = raw.toJson();
        }
        if (jsonMap != null) {
          await _box.put(id, jsonMap);
          // Update entries cache and secondary indices
          final moment = Moment.fromJson(jsonMap);
          if (_cachedMoments != null) {
            _cachedMoments!.removeWhere((m) => m.id == id);
            _cachedMoments!.add(moment);
            _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }
          _momentIdIndex?[moment.id] = moment;
          SearchIndexService.instance.indexMoment(moment);
        }
        await _trashBox.delete(id);
        // Update trash cache
        if (_cachedTrashMoments != null) {
          _cachedTrashMoments!.removeWhere((m) => m.id == id);
        }
      }
    } catch (e, stack) {
      _logger.error('Failed to restore trash moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> restoreAllTrash() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      final entries = _trashBox.toMap();
      await _box.putAll(entries);
      await _trashBox.clear();
      // Invalidate caches
      _cachedMoments = null;
      _cachedTrashMoments = null;
    } catch (e, stack) {
      _logger.error('Failed to restore all trash moments', e, stack);
      rethrow;
    }
  }

  Future<void> permanentlyDeleteTrashMoment(int id) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      await _trashBox.delete(id);
      // Update trash cache
      if (_cachedTrashMoments != null) {
        _cachedTrashMoments!.removeWhere((m) => m.id == id);
      }
    } catch (e, stack) {
      _logger.error('Failed to permanently delete trash moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> clearTrash() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      await _trashBox.clear();
      _cachedTrashMoments = [];
    } catch (e, stack) {
      _logger.error('Failed to clear trash', e, stack);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      final entries = _box.toMap();
      if (entries.isNotEmpty) {
        await _trashBox.putAll(entries);
      }
      await _box.clear();
      await _prefs.remove(_nextIdKey);
      // Update caches
      _cachedMoments = [];
      _cachedTrashMoments = null;
    } catch (e, stack) {
      _logger.error('Failed to clear all moments', e, stack);
      rethrow;
    }
  }

  Future<void> replaceAll(List<Moment> moments) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      await _box.clear();
      final Map<int, dynamic> entries = {};
      int maxId = 0;
      for (final m in moments) {
        entries[m.id] = m.toJson();
        maxId = math.max(maxId, m.id);
      }
      await _box.putAll(entries);
      await _prefs.setInt(_nextIdKey, maxId + 1);
      // Update cache
      final copy = List<Moment>.from(moments);
      copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedMoments = copy;
    } catch (e, stack) {
      _logger.error('Failed to replace all moments', e, stack);
      rethrow;
    }
  }

  int getNextId() {
    return _prefs.getInt(_nextIdKey) ?? 1;
  }

  Future<List<Moment>> migrateLegacyData() async {
    final legacyRows = _prefs.getString(_legacyEntriesKey);
    if (legacyRows == null) return [];

    _logger.info('Migrating legacy data from SharedPreferences');
    try {
      final entries = (jsonDecode(legacyRows) as List)
          .map(
            (item) => Moment.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList();

      for (final entry in entries) {
        await _box.put(entry.id, entry.toJson());
      }

      await _prefs.remove(_legacyEntriesKey);
      _cachedMoments = null; // Invalidate cache
      _logger.info('Successfully migrated ${entries.length} legacy entries');
      return entries;
    } catch (e, stack) {
      _logger.error('Failed to migrate legacy data', e, stack);
      return [];
    }
  }
}
