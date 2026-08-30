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
import 'package:notekar/widgets/common_elements.dart';
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
    showIosPillToast(
      context: context,
      p: widget.p,
      message: '$label copied'.localized(context),
      icon: Icons.copy_rounded,
    );
  }

  void _showSavedToast({required bool success, required String message}) {
    if (!mounted) return;
    showIosPillToast(
      context: context,
      p: widget.p,
      message: message,
      icon: success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
    );
  }

  Future<void> _exportMarkdown() async {
    if (_exportingMarkdown) return;
    setState(() => _exportingMarkdown = true);
    HapticFeedback.mediumImpact();

    final moments = widget.entriesNotifier.value;
    final exportOp = const MarkdownSyncService().exportMarkdownFile(moments);
    final delayOp = Future.delayed(const Duration(milliseconds: 1500));

    final results = await Future.wait([exportOp, delayOp]);
    final savedFileName = results[0];

    if (mounted) {
      setState(() => _exportingMarkdown = false);
      if (savedFileName != null) {
        _showSavedToast(
          success: true,
          message: 'Saved to Downloads/$savedFileName'.localized(context),
        );
      } else {
        _showSavedToast(
          success: false,
          message: 'Failed to export Markdown journal.'.localized(context),
        );
      }
    }
  }

  Future<void> _exportCalendar() async {
    if (_exportingCalendar) return;
    setState(() => _exportingCalendar = true);
    HapticFeedback.mediumImpact();

    final moments = widget.entriesNotifier.value;
    final exportOp = const CalendarSyncService().exportCalendarFile(moments);
    final delayOp = Future.delayed(const Duration(milliseconds: 1500));

    final results = await Future.wait([exportOp, delayOp]);
    final savedFileName = results[0];

    if (mounted) {
      setState(() => _exportingCalendar = false);
      if (savedFileName != null) {
        _showSavedToast(
          success: true,
          message: 'Saved to Downloads/$savedFileName'.localized(context),
        );
      } else {
        _showSavedToast(
          success: false,
          message: 'Failed to export Calendar sessions.'.localized(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      children: [
        const SizedBox(height: spacing8),

        // URL Schemes
        SettingsGroup(
          p: p,
          title: 'URL Schemes'.localized(context).toUpperCase(),
          insetDividers: false,
          children: [
            SettingsRow(
              p: p,
              title: 'Quick Log'.localized(context),
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
              title: 'Check-In & Out'.localized(context),
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
              title: 'Draft Note'.localized(context),
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
              title: 'Open Screen'.localized(context),
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

        // System Bridges
        SettingsGroup(
          p: p,
          title: 'System Bridges'.localized(context).toUpperCase(),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.selection_pin_in_out,
              title: 'Text Selection Menu'.localized(context),
              status: 'Active'.localized(context),
              color: p.accent,
              onTap: null,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.share,
              title: 'Share Target'.localized(context),
              status: 'Active'.localized(context),
              color: p.green,
              onTap: null,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Capture quotes, reading notes, and links directly from Chrome, WhatsApp, or other apps.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Obsidian & Markdown Journal
        SettingsGroup(
          p: p,
          title: 'Markdown Journal'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: Icons.article_rounded,
              title: 'Export Journal (.md)'.localized(context),
              status: _exportingMarkdown ? null : 'Export'.localized(context),
              trailing: _exportingMarkdown
                  ? const CupertinoActivityIndicator(radius: 9)
                  : null,
              color: const Color(0xFF7000FF),
              onTap: _exportingMarkdown ? null : _exportMarkdown,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Generates date-grouped Markdown tables compatible with Obsidian, Logseq, and Notion.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Calendar Sessions (.ics)
        SettingsGroup(
          p: p,
          title: 'Calendar Sessions'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.calendar,
              title: 'Export Calendar (.ics)'.localized(context),
              status: _exportingCalendar ? null : 'Export'.localized(context),
              trailing: _exportingCalendar
                  ? const CupertinoActivityIndicator(radius: 9)
                  : null,
              color: p.orange,
              onTap: _exportingCalendar ? null : _exportCalendar,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Converts Two-Way intervals into standard calendar events for Google Calendar, Outlook, and Samsung Calendar.'
                  .localized(context),
        ),

        const SizedBox(height: spacing16),

        // Tasker Broadcast API
        SettingsGroup(
          p: p,
          title: 'Automation Broadcast API'.localized(context).toUpperCase(),
          insetDividers: false,
          children: [
            SettingsRow(
              p: p,
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
              'Send offline broadcast intents from Tasker, MacroDroid, or Termux with extras to log moments.'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }
}
