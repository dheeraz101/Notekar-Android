import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class MomentsSettingsPage extends StatelessWidget {
  const MomentsSettingsPage({
    super.key,
    required this.p,
    required this.controller,
    this.onOpenTrash,
    this.lastDeletedPreview,
  });

  final Palette p;
  final SettingsController controller;
  final VoidCallback? onOpenTrash;
  final String? lastDeletedPreview;

  @override
  Widget build(BuildContext context) {
    final previewText = (lastDeletedPreview != null && lastDeletedPreview!.isNotEmpty)
        ? lastDeletedPreview!
        : 'No moments deleted';

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          children: [
            const SizedBox(height: 8),
            if (onOpenTrash != null) ...[
              SettingsGroup(
                p: p,
                children: [
                  SettingsRow(
                    p: p,
                    icon: Icons.delete_outline_rounded,
                    title: 'Recently Deleted',
                    status: previewText,
                    color: p.orange,
                    onTap: onOpenTrash!,
                  ),
                ],
              ),
              SettingsPageDescription(
                p: p,
                text: 'View and restore moments deleted within the last 30 days.',
              ),
            ],
            SettingsGroup(
              p: p,
              title: 'History Controls',
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Compact History',
                  color: p.accent,
                  value: controller.compactHistory,
                  onChanged: (val) {
                    controller.setCompactHistory(val);
                    controller.setHistoryDensity(val ? 'compact' : 'comfortable');
                  },
                ),
                SettingsSwitchRow(
                  p: p,
                  title: 'Confirm Delete',
                  color: p.red,
                  value: controller.confirmDelete,
                  onChanged: (val) => controller.setConfirmDelete(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Controls log spacing density and requires confirmation before deleting history moments.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Extended Duration',
                  color: p.accent,
                  value: controller.extendedDuration,
                  onChanged: (val) => controller.setExtendedDuration(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Includes years, months, and days breakdown for long time intervals.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Minimal Moment Options',
                  color: p.accent,
                  value: controller.minimalMomentOptions,
                  onChanged: (val) => controller.setMinimalMomentOptions(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Enables streamlined icon-only quick action buttons when managing history moments.',
            ),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }
}
