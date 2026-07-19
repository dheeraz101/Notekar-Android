import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/app_logger.dart';

class MomentRepository {
  static const String _entryBoxName = 'notekar_entries_v1';
  static const String _nextIdKey = 'notekar.nextId';
  static const String _legacyEntriesKey = 'notekar.entries';

  late Box<dynamic> _box;
  late SharedPreferences _prefs;
  final _logger = AppLogger();

  Future<void> initialize({SharedPreferences? preloadedPrefs}) async {
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();
    _box = await Hive.openBox<dynamic>(_entryBoxName);
    _logger.info('MomentRepository initialized with ${_box.length} entries');
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
      await _box.delete(id);
    } catch (e, stack) {
      _logger.error('Failed to delete moment $id', e, stack);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
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
