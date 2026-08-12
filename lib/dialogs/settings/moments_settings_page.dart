import 'package:flutter/material.dart';
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
    required this.onCompactHistoryChanged,
    required this.onHistoryDensityChanged,
    required this.onConfirmDeleteChanged,
    required this.onEnableNoteOnClickChanged,
    required this.onExtendedDurationChanged,
    required this.onMinimalMomentOptionsChanged,
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

  final ValueChanged<bool> onCompactHistoryChanged;
  final ValueChanged<String> onHistoryDensityChanged;
  final ValueChanged<bool> onConfirmDeleteChanged;
  final ValueChanged<bool> onEnableNoteOnClickChanged;
  final ValueChanged<bool> onExtendedDurationChanged;
  final ValueChanged<bool> onMinimalMomentOptionsChanged;
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
              onChanged: (value) {
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
        SettingsPageDescription(
          p: p,
          text:
              'Controls log spacing density, tap actions, and delete confirmations for history moments.'
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
