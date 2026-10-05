import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:notekar/models/moment.dart';
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

  late Isar _isar;
  late Isar _trashIsar;
  late SharedPreferences _prefs;
  final _logger = AppLogger();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

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

    _logger.info(
      'MomentRepository initialized with ${_isar.moments.countSync()} entries, ${_trashIsar.moments.countSync()} trash entries',
    );
  }

  Future<void> close() async {
    if (_isInitialized) {
      try {
        if (_isar.isOpen) {
          await _isar.close();
        }
      } catch (_) {}
      try {
        if (_trashIsar.isOpen) {
          await _trashIsar.close();
        }
      } catch (_) {}
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

      final oldTrash = _trashIsar.moments
          .filter()
          .timestampLessThan(thirtyDaysAgo)
          .findAllSync();
      if (oldTrash.isNotEmpty) {
        await _trashIsar.writeTxn(() async {
          await _trashIsar.moments.deleteAll(
            oldTrash.map((e) => e.id).toList(),
          );
        });
        _cachedTrashMoments = null;
        _logger.info(
          'Auto-purged ${oldTrash.length} trash entries older than 30 days',
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
      final moments = _isar.moments.where().sortByTimestampDesc().findAllSync();
      _cachedMoments = moments;
      _momentIdIndex = {for (final m in moments) m.id: m};
      SearchIndexService.instance.buildIndex(moments);
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load moments from Isar', e, stack);
      return [];
    }
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
    return _isar.moments
        .filter()
        .timestampBetween(startMs, endMs)
        .sortByTimestampDesc()
        .findAllSync();
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
    try {
      final moments = _trashIsar.moments
          .where()
          .sortByTimestampDesc()
          .findAllSync();
      _cachedTrashMoments = moments;
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load trash moments from Isar', e, stack);
      return [];
    }
  }

  Future<void> saveMoment(Moment moment) async {
    if (!_isInitialized) await ensureInitialized();
    try {
      await _isar.writeTxn(() async {
        await _isar.moments.put(moment);
      });
      final currentNextId = _prefs.getInt(_nextIdKey) ?? 0;
      if (moment.id >= currentNextId) {
        await _prefs.setInt(_nextIdKey, moment.id + 1);
      }

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
      final moment = await _isar.moments.get(id);
      if (moment != null) {
        await _trashIsar.writeTxn(() async {
          await _trashIsar.moments.put(moment);
        });
        if (_cachedTrashMoments != null) {
          _cachedTrashMoments!.removeWhere((m) => m.id == id);
          _cachedTrashMoments!.add(moment);
          _cachedTrashMoments!.sort(
            (a, b) => b.timestamp.compareTo(a.timestamp),
          );
        }
      }

      await _isar.writeTxn(() async {
        await _isar.moments.delete(id);
      });

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
      final moment = await _trashIsar.moments.get(id);
      if (moment != null) {
        await _isar.writeTxn(() async {
          await _isar.moments.put(moment);
        });

        if (_cachedMoments != null) {
          _cachedMoments!.removeWhere((m) => m.id == id);
          _cachedMoments!.add(moment);
          _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
        _momentIdIndex?[moment.id] = moment;
        SearchIndexService.instance.indexMoment(moment);

        await _trashIsar.writeTxn(() async {
          await _trashIsar.moments.delete(id);
        });

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
      final allTrash = await _trashIsar.moments.where().findAll();
      await _isar.writeTxn(() async {
        await _isar.moments.putAll(allTrash);
      });
      await _trashIsar.writeTxn(() async {
        await _trashIsar.moments.clear();
      });

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
      await _trashIsar.writeTxn(() async {
        await _trashIsar.moments.delete(id);
      });
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
      await _trashIsar.writeTxn(() async {
        await _trashIsar.moments.clear();
      });
      _cachedTrashMoments = [];
    } catch (e, stack) {
      _logger.error('Failed to clear trash', e, stack);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    if (!_isInitialized) await ensureInitialized();
    try {
      final allEntries = await _isar.moments.where().findAll();
      if (allEntries.isNotEmpty) {
        await _trashIsar.writeTxn(() async {
          await _trashIsar.moments.putAll(allEntries);
        });
      }
      await _isar.writeTxn(() async {
        await _isar.moments.clear();
      });

      await _prefs.remove(_nextIdKey);
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
      await _isar.writeTxn(() async {
        await _isar.moments.clear();
        await _isar.moments.putAll(moments);
      });

      int maxId = 0;
      for (final m in moments) {
        maxId = math.max(maxId, m.id);
      }
      await _prefs.setInt(_nextIdKey, maxId + 1);

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

      await _isar.writeTxn(() async {
        await _isar.moments.putAll(entries);
      });

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
