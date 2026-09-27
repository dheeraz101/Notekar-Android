import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notekar/models/moment.dart';

/// Service for converting NoteKar Two-Way session intervals and moments into RFC 5545 iCalendar (.ics) files.
class CalendarSyncService {
  const CalendarSyncService();

  /// Generates a standard RFC 5545 .ics file content from moments.
  String generateICalendar(
    List<Moment> moments, {
    String calendarName = 'NoteKar Focus Sessions',
  }) {
    final buffer = StringBuffer();
    final nowUtc = DateFormat(
      "yyyyMMdd'T'HHmmss'Z'",
    ).format(DateTime.now().toUtc());

    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//DigitalSuraksha//NoteKar//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:$calendarName');
    buffer.writeln('X-WR-TIMEZONE:UTC');

    // 1. Pair Two-Way IN and OUT moments into discrete session intervals
    final sorted = List<Moment>.from(moments)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Moment? activeIn;
    final sessions = <_SessionInterval>[];

    for (final m in sorted) {
      if (m.type == 'in') {
        activeIn = m;
      } else if (m.type == 'out' && activeIn != null) {
        sessions.add(
          _SessionInterval(
            start: DateTime.fromMillisecondsSinceEpoch(activeIn.timestamp),
            end: DateTime.fromMillisecondsSinceEpoch(m.timestamp),
            startNote: activeIn.note,
            endNote: m.note,
            id: '${activeIn.id}_${m.id}',
          ),
        );
        activeIn = null;
      } else if (m.type == 'single' || m.type == 'note') {
        // Individual discrete moment (instantaneous point in time)
        final startDt = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
        sessions.add(
          _SessionInterval(
            start: startDt,
            end: startDt,
            startNote: m.note,
            endNote: '',
            id: '${m.id}_single',
            isSingle: true,
          ),
        );
      }
    }

    String escapeIcs(String text) {
      return text
          .replaceAll(r'\', r'\\')
          .replaceAll(';', r'\;')
          .replaceAll(',', r'\,')
          .replaceAll('\r\n', r'\n')
          .replaceAll('\n', r'\n');
    }

    // Write each VEVENT
    for (final s in sessions) {
      final dtStart = DateFormat(
        "yyyyMMdd'T'HHmmss'Z'",
      ).format(s.start.toUtc());
      final dtEnd = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(s.end.toUtc());
      final uid = 'notekar_session_${s.id}@notekar.app';

      final title = s.isSingle
          ? (s.startNote.isNotEmpty
                ? escapeIcs('⚡ ${s.startNote}')
                : '⚡ NoteKar Moment')
          : (s.startNote.isNotEmpty
                ? escapeIcs('⏳ ${s.startNote}')
                : '⏳ NoteKar Focus Session');

      final description = StringBuffer();
      if (s.isSingle) {
        description.write(escapeIcs('Logged single moment in NoteKar.'));
        if (s.startNote.isNotEmpty) {
          description.write('\\nNote: ${escapeIcs(s.startNote)}');
        }
      } else {
        final durationMins = s.end.difference(s.start).inMinutes;
        final durationHours = durationMins ~/ 60;
        final remMins = durationMins % 60;
        final durationLabel = durationHours > 0
            ? '${durationHours}h ${remMins}m'
            : '${remMins}m';

        description.write(
          escapeIcs('Two-Way Tracked Interval: $durationLabel'),
        );
        if (s.startNote.isNotEmpty) {
          description.write('\\nIN Note: ${escapeIcs(s.startNote)}');
        }
        if (s.endNote.isNotEmpty) {
          description.write('\\nOUT Note: ${escapeIcs(s.endNote)}');
        }
      }

      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:$uid');
      buffer.writeln('DTSTAMP:$nowUtc');
      buffer.writeln('DTSTART:$dtStart');
      buffer.writeln('DTEND:$dtEnd');
      buffer.writeln('SUMMARY:$title');
      buffer.writeln('DESCRIPTION:${description.toString()}');
      buffer.writeln('STATUS:CONFIRMED');
      buffer.writeln('TRANSP:OPAQUE');
      buffer.writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  /// Exports .ics calendar file to Downloads/Storage.
  Future<String?> exportCalendarFile(
    List<Moment> moments, {
    String? customFileName,
  }) async {
    const channel = MethodChannel('notekar/files');
    final fileName =
        customFileName ??
        'notekar-sessions-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.ics';
    final content = generateICalendar(moments);

    try {
      final res = await channel.invokeMethod<String>('saveTextFile', {
        'fileName': fileName,
        'content': content,
        'mimeType': 'text/calendar',
      });
      if (res != null && res.isNotEmpty) {
        return fileName;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _SessionInterval {
  _SessionInterval({
    required this.start,
    required this.end,
    required this.startNote,
    required this.endNote,
    required this.id,
    this.isSingle = false,
  });

  final DateTime start;
  final DateTime end;
  final String startNote;
  final String endNote;
  final String id;
  final bool isSingle;
}
