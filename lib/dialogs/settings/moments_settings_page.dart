import 'package:flutter/material.dart';
import 'package:notekar/dialogs/feature_conflict_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class MomentsSettingsPage extends StatelessWidget {
  const MomentsSettingsPage({
    super.key,
    required this.p,
    required this.showTrashBin,
    required this.trash,
    required this.compactHistory,
    required this.confirmDelete,
    required this.enableNoteOnClick,
    required this.extendedDuration,
    required this.minimalMomentOptions,
    required this.notesCount,
    this.useNumbersInSingle = false,
    this.resetSingleDaily = false,
    this.countOnSave = false,
    required this.onCompactHistoryChanged,
    required this.onHistoryDensityChanged,
    required this.onConfirmDeleteChanged,
    required this.onEnableNoteOnClickChanged,
    required this.onExtendedDurationChanged,
    required this.onMinimalMomentOptionsChanged,
    required this.onUseNumbersInSingleChanged,
    required this.onResetSingleDailyChanged,
    required this.onCountOnSaveChanged,
    required this.onOpenCategory,
  });

  final Palette p;
  final bool showTrashBin;
  final List<Moment> trash;
  final bool compactHistory;
  final bool confirmDelete;
  final bool enableNoteOnClick;
  final bool extendedDuration;
  final bool minimalMomentOptions;
  final int notesCount;
  final bool useNumbersInSingle;
  final bool resetSingleDaily;
  final bool countOnSave;

  final ValueChanged<bool> onCompactHistoryChanged;
  final ValueChanged<String> onHistoryDensityChanged;
  final ValueChanged<bool> onConfirmDeleteChanged;
  final ValueChanged<bool> onEnableNoteOnClickChanged;
  final ValueChanged<bool> onExtendedDurationChanged;
  final ValueChanged<bool> onMinimalMomentOptionsChanged;
  final ValueChanged<bool> onUseNumbersInSingleChanged;
  final ValueChanged<bool> onResetSingleDailyChanged;
  final ValueChanged<bool> onCountOnSaveChanged;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),

        SettingsGroup(
          p: p,
          title: 'History Controls',
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Compact History',
              color: p.accent,
              value: compactHistory,
              onChanged: (value) async {
                if (value && useNumbersInSingle) {
                  final confirmed = await showFeatureConflictDialog(
                    context,
                    p: p,
                    title: 'Turn Off Single Numbers?',
                    message:
                        'Compact History cannot be enabled while Single Moment Numbering is active. Disable Single Numbers to use compact rows.',
                    confirmLabel: 'Turn Off & Enable',
                    icon: Icons.compress_rounded,
                    iconColor: p.accent,
                  );
                  if (!confirmed) return;
                  onUseNumbersInSingleChanged(false);
                }
                final density = value ? 'compact' : 'comfortable';
                onCompactHistoryChanged(value);
                onHistoryDensityChanged(density);
              },
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Confirm Delete',
              color: p.red,
              value: confirmDelete,
              onChanged: onConfirmDeleteChanged,
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Note on Click',
              subtitle:
                  'Tap a moment to view or edit its note, and long-press to select for duration.',
              color: p.accent,
              value: enableNoteOnClick,
              onChanged: onEnableNoteOnClickChanged,
            ),
          ],
        ),
        SettingsGroup(
          p: p,
          title: 'Single Moment Numbering',
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Use Numbers in Single',
              subtitle:
                  'Display sequential 2-digit numbers (00–99) instead of icons in single history moments.',
              color: p.accent,
              value: useNumbersInSingle,
              onChanged: (value) async {
                if (value && compactHistory) {
                  final confirmed = await showFeatureConflictDialog(
                    context,
                    p: p,
                    title: 'Disable Compact History?',
                    message:
                        'Sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. Turn off Compact History to enable numbers in single mode.',
                    confirmLabel: 'Turn Off & Enable',
                    icon: Icons.pin_outlined,
                    iconColor: p.accent,
                  );
                  if (!confirmed) return;
                  onCompactHistoryChanged(false);
                  onHistoryDensityChanged('comfortable');
                }
                onUseNumbersInSingleChanged(value);
              },
            ),
            if (useNumbersInSingle) ...[
              SettingsSwitchRow(
                p: p,
                title: 'Reset Daily',
                subtitle:
                    'Restart single count from 00 every calendar day while preserving past history.',
                color: p.accent,
                value: resetSingleDaily,
                onChanged: onResetSingleDailyChanged,
              ),
              SettingsSwitchRow(
                p: p,
                title: 'Enable Count on Save',
                subtitle:
                    'Show the 2-digit count on the tap pulse animation instead of "SINGLE saved".',
                color: p.accent,
                value: countOnSave,
                onChanged: onCountOnSaveChanged,
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              '00 is the starting point. Moments count up to 99 and then restart at 00. If Reset Daily is enabled, today\'s single count restarts from 00 the next day while preserving all past history. If disabled, counting continues across days until 99 and then restarts from 00.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Extended Duration',
              color: p.accent,
              value: extendedDuration,
              onChanged: onExtendedDurationChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Includes years, months, and days breakdown for long time intervals between moments.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Minimal Moment Options',
              color: p.accent,
              value: minimalMomentOptions,
              onChanged: onMinimalMomentOptionsChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enables streamlined icon-only quick action buttons when managing history moments.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.search_rounded,
              title: 'Search Notes'.localized(context),
              color: p.accent,
              status: '$notesCount ${'Notes'.localized(context)}',
              onTap: () => onOpenCategory('Search Notes', parent: 'Moments'),
            ),
          ],
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
