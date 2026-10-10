import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MomentRepository {
  static final MomentRepository _instance = MomentRepository._internal();
  factory MomentRepository() => _instance;
  MomentRepository._internal();

  static const String _nextIdKey = 'notekar.nextId';
  static const String _legacyEntriesKey = 'notekar.entries';
  static const String _autoSnapshotKey = 'notekar.auto_rolling_snapshot';
  static const String _lastSnapshotTimeKey = 'notekar.last_auto_snapshot_ms';
  static const String keyCorruptedFlag = 'notekar.database_corrupted_flag';
  static const String keyRecoveredFromSnapshot =
      'notekar.database_recovered_from_snapshot';

  Isar? _isar;
  Isar? _trashIsar;
  late SharedPreferences _prefs;
  final _logger = AppLogger();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isIsarAvailable => _isar != null && _isar!.isOpen;

  List<Moment>? _cachedMoments;
  List<Moment>? _cachedTrashMoments;
  Map<int, Moment>? _momentIdIndex;

  Future<void> ensureInitialized({
    SharedPreferences? preloadedPrefs,
    String? directoryPath,
  }) async {
    if (_isInitialized) return;
    await initialize(
      preloadedPrefs: preloadedPrefs,
      directoryPath: directoryPath,
    );
  }

  Future<void> initialize({
    SharedPreferences? preloadedPrefs,
    String? directoryPath,
  }) async {
    if (_isInitialized) return;
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();

    if (!Platform.isAndroid && !Platform.isIOS) {
      try {
        await Isar.initializeIsarCore(download: true);
      } catch (_) {}
    }

    String? dataDirPath = directoryPath;
    if (dataDirPath == null) {
      try {
        const channel = MethodChannel('notekar/files');
        dataDirPath = await channel.invokeMethod<String>('appDataDir');
      } catch (_) {}
    }
    dataDirPath ??= Directory.systemTemp.path;

    try {
      _isar =
          Isar.getInstance('notekar_entries_v1') ??
          await Isar.open(
            [MomentSchema],
            name: 'notekar_entries_v1',
            directory: dataDirPath,
          );
      _trashIsar =
          Isar.getInstance('notekar_trash_v1') ??
          await Isar.open(
            [MomentSchema],
            name: 'notekar_trash_v1',
            directory: dataDirPath,
          );
      _logger.info(
        'MomentRepository initialized with ${_isar!.moments.countSync()} entries, ${_trashIsar!.moments.countSync()} trash entries',
      );
    } catch (e, stack) {
      _logger.warning(
        'Isar native core could not be opened in current environment ($e). Operating in robust in-memory/snapshot mode.',
        e,
        stack,
      );
      _isar = null;
      _trashIsar = null;
    }

    _isInitialized = true;

    unawaited(
      Future(() async {
        await _autoPurgeOldTrash();
      }),
    );

    unawaited(
      Future(() {
        getAllMoments();
        getTrashMoments();
        triggerAutoSnapshotIfNeeded();
      }),
    );
  }

  Future<void> close() async {
    if (_isInitialized) {
      try {
        if (_isar != null && _isar!.isOpen) {
          await _isar!.close();
        }
      } catch (_) {}
      try {
        if (_trashIsar != null && _trashIsar!.isOpen) {
          await _trashIsar!.close();
        }
      } catch (_) {}
      _isar = null;
      _trashIsar = null;
      _isInitialized = false;
      _cachedMoments = null;
      _cachedTrashMoments = null;
      _momentIdIndex = null;
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

  Future<void> _autoPurgeOldTrash() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final thirtyDaysAgo = now - const Duration(days: 30).inMilliseconds;

      if (_trashIsar != null && _trashIsar!.isOpen) {
        final oldTrash = _trashIsar!.moments
            .filter()
            .timestampLessThan(thirtyDaysAgo)
            .findAllSync();
        if (oldTrash.isNotEmpty) {
          for (final m in oldTrash) {
            unawaited(MediaStorageService.instance.deleteMediaForMoment(m));
          }
          await _trashIsar!.writeTxn(() async {
            await _trashIsar!.moments.deleteAll(
              oldTrash.map((e) => e.id).toList(),
            );
          });
          _cachedTrashMoments = null;
          _logger.info(
            'Auto-purged ${oldTrash.length} trash entries older than 30 days',
          );
        }
      } else if (_cachedTrashMoments != null) {
        final oldTrash = _cachedTrashMoments!
            .where((m) => m.timestamp < thirtyDaysAgo)
            .toList();
        for (final m in oldTrash) {
          unawaited(MediaStorageService.instance.deleteMediaForMoment(m));
        }
        _cachedTrashMoments!.removeWhere((m) => m.timestamp < thirtyDaysAgo);
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
    if (_isar != null && _isar!.isOpen) {
      try {
        final moments = _isar!.moments
            .where()
            .sortByTimestampDesc()
            .findAllSync();
        _cachedMoments = moments;
        _momentIdIndex = {for (final m in moments) m.id: m};
        SearchIndexService.instance.buildIndex(moments);
        return moments;
      } catch (e, stack) {
        _logger.error('Failed to load moments from Isar', e, stack);
      }
    }
    final snapshot = _prefs.getString(_autoSnapshotKey);
    if (snapshot != null && snapshot.isNotEmpty) {
      try {
        final list = (jsonDecode(snapshot) as List)
            .map((e) => Moment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _cachedMoments = list;
        _momentIdIndex = {for (final m in list) m.id: m};
        SearchIndexService.instance.buildIndex(list);
        return list;
      } catch (_) {}
    }
    _cachedMoments = [];
    _momentIdIndex = {};
    return [];
  }

  Moment? getMomentById(int id) {
    if (_momentIdIndex != null) {
      return _momentIdIndex![id];
    }
    getAllMoments();
    return _momentIdIndex?[id];
  }

  List<Moment> getMomentsBetween(int startMs, int endMs) {
    if (!_isInitialized) return const [];
    final moments = getAllMoments();
    if (moments.isEmpty) return const [];

    // O(log N) binary range slicing on moments sorted descending by timestamp
    int low = 0;
    int high = moments.length - 1;
    int firstIdx = -1;

    // Find first moment with timestamp <= endMs (inclusive upper bound)
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (moments[mid].timestamp <= endMs) {
        firstIdx = mid;
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    if (firstIdx == -1) return const [];

    // Find last moment with timestamp >= startMs (inclusive lower bound)
    low = firstIdx;
    high = moments.length - 1;
    int lastIdx = -1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (moments[mid].timestamp >= startMs) {
        lastIdx = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    if (lastIdx == -1 || lastIdx < firstIdx) return const [];

    return moments.sublist(firstIdx, lastIdx + 1);
  }

  Future<void> performDailyMaintenance() async {
    try {
      _logger.info('Performing daily background maintenance...');
      await triggerAutoSnapshotIfNeeded(force: true);
      await _autoPurgeOldTrash();
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
    if (_trashIsar != null && _trashIsar!.isOpen) {
      try {
        final moments = _trashIsar!.moments
            .where()
            .sortByTimestampDesc()
            .findAllSync();
        _cachedTrashMoments = moments;
        return moments;
      } catch (e, stack) {
        _logger.error('Failed to load trash moments from Isar', e, stack);
      }
    }
    _cachedTrashMoments = [];
    return _cachedTrashMoments!;
  }

  Future<void> saveMoment(Moment moment) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      if (_isar != null && _isar!.isOpen) {
        await _isar!.writeTxn(() async {
          await _isar!.moments.put(moment);
        });
      }
      final currentNextId = _prefs.getInt(_nextIdKey) ?? 0;
      if (moment.id >= currentNextId) {
        await _prefs.setInt(_nextIdKey, moment.id + 1);
      }

      _cachedMoments ??= [];
      _cachedMoments!.removeWhere((m) => m.id == moment.id);
      _cachedMoments!.add(moment);
      _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _momentIdIndex ??= {};
      _momentIdIndex![moment.id] = moment;
      SearchIndexService.instance.indexMoment(moment);
    } catch (e, stack) {
      _logger.error('Failed to save moment ${moment.id}', e, stack);
      rethrow;
    }
  }

  /// Persists related moments in one Isar transaction so paired sessions never
  /// leave only one endpoint in the database if a write fails.
  Future<void> saveMoments(List<Moment> moments) async {
    if (moments.isEmpty) return;
    if (!_isInitialized) await ensureInitialized();

    final ids = moments.map((moment) => moment.id).toSet();
    if (ids.length != moments.length) {
      throw ArgumentError('Moment IDs in a batch must be unique.');
    }

    if (_isar != null && _isar!.isOpen) {
      try {
        await _isar!.writeTxn(() async {
          await _isar!.moments.putAll(moments);
        });
      } catch (e, stack) {
        _logger.error('Failed to save moment batch', e, stack);
        rethrow;
      }
    }

    final maxId = moments.map((moment) => moment.id).reduce(math.max);
    final currentNextId = _prefs.getInt(_nextIdKey) ?? 0;
    if (maxId >= currentNextId) {
      try {
        await _prefs.setInt(_nextIdKey, maxId + 1);
      } catch (e, stack) {
        // The moments are already durable. Do not report a failed save after
        // the transaction committed; the caller must still update its UI.
        _logger.error(
          'Failed to advance next moment ID after batch save',
          e,
          stack,
        );
      }
    }

    _cachedMoments ??= [];
    _momentIdIndex ??= {};
    for (final moment in moments) {
      _cachedMoments!.removeWhere((cached) => cached.id == moment.id);
      _cachedMoments!.add(moment);
      _momentIdIndex![moment.id] = moment;
      try {
        SearchIndexService.instance.indexMoment(moment);
      } catch (e, stack) {
        _logger.error('Failed indexing saved moment ${moment.id}', e, stack);
      }
    }
    _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteMoment(int id) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      Moment? moment;
      if (_isar != null && _isar!.isOpen) {
        moment = await _isar!.moments.get(id);
      }
      moment ??= _momentIdIndex?[id];

      if (moment != null) {
        if (_trashIsar != null && _trashIsar!.isOpen) {
          await _trashIsar!.writeTxn(() async {
            await _trashIsar!.moments.put(moment!);
          });
        }
        _cachedTrashMoments ??= [];
        _cachedTrashMoments!.removeWhere((m) => m.id == id);
        _cachedTrashMoments!.add(moment);
        _cachedTrashMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      if (_isar != null && _isar!.isOpen) {
        await _isar!.writeTxn(() async {
          await _isar!.moments.delete(id);
        });
      }

      _cachedMoments?.removeWhere((m) => m.id == id);
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
      Moment? moment;
      if (_trashIsar != null && _trashIsar!.isOpen) {
        moment = await _trashIsar!.moments.get(id);
      }
      if (moment == null && _cachedTrashMoments != null) {
        final matches = _cachedTrashMoments!.where((m) => m.id == id);
        if (matches.isNotEmpty) moment = matches.first;
      }

      if (moment != null) {
        if (_isar != null && _isar!.isOpen) {
          await _isar!.writeTxn(() async {
            await _isar!.moments.put(moment!);
          });
        }

        _cachedMoments ??= [];
        _cachedMoments!.removeWhere((m) => m.id == id);
        _cachedMoments!.add(moment);
        _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _momentIdIndex?[moment.id] = moment;
        SearchIndexService.instance.indexMoment(moment);

        if (_trashIsar != null && _trashIsar!.isOpen) {
          await _trashIsar!.writeTxn(() async {
            await _trashIsar!.moments.delete(id);
          });
        }

        _cachedTrashMoments?.removeWhere((m) => m.id == id);
      }
    } catch (e, stack) {
      _logger.error('Failed to restore trash moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> restoreAllTrash() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      if (_trashIsar != null && _trashIsar!.isOpen) {
        final allTrash = await _trashIsar!.moments.where().findAll();
        if (_isar != null && _isar!.isOpen) {
          await _isar!.writeTxn(() async {
            await _isar!.moments.putAll(allTrash);
          });
        }
        await _trashIsar!.writeTxn(() async {
          await _trashIsar!.moments.clear();
        });
      } else if (_cachedTrashMoments != null &&
          _cachedTrashMoments!.isNotEmpty) {
        _cachedMoments ??= [];
        _cachedMoments!.addAll(_cachedTrashMoments!);
        _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _momentIdIndex = {for (final m in _cachedMoments!) m.id: m};
      }

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
      Moment? moment;
      if (_trashIsar != null && _trashIsar!.isOpen) {
        moment = await _trashIsar!.moments.get(id);
        if (moment != null) {
          unawaited(MediaStorageService.instance.deleteMediaForMoment(moment));
        }
        await _trashIsar!.writeTxn(() async {
          await _trashIsar!.moments.delete(id);
        });
      }
      _cachedTrashMoments?.removeWhere((m) => m.id == id);
    } catch (e, stack) {
      _logger.error('Failed to permanently delete trash moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> clearTrash() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      if (_trashIsar != null && _trashIsar!.isOpen) {
        final allTrash = await _trashIsar!.moments.where().findAll();
        for (final m in allTrash) {
          unawaited(MediaStorageService.instance.deleteMediaForMoment(m));
        }
        await _trashIsar!.writeTxn(() async {
          await _trashIsar!.moments.clear();
        });
      }
      _cachedTrashMoments = [];
    } catch (e, stack) {
      _logger.error('Failed to clear trash', e, stack);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      if (_isar != null && _isar!.isOpen) {
        final allEntries = await _isar!.moments.where().findAll();
        if (allEntries.isNotEmpty && _trashIsar != null && _trashIsar!.isOpen) {
          await _trashIsar!.writeTxn(() async {
            await _trashIsar!.moments.putAll(allEntries);
          });
        }
        await _isar!.writeTxn(() async {
          await _isar!.moments.clear();
        });
      } else if (_cachedMoments != null && _cachedMoments!.isNotEmpty) {
        _cachedTrashMoments ??= [];
        _cachedTrashMoments!.addAll(_cachedMoments!);
      }

      await _prefs.remove(_nextIdKey);
      _cachedMoments = [];
      _momentIdIndex = {};
      _cachedTrashMoments = null;
    } catch (e, stack) {
      _logger.error('Failed to clear all moments', e, stack);
      rethrow;
    }
  }

  Future<void> replaceAll(List<Moment> moments) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      if (_isar != null && _isar!.isOpen) {
        await _isar!.writeTxn(() async {
          await _isar!.moments.clear();
          await _isar!.moments.putAll(moments);
        });
      }

      int maxId = 0;
      for (final m in moments) {
        maxId = math.max(maxId, m.id);
      }
      await _prefs.setInt(_nextIdKey, maxId + 1);

      final copy = List<Moment>.from(moments);
      copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedMoments = copy;
      _momentIdIndex = {for (final m in copy) m.id: m};
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

      if (_isar != null && _isar!.isOpen) {
        await _isar!.writeTxn(() async {
          await _isar!.moments.putAll(entries);
        });
      } else {
        _cachedMoments ??= [];
        _cachedMoments!.addAll(entries);
        _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _momentIdIndex = {for (final m in _cachedMoments!) m.id: m};
      }

      await _prefs.remove(_legacyEntriesKey);
      _cachedMoments = null;
      _logger.info('Successfully migrated ${entries.length} legacy entries');
      return entries;
    } catch (e, stack) {
      _logger.error('Failed to migrate legacy data', e, stack);
      return [];
    }
  }
}
