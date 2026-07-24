import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:hive/hive.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MomentRepository {
  static const String _entryBoxName = 'notekar_entries_v1';
  static const String _trashBoxName = 'notekar_trash_v1';
  static const String _nextIdKey = 'notekar.nextId';
  static const String _legacyEntriesKey = 'notekar.entries';

  late Box<dynamic> _box;
  late Box<dynamic> _trashBox;
  late SharedPreferences _prefs;
  final _logger = AppLogger();

  // In-memory cache to boost read performance
  List<Moment>? _cachedMoments;
  List<Moment>? _cachedTrashMoments;

  Future<void> initialize({SharedPreferences? preloadedPrefs}) async {
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();

    // Database Corruption Recovery Wrapper
    try {
      _box = await Hive.openBox<dynamic>(_entryBoxName);
    } catch (e, stack) {
      _logger.error(
        'Failed to open entry box due to corruption. Recreating...',
        e,
        stack,
      );
      try {
        await Hive.deleteBoxFromDisk(_entryBoxName);
        _box = await Hive.openBox<dynamic>(_entryBoxName);
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
      _trashBox = await Hive.openBox<dynamic>(_trashBoxName);
    } catch (e, stack) {
      _logger.error(
        'Failed to open trash box due to corruption. Recreating...',
        e,
        stack,
      );
      try {
        await Hive.deleteBoxFromDisk(_trashBoxName);
        _trashBox = await Hive.openBox<dynamic>(_trashBoxName);
      } catch (innerE, innerStack) {
        _logger.error(
          'Failed to recreate corrupted trash box.',
          innerE,
          innerStack,
        );
        rethrow;
      }
    }

    await _autoPurgeOldTrash();

    if (_box.length > 300) {
      unawaited(_box.compact());
    }
    if (_trashBox.length > 300) {
      unawaited(_trashBox.compact());
    }

    // Pre-populate the cache in the background for zero-delay read paths
    getAllMoments();
    getTrashMoments();

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
    try {
      final moments = _box.values
          .whereType<Map>()
          .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedMoments = moments;
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load moments from Hive', e, stack);
      return [];
    }
  }

  List<Moment> getTrashMoments() {
    if (_cachedTrashMoments != null) {
      return _cachedTrashMoments!;
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
    try {
      await _box.put(moment.id, moment.toJson());
      final currentNextId = _prefs.getInt(_nextIdKey) ?? 0;
      if (moment.id >= currentNextId) {
        await _prefs.setInt(_nextIdKey, moment.id + 1);
      }
      // Update local cache
      if (_cachedMoments != null) {
        _cachedMoments!.removeWhere((m) => m.id == moment.id);
        _cachedMoments!.add(moment);
        _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e, stack) {
      _logger.error('Failed to save moment ${moment.id}', e, stack);
      rethrow;
    }
  }

  Future<void> deleteMoment(int id) async {
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
      // Update entries cache
      if (_cachedMoments != null) {
        _cachedMoments!.removeWhere((m) => m.id == id);
      }
    } catch (e, stack) {
      _logger.error('Failed to delete moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> restoreTrashMoment(int id) async {
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
          // Update entries cache
          if (_cachedMoments != null) {
            final moment = Moment.fromJson(jsonMap);
            _cachedMoments!.removeWhere((m) => m.id == id);
            _cachedMoments!.add(moment);
            _cachedMoments!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }
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
    try {
      await _trashBox.clear();
      _cachedTrashMoments = [];
    } catch (e, stack) {
      _logger.error('Failed to clear trash', e, stack);
      rethrow;
    }
  }

  Future<void> clearAll() async {
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
          .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
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
