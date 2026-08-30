import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/pioneer_badge_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GodModeSettingsPage extends StatefulWidget {
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

  @override
  State<GodModeSettingsPage> createState() => _GodModeSettingsPageState();
}

class _GodModeSettingsPageState extends State<GodModeSettingsPage> {
  bool _gameEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadGameSetting();
  }

  Future<void> _loadGameSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _gameEnabled = prefs.getBool('god_mode_game_enabled') ?? false;
    });
  }

  Future<void> _toggleGame(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('god_mode_game_enabled', val);
    if (!mounted) return;
    setState(() => _gameEnabled = val);
  }

  Future<void> _confirmRevocation() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text('Revoke God Mode?'.localized(ctx)),
        content: Text(
          'This will deactivate secret themes, hide the Chrono Focus home game, lock the VIP badge, and remove the God Mode card from history. You can unlock it again anytime with the secret cipher.'
              .localized(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'.localized(ctx)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: widget.p.red),
            child: Text(
              'Revoke God Mode'.localized(ctx),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onRelockGodMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

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
              trailing: widget.currentTheme == 'matrix'
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF00FF41),
                      size: 20,
                    )
                  : const SizedBox.shrink(),
              color: const Color(0xFF00FF41),
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onThemeChanged(
                  widget.currentTheme == 'matrix' ? 'dark' : 'matrix',
                );
              },
            ),
            SettingsRow(
              p: p,
              icon: Icons.menu_book_rounded,
              title: 'Kindle E-Ink Paperwhite'.localized(context),
              subtitle: '100% monochrome grayscale contrast'.localized(context),
              trailing: widget.currentTheme == 'eink'
                  ? Icon(Icons.check_rounded, color: p.text, size: 20)
                  : const SizedBox.shrink(),
              color: p.text2,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onThemeChanged(
                  widget.currentTheme == 'eink' ? 'dark' : 'eink',
                );
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
          title: 'Interactive Labs'.localized(context).toUpperCase(),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.radar_rounded,
              title: 'Chrono Focus Game'.localized(context),
              subtitle: 'Show reflex mini-game on home screen'.localized(
                context,
              ),
              trailing: Switch.adaptive(
                value: _gameEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  _toggleGame(val);
                },
                activeTrackColor: p.accent,
              ),
              color: const Color(0xFF00E5FF),
              onTap: () => _toggleGame(!_gameEnabled),
            ),
            SettingsRow(
              p: p,
              icon: Icons.badge_rounded,
              title: 'VIP Pioneer Badge'.localized(context),
              subtitle: 'Cryptographic SHA-256 telemetry card'.localized(
                context,
              ),
              status: 'View'.localized(context),
              color: const Color(0xFFFFD700),
              onTap: () => PioneerBadgeDialog.show(
                context,
                p: p,
                totalMoments: widget.totalMoments,
                streakDays: widget.streakDays,
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Focus-driven temporal reflex game and cryptographic integrity credentials.'
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
              onTap: _confirmRevocation,
            ),
          ],
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
