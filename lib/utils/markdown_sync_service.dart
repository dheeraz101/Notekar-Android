import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notekar/models/moment.dart';

/// Service for exporting and formatting NoteKar moments into Obsidian/Logseq-compliant Markdown.
class MarkdownSyncService {
  const MarkdownSyncService();

  /// Converts a list of moments into a structured Markdown document.
  String generateMarkdown(
    List<Moment> moments, {
    String title = 'NoteKar Journal',
  }) {
    if (moments.isEmpty) {
      return '# $title\n\n*No moments recorded yet.*';
    }

    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln(
      '> ⚡ *Generated offline via NoteKar on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}*',
    );
    buffer.writeln();

    // Group moments by date
    final grouped = <String, List<Moment>>{};
    for (final m in moments) {
      final dateKey = m.date.isNotEmpty
          ? m.date
          : DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.fromMillisecondsSinceEpoch(m.timestamp));
      grouped.putIfAbsent(dateKey, () => []).add(m);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final dayMoments = grouped[date]!;
      dayMoments.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      DateTime? parsedDate;
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      } catch (_) {}

      final dayLabel = parsedDate != null
          ? DateFormat('EEEE, MMMM d, yyyy').format(parsedDate)
          : date;

      buffer.writeln('## 📅 $dayLabel');
      buffer.writeln();
      buffer.writeln('| Time | Type | Details / Note |');
      buffer.writeln('| :--- | :--- | :--- |');

      for (final moment in dayMoments) {
        final timeStr = DateFormat(
          'hh:mm:ss a',
        ).format(DateTime.fromMillisecondsSinceEpoch(moment.timestamp));
        final typeBadge = _formatTypeBadge(moment.type);
        final safeNote = moment.note
            .replaceAll('|', '\\|')
            .replaceAll('\n', ' ')
            .trim();
        final displayNote = safeNote.isNotEmpty ? safeNote : '*No note*';

        buffer.writeln('| `$timeStr` | $typeBadge | $displayNote |');
      }

      buffer.writeln();
    }

    // Summary Statistics
    buffer.writeln('---');
    buffer.writeln('### 📊 Summary Telemetry');
    buffer.writeln('- **Total Moments**: ${moments.length}');
    buffer.writeln('- **Active Days**: ${sortedDates.length}');
    buffer.writeln(
      '- **Single Logs**: ${moments.where((m) => m.type == 'single').length}',
    );
    buffer.writeln(
      '- **IN Sessions**: ${moments.where((m) => m.type == 'in').length}',
    );
    buffer.writeln(
      '- **OUT Sessions**: ${moments.where((m) => m.type == 'out').length}',
    );
    buffer.writeln();

    return buffer.toString();
  }

  /// Exports markdown to the user's Downloads or local storage.
  Future<bool> exportMarkdownFile(
    List<Moment> moments, {
    String? customFileName,
  }) async {
    const channel = MethodChannel('notekar/files');
    final fileName =
        customFileName ??
        'notekar-journal-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.md';
    final content = generateMarkdown(moments);

    try {
      final res = await channel.invokeMethod<String>('saveTextFile', {
        'fileName': fileName,
        'content': content,
        'mimeType': 'text/markdown',
      });
      return res != null && res.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _formatTypeBadge(String type) {
    switch (type.toLowerCase()) {
      case 'in':
        return '🟢 **IN**';
      case 'out':
        return '🔴 **OUT**';
      case 'note':
        return '📝 **NOTE**';
      case 'single':
      default:
        return '⚡ **SINGLE**';
    }
  }
}
