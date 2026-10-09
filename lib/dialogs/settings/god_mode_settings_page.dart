import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class GodModeSettingsPage extends StatelessWidget {
  const GodModeSettingsPage({
    super.key,
    required this.p,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.totalMoments,
    required this.streakDays,
    required this.onRelockGodMode,
    this.onOpenAppIcons,
  });

  final Palette p;
  final String currentTheme;
  final ValueChanged<String> onThemeChanged;
  final int totalMoments;
  final int streakDays;
  final VoidCallback onRelockGodMode;
  final VoidCallback? onOpenAppIcons;

  Future<void> _confirmRevocation(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: p.name == 'light' ? Brightness.light : Brightness.dark,
          primaryColor: p.accent,
        ),
        child: CupertinoAlertDialog(
          title: Text('Revoke God Mode?'.localized(ctx)),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'This will deactivate secret themes, lock the God Mode icon, and remove the God Mode card from history.'
                  .localized(ctx),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel'.localized(ctx)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Revoke God Mode'.localized(ctx)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      onRelockGodMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),

        // Secret Themes Group
        SettingsGroup(
          p: p,
          title: 'Secret Developer Themes'.localized(context).toUpperCase(),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.chevron_left_slash_chevron_right,
              title: 'Matrix Phosphor Terminal'.localized(context),
              subtitle: 'Monospace green on OLED black'.localized(context),
              trailing: currentTheme == 'matrix'
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: Color(0xFF00FF41),
                      size: 20,
                    )
                  : const SizedBox.shrink(),
              color: const Color(0xFF00FF41),
              onTap: () {
                HapticFeedback.selectionClick();
                onThemeChanged(currentTheme == 'matrix' ? 'dark' : 'matrix');
              },
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.book,
              title: 'Kindle E-Ink Paperwhite'.localized(context),
              subtitle: '100% monochrome grayscale contrast'.localized(context),
              trailing: currentTheme == 'eink'
                  ? Icon(CupertinoIcons.checkmark, color: p.text, size: 20)
                  : const SizedBox.shrink(),
              color: p.text2,
              onTap: () {
                HapticFeedback.selectionClick();
                onThemeChanged(currentTheme == 'eink' ? 'dark' : 'eink');
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Exclusive themes unlocked via sovereign God Mode authorization.'
                  .localized(context),
        ),

        const SizedBox(height: spacing12),

        // Exclusive God Mode App Icon Group
        SettingsGroup(
          p: p,
          title: 'Exclusive God Mode App Icon'.localized(context).toUpperCase(),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1A24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFFD700,
                          ).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'D',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'God Mode Icon'.localized(context),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFD700,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'UNLOCKED',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Handcrafted obsidian & gold icon unlocked in App Icons.'
                              .localized(context),
                          style: TextStyle(color: p.text2, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.sparkles,
              title: 'Customize in App Icons'.localized(context),
              subtitle: 'Select and activate this exclusive icon'.localized(
                context,
              ),
              status: 'Open'.localized(context),
              color: const Color(0xFFFFD700),
              onTap: () {
                HapticFeedback.selectionClick();
                onOpenAppIcons?.call();
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'This exclusive icon is now unlocked in your App Icons gallery.'
              .localized(context),
        ),

        const SizedBox(height: spacing12),

        // Lock Control
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.lock_shield,
              title: 'Revoke God Mode'.localized(context),
              subtitle: 'Deactivates secret perks and relocks God Mode'
                  .localized(context),
              color: p.red,
              onTap: () => _confirmRevocation(context),
            ),
          ],
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
