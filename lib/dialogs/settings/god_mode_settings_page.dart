import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/pioneer_badge_dialog.dart';
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
  });

  final Palette p;
  final String currentTheme;
  final ValueChanged<String> onThemeChanged;
  final int totalMoments;
  final int streakDays;
  final VoidCallback onRelockGodMode;

  Future<void> _confirmRevocation(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Revoke God Mode?'.localized(ctx)),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'This will deactivate secret themes, lock the VIP badge, and remove the God Mode card from history.'
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
              icon: Icons.terminal_rounded,
              title: 'Matrix Phosphor Terminal'.localized(context),
              subtitle: 'Monospace green on OLED black'.localized(context),
              trailing: currentTheme == 'matrix'
                  ? const Icon(
                      Icons.check_rounded,
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
              icon: Icons.menu_book_rounded,
              title: 'Kindle E-Ink Paperwhite'.localized(context),
              subtitle: '100% monochrome grayscale contrast'.localized(context),
              trailing: currentTheme == 'eink'
                  ? Icon(Icons.check_rounded, color: p.text, size: 20)
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

        // Interactive Lab Group
        SettingsGroup(
          p: p,
          title: 'Credentials'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              icon: Icons.badge_rounded,
              title: 'VIP Pioneer Badge'.localized(context),
              status: 'View'.localized(context),
              color: const Color(0xFFFFD700),
              onTap: () => PioneerBadgeDialog.show(
                context,
                p: p,
                totalMoments: totalMoments,
                streakDays: streakDays,
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Cryptographic SHA-256 sovereign integrity credentials and telemetry.'
                  .localized(context),
        ),

        const SizedBox(height: spacing12),

        // Lock Control
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.lock_reset_rounded,
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
