import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_logger.dart';

class MomentRepository {
  static const String _entryBoxName = 'notekar_entries_v1';
  static const String _trashBoxName = 'notekar_trash_v1';
  static const String _nextIdKey = 'notekar.nextId';
  static const String _legacyEntriesKey = 'notekar.entries';

  late Box<dynamic> _box;
  late Box<dynamic> _trashBox;
  late SharedPreferences _prefs;
  final _logger = AppLogger();

  Future<void> initialize({SharedPreferences? preloadedPrefs}) async {
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();
    _box = await Hive.openBox<dynamic>(_entryBoxName);
    _trashBox = await Hive.openBox<dynamic>(_trashBoxName);

    await _autoPurgeOldTrash();

    if (_box.length > 300) {
      unawaited(_box.compact());
    }
    if (_trashBox.length > 300) {
      unawaited(_trashBox.compact());
    }
    _logger.info('MomentRepository initialized with ${_box.length} entries, ${_trashBox.length} trash entries');
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
        _logger.info('Auto-purged ${keysToRemove.length} trash entries older than 30 days');
      }
    } catch (e, stack) {
      _logger.error('Failed auto-purging old trash entries', e, stack);
    }
  }

  List<Moment> getAllMoments() {
    try {
      final moments = _box.values
          .whereType<Map>()
          .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return moments;
    } catch (e, stack) {
      _logger.error('Failed to load moments from Hive', e, stack);
      return [];
    }
  }

  List<Moment> getTrashMoments() {
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
    } catch (e, stack) {
      _logger.error('Failed to save moment ${moment.id}', e, stack);
      rethrow;
    }
  }

  Future<void> deleteMoment(int id) async {
    try {
      final raw = _box.get(id);
      if (raw != null) {
        if (raw is Map) {
          await _trashBox.put(id, Map<String, dynamic>.from(raw));
        } else if (raw is Moment) {
          await _trashBox.put(id, raw.toJson());
        } else {
          await _trashBox.put(id, raw);
        }
      }
      await _box.delete(id);
    } catch (e, stack) {
      _logger.error('Failed to delete moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> restoreTrashMoment(int id) async {
    try {
      final raw = _trashBox.get(id);
      if (raw != null) {
        if (raw is Map) {
          await _box.put(id, Map<String, dynamic>.from(raw));
        } else if (raw is Moment) {
          await _box.put(id, raw.toJson());
        } else {
          await _box.put(id, raw);
        }
        await _trashBox.delete(id);
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
    } catch (e, stack) {
      _logger.error('Failed to restore all trash moments', e, stack);
      rethrow;
    }
  }

  Future<void> permanentlyDeleteTrashMoment(int id) async {
    try {
      await _trashBox.delete(id);
    } catch (e, stack) {
      _logger.error('Failed to permanently delete trash moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> clearTrash() async {
    try {
      await _trashBox.clear();
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
      _logger.info('Successfully migrated ${entries.length} legacy entries');
      return entries;
    } catch (e, stack) {
      _logger.error('Failed to migrate legacy data', e, stack);
      return [];
    }
  }
}
