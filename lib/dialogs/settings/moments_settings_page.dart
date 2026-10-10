import 'package:flutter/cupertino.dart';
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
    this.historyDensity = 'comfortable',
    required this.confirmDelete,
    this.extendedDuration = true,
    required this.minimalMomentOptions,
    required this.notesCount,
    this.useNumbersInSingle = false,
    this.resetSingleDaily = false,
    this.countOnSave = false,
    this.showImagesAlways = true,

    required this.onHistoryDensityChanged,
    required this.onConfirmDeleteChanged,
    this.onShowImagesAlwaysChanged,
    this.onExtendedDurationChanged,
    required this.onMinimalMomentOptionsChanged,
    required this.onUseNumbersInSingleChanged,
    required this.onResetSingleDailyChanged,
    required this.onCountOnSaveChanged,
    required this.onOpenCategory,
  });

  final Palette p;
  final bool showTrashBin;
  final List<Moment> trash;
  final String historyDensity;
  final bool confirmDelete;
  final bool showImagesAlways;
  final bool extendedDuration;
  final bool minimalMomentOptions;
  final int notesCount;
  final bool useNumbersInSingle;
  final bool resetSingleDaily;
  final bool countOnSave;

  final ValueChanged<String> onHistoryDensityChanged;
  final ValueChanged<bool> onConfirmDeleteChanged;
  final ValueChanged<bool>? onShowImagesAlwaysChanged;
  final ValueChanged<bool>? onExtendedDurationChanged;
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
              title: 'Confirm Delete',
              color: p.red,
              value: confirmDelete,
              onChanged: onConfirmDeleteChanged,
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Show Images Always',
              subtitle:
                  'Keep timeline photos expanded by default. When disabled, photos appear as compact bars.',
              color: p.accent,
              value: showImagesAlways,
              onChanged: onShowImagesAlwaysChanged ?? (_) {},
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
                if (value && historyDensity == 'compact') {
                  final confirmed = await showFeatureConflictDialog(
                    context,
                    p: p,
                    title: 'Disable Compact History?',
                    message:
                        'Sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. Turn off Compact History to enable numbers in single mode.',
                    confirmLabel: 'Turn Off & Enable',
                    icon: CupertinoIcons.pin,
                    iconColor: p.accent,
                  );
                  if (!confirmed) return;

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
              icon: CupertinoIcons.search,
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
