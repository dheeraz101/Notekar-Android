import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/calendar_sync_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/markdown_sync_service.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class IntegrationsSettingsPage extends StatefulWidget {
  const IntegrationsSettingsPage({
    super.key,
    required this.p,
    required this.entriesNotifier,
    required this.onTriggerUrlScheme,
  });

  final Palette p;
  final ValueNotifier<List<Moment>> entriesNotifier;
  final ValueChanged<String> onTriggerUrlScheme;

  @override
  State<IntegrationsSettingsPage> createState() =>
      _IntegrationsSettingsPageState();
}

class _IntegrationsSettingsPageState extends State<IntegrationsSettingsPage> {
  bool _exportingMarkdown = false;
  bool _exportingCalendar = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'.localized(context)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportMarkdown() async {
    setState(() => _exportingMarkdown = true);
    HapticFeedback.mediumImpact();
    final moments = widget.entriesNotifier.value;
    final success = await const MarkdownSyncService().exportMarkdownFile(
      moments,
    );
    if (mounted) {
      setState(() => _exportingMarkdown = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Markdown journal exported to Downloads!'.localized(context)
                : 'Failed to export Markdown journal.'.localized(context),
          ),
          backgroundColor: success ? const Color(0xFF248A3D) : widget.p.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportCalendar() async {
    setState(() => _exportingCalendar = true);
    HapticFeedback.mediumImpact();
    final moments = widget.entriesNotifier.value;
    final success = await const CalendarSyncService().exportCalendarFile(
      moments,
    );
    if (mounted) {
      setState(() => _exportingCalendar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Calendar (.ics) sessions exported to Downloads!'.localized(
                    context,
                  )
                : 'Failed to export Calendar sessions.'.localized(context),
          ),
          backgroundColor: success ? const Color(0xFF248A3D) : widget.p.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      children: [
        const SizedBox(height: spacing8),

        // Deep Linking & URL Scheme
        SettingsGroup(
          p: p,
          title: 'Deep Linking & URL Scheme'.localized(context).toUpperCase(),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.link,
              title: 'notekar://log?type=single',
              subtitle: 'Log a single instant moment with optional note'
                  .localized(context),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copyToClipboard(
                  'notekar://log?type=single&note=Coffee',
                  'URL',
                ),
              ),
              color: p.accent,
              onTap: () => widget.onTriggerUrlScheme(
                'notekar://log?type=single&note=Quick%20Log',
              ),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_right_circle,
              title: 'notekar://in & notekar://out',
              subtitle: 'Trigger Two-Way check-in or check-out'.localized(
                context,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copyToClipboard(
                  'notekar://in?note=Focus%20Session',
                  'URL',
                ),
              ),
              color: p.green,
              onTap: () =>
                  widget.onTriggerUrlScheme('notekar://in?note=Focus%20Work'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.doc_text,
              title: 'notekar://note?text=...',
              subtitle: 'Open note composer prefilled with text'.localized(
                context,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () =>
                    _copyToClipboard('notekar://note?text=My%20Idea', 'URL'),
              ),
              color: p.orange,
              onTap: () => widget.onTriggerUrlScheme(
                'notekar://note?text=Quick%20Thought',
              ),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.compass,
              title: 'notekar://open?page=history',
              subtitle: 'Directly navigate to history, stats, or settings'
                  .localized(context),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () =>
                    _copyToClipboard('notekar://open?page=history', 'URL'),
              ),
              color: p.accent,
              onTap: () =>
                  widget.onTriggerUrlScheme('notekar://open?page=history'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Use URL schemes with NFC tags, browser bookmarks, or automation launchers to control NoteKar instantly.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // System Text Selection & Share Target
        SettingsGroup(
          p: p,
          title: 'System Bridges'.localized(context).toUpperCase(),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.selection_pin_in_out,
              title: 'Text Selection Context Menu'.localized(context),
              subtitle:
                  'Highlight text anywhere in Android and tap "Log in NoteKar"'
                      .localized(context),
              status: 'Active'.localized(context),
              color: p.accent,
              onTap: null,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.share,
              title: 'Android Share Target'.localized(context),
              subtitle:
                  'Share plain text and links from any app directly to NoteKar'
                      .localized(context),
              status: 'Active'.localized(context),
              color: p.green,
              onTap: null,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Capture quotes, reading notes, and links without leaving Chrome, WhatsApp, or reader apps.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Obsidian & Second Brain Interop
        SettingsGroup(
          p: p,
          title: 'Obsidian & Markdown Journal'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: Icons.article_rounded,
              title: 'Export Markdown Journal (.md)'.localized(context),
              subtitle: 'Formatted tables, timestamps, and daily telemetry'
                  .localized(context),
              status: _exportingMarkdown ? 'Exporting...' : 'Export',
              color: const Color(0xFF7000FF),
              onTap: _exportingMarkdown ? null : _exportMarkdown,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Compatible with Obsidian, Logseq, and Notion. Generates pristine Markdown tables sorted by date.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Calendar .ics Session Sync
        SettingsGroup(
          p: p,
          title: 'Calendar Sessions (.ics)'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.calendar,
              title: 'Export Sessions to Calendar (.ics)'.localized(context),
              subtitle:
                  'Converts Two-Way IN/OUT intervals into RFC 5545 calendar events'
                      .localized(context),
              status: _exportingCalendar ? 'Exporting...' : 'Export',
              color: p.orange,
              onTap: _exportingCalendar ? null : _exportCalendar,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Import your tracked focus sessions directly into Google Calendar, Samsung Calendar, Outlook, or Proton Calendar.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Tasker & Automation Broadcast API
        SettingsGroup(
          p: p,
          title: 'Tasker & Broadcast API'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.radiowaves_right,
              title: 'ACTION_LOG_MOMENT',
              subtitle: 'app.notekar.notekar.ACTION_LOG_MOMENT'.localized(
                context,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copyToClipboard(
                  'am broadcast -a app.notekar.notekar.ACTION_LOG_MOMENT --es type single --es note "Deep Work"',
                  'ADB Broadcast Command',
                ),
              ),
              color: p.accent,
              onTap: () => _copyToClipboard(
                'am broadcast -a app.notekar.notekar.ACTION_LOG_MOMENT --es type single --es note "Deep Work"',
                'ADB Broadcast Command',
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Send broadcast intents with extras (type: "single"|"in"|"out"|"note", note: string) to log in background.'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }
}
