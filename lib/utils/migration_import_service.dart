import 'dart:convert';

import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';

class MigrationImportResult {
  final bool success;
  final String sourceApp;
  final int momentsCount;
  final List<Moment> moments;
  final String? errorMessage;

  const MigrationImportResult({
    required this.success,
    required this.sourceApp,
    required this.momentsCount,
    required this.moments,
    this.errorMessage,
  });

  const MigrationImportResult.error(String message)
    : success = false,
      sourceApp = 'Unknown',
      momentsCount = 0,
      moments = const [],
      errorMessage = message;
}

/// Universal migration importer that brings habits and moments from
/// Loop Habit Tracker, HabitKit, and generic CSV spreadsheets into NoteKar.
class MigrationImportService {
  static MigrationImportResult parseMigrationContent(String rawContent) {
    final content = rawContent.trim();
    if (content.isEmpty) {
      return const MigrationImportResult.error('The selected file is empty.');
    }

    // 1. Try parsing as JSON (HabitKit or JSON exports)
    if (content.startsWith('{') || content.startsWith('[')) {
      final jsonResult = _tryParseJson(content);
      if (jsonResult != null) {
        return jsonResult;
      }
    }

    // 2. Try parsing as CSV (Loop Habit Tracker or generic spreadsheets)
    final csvResult = _tryParseCsv(content);
    if (csvResult != null) {
      return csvResult;
    }

    return const MigrationImportResult.error(
      'Unsupported file format. Please provide a Loop Habit Tracker CSV or HabitKit JSON export.',
    );
  }

  static MigrationImportResult? _tryParseJson(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      // Check HabitKit format: { "habits": [ { "name": "...", "completions": [...] } ] }
      if (map.containsKey('habits') && map['habits'] is List) {
        final habits = map['habits'] as List;
        final moments = <Moment>[];
        int idCounter = 1;

        for (final h in habits) {
          if (h is! Map) continue;
          final habitMap = Map<String, dynamic>.from(h);
          final rawName = habitMap['name']?.toString() ?? 'Habit';
          final cleanTag = rawName
              .replaceAll(RegExp(r'\s+'), '_')
              .replaceAll(RegExp(r'[^\w]'), '');
          final tagNote = cleanTag.isNotEmpty ? '#$cleanTag' : rawName;

          final completions = habitMap['completions'];
          if (completions is List) {
            for (final comp in completions) {
              final dateStr = comp.toString().trim();
              final dt = DateTime.tryParse(dateStr);
              if (dt != null) {
                // Set timestamp to noon on that day
                final noon = DateTime(dt.year, dt.month, dt.day, 12, 0);
                final ts = noon.millisecondsSinceEpoch;
                moments.add(
                  Moment(
                    id: idCounter++,
                    timestamp: ts,
                    type: 'single',
                    date: dateKey(noon),
                    note: tagNote,
                  ),
                );
              }
            }
          }
        }

        if (moments.isNotEmpty) {
          moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return MigrationImportResult(
            success: true,
            sourceApp: 'HabitKit',
            momentsCount: moments.length,
            moments: moments,
          );
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static MigrationImportResult? _tryParseCsv(String content) {
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) return null;

    final headerLine = lines.first.trim();
    final separator = headerLine.contains(';') ? ';' : ',';
    final headers = headerLine
        .split(separator)
        .map((h) => h.trim().replaceAll('"', '').toLowerCase())
        .toList();

    // Check if Loop Habit Tracker (Date,HabitName,Value)
    // Or Wide table format (Date,Habit 1,Habit 2,...)
    final dateColIndex = headers.indexWhere(
      (h) => h.contains('date') || h.contains('timestamp') || h == 'day',
    );

    if (dateColIndex == -1) {
      return null;
    }

    final moments = <Moment>[];
    int idCounter = 1;

    // Check for Loop's 3-column long format: Date, Habit, Value
    final habitColIndex = headers.indexWhere(
      (h) => h.contains('habit') || h.contains('name') || h == 'action',
    );
    final valueColIndex = headers.indexWhere(
      (h) => h.contains('value') || h.contains('status') || h == 'count',
    );

    if (habitColIndex != -1 && valueColIndex != -1) {
      // Long format: Date,HabitName,Value
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final cols = line
            .split(separator)
            .map((c) => c.trim().replaceAll('"', ''))
            .toList();
        if (cols.length <=
            mathMax(dateColIndex, mathMax(habitColIndex, valueColIndex))) {
          continue;
        }

        final dateStr = cols[dateColIndex];
        final habitName = cols[habitColIndex];
        final valStr = cols[valueColIndex];
        final val = num.tryParse(valStr) ?? 0;

        if (val > 0 && habitName.isNotEmpty) {
          final dt = DateTime.tryParse(dateStr);
          if (dt != null) {
            final noon = DateTime(dt.year, dt.month, dt.day, 12, 0);
            final cleanTag = habitName
                .replaceAll(RegExp(r'\s+'), '_')
                .replaceAll(RegExp(r'[^\w]'), '');
            moments.add(
              Moment(
                id: idCounter++,
                timestamp: noon.millisecondsSinceEpoch,
                type: 'single',
                date: dateKey(noon),
                note: cleanTag.isNotEmpty ? '#$cleanTag' : habitName,
              ),
            );
          }
        }
      }

      if (moments.isNotEmpty) {
        moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return MigrationImportResult(
          success: true,
          sourceApp: 'Loop Habit Tracker',
          momentsCount: moments.length,
          moments: moments,
        );
      }
    }

    // Wide format: Date in col 0, and column headers are habit names with values > 0
    if (headers.length > 1) {
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final cols = line
            .split(separator)
            .map((c) => c.trim().replaceAll('"', ''))
            .toList();
        if (cols.length <= dateColIndex) continue;

        final dateStr = cols[dateColIndex];
        final dt = DateTime.tryParse(dateStr);
        if (dt == null) continue;

        final noon = DateTime(dt.year, dt.month, dt.day, 12, 0);

        for (int c = 0; c < cols.length; c++) {
          if (c == dateColIndex || c >= headers.length) continue;
          final habitHeader = headers[c];
          final val = num.tryParse(cols[c]) ?? 0;
          if (val > 0) {
            final cleanTag = habitHeader
                .replaceAll(RegExp(r'\s+'), '_')
                .replaceAll(RegExp(r'[^\w]'), '');
            moments.add(
              Moment(
                id: idCounter++,
                timestamp: noon.millisecondsSinceEpoch,
                type: 'single',
                date: dateKey(noon),
                note: cleanTag.isNotEmpty ? '#$cleanTag' : habitHeader,
              ),
            );
          }
        }
      }

      if (moments.isNotEmpty) {
        moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return MigrationImportResult(
          success: true,
          sourceApp: 'Spreadsheet / Habit CSV',
          momentsCount: moments.length,
          moments: moments,
        );
      }
    }

    return null;
  }

  static int mathMax(int a, int b) => a > b ? a : b;
}
