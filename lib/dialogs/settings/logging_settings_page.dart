import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class LoggingSettingsPage extends StatelessWidget {
  const LoggingSettingsPage({
    super.key,
    required this.p,
    required this.defaultMode,
    required this.entriesCount,
    this.notesCount = 0,
    required this.remindersStatus,
    required this.enableSobrietyMode,
    required this.showPersistentNotification,
    this.notifLogAction = 'popup',
    this.onNotifLogActionChanged,
    this.showTrashBin = false,
    this.trash = const [],
    this.rainbowCards = false,
    this.onRainbowCardsChanged,
    required this.onShowPersistentNotificationChanged,
    required this.onOpenCategory,
  });

  final Palette p;
  final String defaultMode;
  final int entriesCount;
  final int notesCount;
  final String remindersStatus;
  final bool enableSobrietyMode;
  final bool showPersistentNotification;
  final String notifLogAction;
  final ValueChanged<bool>? onNotifLogActionChanged;
  final bool showTrashBin;
  final List<Moment> trash;
  final bool rainbowCards;
  final ValueChanged<bool>? onRainbowCardsChanged;
  final ValueChanged<bool> onShowPersistentNotificationChanged;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.chart_bar_square,
              title: 'Dashboard'.localized(context),
              status: '$entriesCount ${'Logs'.localized(context)}',
              color: p.accent,
              onTap: () => onOpenCategory('Dashboard', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.hourglass,
              title: 'Life Audit'.localized(context),
              status: 'Time Wastage'.localized(context),
              color: p.red,
              onTap: () => onOpenCategory('Life Audit', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Executive activity intelligence, time wastage auditing, 24-hour baseline accounting, and mortality insights.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Logging Controls'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.hand_point_right_fill,
              title: 'Capture'.localized(context),
              status: defaultModeLabel(defaultMode),
              color: p.green,
              onTap: () => onOpenCategory('Capture', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.clock_fill,
              title: 'Moments'.localized(context),
              status: '$notesCount ${'Notes'.localized(context)}',
              color: p.orange,
              onTap: () => onOpenCategory('Moments', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.square_grid_2x2,
              title: 'Modes'.localized(context),
              status: 'Focus Modes'.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory('Modes', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.tag,
              title: 'Activity Tags'.localized(context),
              status: 'Quick Tags'.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory('Activity Tags', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.bell,
              title: 'Reminders'.localized(context),
              status: remindersStatus,
              color: p.accent,
              onTap: () => onOpenCategory('Reminders', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_up_doc,
              title: 'Backup & Export'.localized(context),
              status: 'Data'.localized(context),
              color: p.green,
              onTap: () => onOpenCategory('Backup & Export', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These settings define how moments are recorded and prepared for export.'
                  .localized(context),
        ),
        if (showTrashBin && trash.isNotEmpty) ...[
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            children: [
              SettingsRow(
                p: p,
                icon: CupertinoIcons.trash,
                title: 'Trash Bin'.localized(context),
                status:
                    '${trash.length} ${(trash.length == 1 ? "item" : "items").localized(context)}',
                color: p.orange,
                onTap: () => onOpenCategory('Trash Bin', parent: 'Logging'),
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text: 'View and restore moments deleted within the last 30 days.'
                .localized(context),
          ),
        ],
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.sparkles,
              title: 'Sobriety Companion',
              color: p.orange,
              status: enableSobrietyMode ? 'On' : 'Off',
              onTap: () =>
                  onOpenCategory('Sobriety Companion', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Track clean streaks, log relapses with mood and trigger tags, and view offline pattern analysis.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Notification Panel',
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Persistent Control',
              subtitle:
                  'Show a sticky notification in the drawer to log check-in/out directly from the lock screen.'
                      .localized(context),
              value: showPersistentNotification,
              color: p.accent,
              onChanged: onShowPersistentNotificationChanged,
            ),
            if (showPersistentNotification)
              SettingsSwitchRow(
                p: p,
                title: 'Quick Note Popup'.localized(context),
                subtitle:
                    'Prompt for tags and notes when logging from notification.'
                        .localized(context),
                value: notifLogAction != 'silent',
                color: p.accent,
                onChanged: onNotifLogActionChanged ?? (_) {},
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _NotificationPreviewCard(
                p: p,
                enabled: showPersistentNotification,
                quickNoteEnabled: notifLogAction != 'silent',
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enables quick, low-priority control notification in the system drawer for convenience.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Card Chromatics'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Rainbow Cards'.localized(context),
              subtitle:
                  'Tint cards with category colors across timeline, calendar, and search notes while preserving contrast.'
                      .localized(context),
              value: rainbowCards,
              color: p.accent,
              onChanged: onRainbowCardsChanged ?? (_) {},
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Subtle chromatic tinting provides effortless visual distinction between categories without visual fatigue.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _NotificationPreviewCard extends StatelessWidget {
  const _NotificationPreviewCard({
    required this.p,
    required this.enabled,
    required this.quickNoteEnabled,
  });

  final Palette p;
  final bool enabled;
  final bool quickNoteEnabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.surface2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.bell_slash_fill, size: 16, color: p.text3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Persistent drawer notification is turned off.'.localized(
                  context,
                ),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Header
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.clock_fill,
                  size: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text2,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '•',
                  style: TextStyle(color: p.text3, fontSize: 11),
                ),
              ),
              Text(
                'Active Session'.localized(context),
                style: TextStyle(color: p.text3, fontSize: 11),
              ),
              const Spacer(),
              Text('now', style: TextStyle(color: p.text3, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),

          // Notification Content
          Text(
            'Deep Work • Focus Mode'.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '01:24:18 elapsed · Chronometer live ticker'.localized(context),
            style: TextStyle(color: p.text2, fontSize: 11.5),
          ),
          const SizedBox(height: 10),

          // Action Chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.square_fill, size: 9, color: p.accent),
                    const SizedBox(width: 5),
                    Text(
                      'Check Out'.localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      quickNoteEnabled
                          ? CupertinoIcons.pencil_circle
                          : CupertinoIcons.bolt_fill,
                      size: 10,
                      color: p.text,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      (quickNoteEnabled ? 'Quick Note' : 'Quick Log').localized(
                        context,
                      ),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
