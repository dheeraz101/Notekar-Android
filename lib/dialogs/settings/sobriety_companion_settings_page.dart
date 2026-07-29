import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class SobrietyCompanionSettingsPage extends StatelessWidget {
  const SobrietyCompanionSettingsPage({
    super.key,
    required this.p,
    required this.enableSobrietyMode,
    required this.sobrietyResetType,
    required this.sobrietyCustomStartMs,
    required this.sobrietyMilestoneTheme,
    required this.onEnableSobrietyModeChanged,
    required this.onSobrietyResetTypeChanged,
    required this.onSobrietyCustomStartMsChanged,
    required this.onOpenCategory,
    required this.onSelectStartDate,
  });

  final Palette p;
  final bool enableSobrietyMode;
  final String sobrietyResetType;
  final int? sobrietyCustomStartMs;
  final String sobrietyMilestoneTheme;

  final ValueChanged<bool> onEnableSobrietyModeChanged;
  final ValueChanged<String> onSobrietyResetTypeChanged;
  final ValueChanged<int?> onSobrietyCustomStartMsChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final Future<DateTime?> Function(BuildContext context, DateTime initial)
  onSelectStartDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Privacy-first streak tracking and relapse diary. All data stays on your device. Existing logs are never altered.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          title: 'Streak Mode'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              icon: Icons.self_improvement_rounded,
              title: 'Enable Sobriety Mode'.localized(context),
              subtitle:
                  'Adds a clean streak card to your home screen and adapts home screen widgets.'
                      .localized(context),
              color: p.orange,
              value: enableSobrietyMode,
              onChanged: onEnableSobrietyModeChanged,
            ),
          ],
        ),
        if (enableSobrietyMode) ...[
          SettingsPageDescription(
            p: p,
            text:
                'Your home screen will show a live streak card with milestone badges. The home widget will adapt to show RESET and DIARY buttons.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Streak Reset Logic'.localized(context),
            children: [
              SettingsSwitchRow(
                p: p,
                icon: Icons.restart_alt_rounded,
                title: 'Reset on Relapse Tag Only'.localized(context),
                subtitle:
                    'Only moments tagged #relapse reset the streak. Turn off to reset on any new log.'
                        .localized(context),
                color: p.orange,
                value: sobrietyResetType == 'relapse',
                onChanged: (value) {
                  onSobrietyResetTypeChanged(value ? 'relapse' : 'any');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Trigger Diary'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.analytics_rounded,
                title: 'Trigger Analysis'.localized(context),
                subtitle:
                    'View your relapse pattern insights, top moods, and peak vulnerability windows.'
                        .localized(context),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () => onOpenCategory(
                  'Trigger Analysis',
                  parent: 'Sobriety Companion',
                ),
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'When logging a moment with Sobriety Mode on, you can tag mood (Bored, Anxious, Lonely...) and trigger (Social Media, Late Night...). These are stored as hashtags in the note for full backwards compatibility.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Custom Start Date'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.calendar_today_rounded,
                title: 'Set Sobriety Start Date'.localized(context),
                subtitle: sobrietyCustomStartMs != null
                    ? '${"From".localized(context)} ${datePretty(sobrietyCustomStartMs!)} ${"at".localized(context)} ${timeOnly(sobrietyCustomStartMs!).substring(0, 5)}'
                    : 'Not set: using last log or relapse tag'.localized(
                        context,
                      ),
                color: p.orange,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sobrietyCustomStartMs != null)
                      GestureDetector(
                        onTap: () {
                          onSobrietyCustomStartMsChanged(null);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: p.text3,
                          size: 18,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: p.text3, size: 20),
                  ],
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final initialDateTime = sobrietyCustomStartMs != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                          sobrietyCustomStartMs!,
                        )
                      : now.subtract(const Duration(days: 7));
                  final picked = await onSelectStartDate(
                    context,
                    initialDateTime,
                  );
                  if (picked != null) {
                    onSobrietyCustomStartMsChanged(
                      picked.millisecondsSinceEpoch,
                    );
                  }
                },
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Were you already clean before installing? Set your actual start date here. This overrides automatic detection from your logs.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Milestone Theme'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.palette_rounded,
                title: 'Theme Style'.localized(context),
                subtitle: () {
                  final t = kMilestoneThemes.firstWhere(
                    (t) => t.id == sobrietyMilestoneTheme,
                    orElse: () => kMilestoneThemes.first,
                  );
                  return '${t.emoji} ${t.name.localized(context)}: ${t.description.localized(context)}';
                }(),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () => onOpenCategory(
                  'Milestone Theme',
                  parent: 'Sobriety Companion',
                ),
              ),
              SettingsRow(
                p: p,
                icon: Icons.emoji_events_rounded,
                title: 'View All Milestones'.localized(context),
                subtitle:
                    'See all 21 milestones with descriptions from day 1 to 10 years.'
                        .localized(context),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () =>
                    onOpenCategory('Milestones', parent: 'Sobriety Companion'),
              ),
            ],
          ),
        ],
        const SizedBox(height: spacing48),
      ],
    );
  }
}
