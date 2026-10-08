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
          title: 'Capture & Session Controls'.localized(context),
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
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Configure capture defaults, sequential counters, custom focus modes, and activity tags.'
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
            SettingsSwitchRow(
              p: p,
              title: 'Log ⚡ Quick Note Popup',
              subtitle:
                  'Open popup to pick quick activity tags and add notes when tapping Log ⚡ in notification drawer.'
                      .localized(context),
              value: notifLogAction != 'silent',
              color: p.accent,
              onChanged: onNotifLogActionChanged ?? (_) {},
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
