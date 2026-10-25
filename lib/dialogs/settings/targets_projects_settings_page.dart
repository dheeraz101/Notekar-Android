import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated Apple HIG settings page for Targets, Goals & Projects.
///
/// Features clean concise titles, subtitles, and Apple editorial descriptions.
class TargetsProjectsSettingsPage extends StatefulWidget {
  const TargetsProjectsSettingsPage({
    super.key,
    required this.p,
    this.onOpenCategory,
  });

  final Palette p;
  final void Function(String category, {required String parent})?
  onOpenCategory;

  @override
  State<TargetsProjectsSettingsPage> createState() =>
      _TargetsProjectsSettingsPageState();
}

class _TargetsProjectsSettingsPageState
    extends State<TargetsProjectsSettingsPage> {
  static const _channel = MethodChannel('notekar/files');

  bool _reflectionEnabled = true;
  bool _celebrationEnabled = true;
  bool _dailyPacingEnabled = true;
  bool _autoTagEnabled = true;
  bool _exclusiveMode = true;
  bool _floatingTimerEnabled = false;
  String _singleTapAction = 'quick_log';
  String _doubleTapAction = 'quick_menu';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _reflectionEnabled =
            prefs.getBool('goals_reflection_enabled') ??
            prefs.getBool('targets_session_reflection') ??
            prefs.getBool('projects_session_reflection') ??
            true;
        _celebrationEnabled =
            prefs.getBool('goals_celebration_enabled') ?? true;
        _dailyPacingEnabled =
            prefs.getBool('goals_daily_pacing_enabled') ?? true;
        _autoTagEnabled = prefs.getBool('goals_autotag_enabled') ?? true;
        _exclusiveMode = prefs.getBool('goals_exclusive_mode') ?? true;
        _floatingTimerEnabled =
            prefs.getBool('floating_timer_enabled') ?? false;
        _singleTapAction =
            prefs.getString('floating_single_tap_action') ?? 'quick_log';
        _doubleTapAction =
            prefs.getString('floating_double_tap_action') ?? 'quick_menu';
      });
    }
  }

  Future<void> _toggleSetting(String key, bool val, VoidCallback update) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
    if (key == 'goals_reflection_enabled') {
      await prefs.setBool('targets_session_reflection', val);
      await prefs.setBool('projects_session_reflection', val);
    }
    setState(update);
  }

  Future<void> _toggleFloatingTimer(bool val) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    if (val) {
      final canDraw =
          await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
      if (!canDraw) {
        await _channel.invokeMethod('requestOverlayPermission');
      } else {
        await _channel.invokeMethod('startFloatingTimer');
      }
    } else {
      await _channel.invokeMethod('stopFloatingTimer');
    }
    await prefs.setBool('floating_timer_enabled', val);
    setState(() => _floatingTimerEnabled = val);
  }

  Future<void> _showGesturePicker(
    BuildContext anchorContext, {
    required bool isSingleTap,
  }) async {
    final currentVal = isSingleTap ? _singleTapAction : _doubleTapAction;
    final options = isSingleTap
        ? [
            (
              key: 'quick_log',
              title: 'Quick Log',
              subtitle: 'Haptic instant note entry',
            ),
            (
              key: 'toggle_expand',
              title: 'Expand Controls',
              subtitle: 'Show actions toolbar',
            ),
          ]
        : [
            (
              key: 'quick_menu',
              title: 'Modes Menu',
              subtitle: 'Open quick mode selector',
            ),
            (
              key: 'toggle_expand',
              title: 'Toggle Expand',
              subtitle: 'Show or hide toolbar',
            ),
          ];

    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      renderBox.localToGlobal(Offset.zero) & renderBox.size,
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: widget.p.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.p.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      elevation: 8,
      items: [
        for (final opt in options)
          PopupMenuItem<String>(
            value: opt.key,
            height: opt.subtitle.isNotEmpty ? 50 : 42,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt.title.localized(context),
                        style: TextStyle(
                          color: opt.key == currentVal
                              ? widget.p.accent
                              : widget.p.text,
                          fontSize: 13.5,
                          fontWeight: opt.key == currentVal
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (opt.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          opt.subtitle.localized(context),
                          style: TextStyle(color: widget.p.text3, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                if (opt.key == currentVal) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark,
                    size: 15,
                    color: widget.p.accent,
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    if (selected != null) {
      HapticFeedback.selectionClick();
      final prefs = await SharedPreferences.getInstance();
      if (isSingleTap) {
        await prefs.setString('floating_single_tap_action', selected);
        if (mounted) setState(() => _singleTapAction = selected);
      } else {
        await prefs.setString('floating_double_tap_action', selected);
        if (mounted) setState(() => _doubleTapAction = selected);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      children: [
        const SizedBox(height: 8),

        // 1. Session Reflections & Reviews Group
        SettingsGroup(
          p: p,
          title: 'Review & Reflection'.localized(context),
          insetDividers: true,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Session Reflection'.localized(context),
              subtitle: 'Prompt for key takeaways when completing sessions'
                  .localized(context),
              value: _reflectionEnabled,
              color: p.accent,
              onChanged: (val) => _toggleSetting(
                'goals_reflection_enabled',
                val,
                () => _reflectionEnabled = val,
              ),
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Milestone Celebration'.localized(context),
              subtitle: 'Tactile celebration when completing checkpoints'
                  .localized(context),
              value: _celebrationEnabled,
              color: p.green,
              onChanged: (val) => _toggleSetting(
                'goals_celebration_enabled',
                val,
                () => _celebrationEnabled = val,
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Intentional reflections transform raw tracked duration into actionable knowledge.'
                  .localized(context),
        ),
        const SizedBox(height: 12),

        // 2. Deficit Pacing & Attribution
        SettingsGroup(
          p: p,
          title: 'Pacing & Attribution'.localized(context),
          insetDividers: true,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Daily Deficit Pacing'.localized(context),
              subtitle: 'Calculate daily hours needed before deadline'
                  .localized(context),
              value: _dailyPacingEnabled,
              color: p.orange,
              onChanged: (val) => _toggleSetting(
                'goals_daily_pacing_enabled',
                val,
                () => _dailyPacingEnabled = val,
              ),
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Auto-Tag Attribution'.localized(context),
              subtitle: 'Attach target tag to session moments'.localized(
                context,
              ),
              value: _autoTagEnabled,
              color: p.accent,
              onChanged: (val) => _toggleSetting(
                'goals_autotag_enabled',
                val,
                () => _autoTagEnabled = val,
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Daily pacing computes remaining deficit and suggests realistic hours per day.'
                  .localized(context),
        ),
        const SizedBox(height: 12),

        // 3. Concurrency & Island Overlay
        SettingsGroup(
          p: p,
          title: 'Focus & Overlay'.localized(context),
          insetDividers: true,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Exclusive Session Locking'.localized(context),
              subtitle: 'Focus on active target, pausing other modes'.localized(
                context,
              ),
              value: _exclusiveMode,
              color: p.accent,
              onChanged: (val) => _toggleSetting(
                'goals_exclusive_mode',
                val,
                () => _exclusiveMode = val,
              ),
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Floating Control Pill'.localized(context),
              subtitle:
                  'Always-on floating control pill like iOS AssistiveTouch to start, stop, switch modes, and log moments from any screen without opening notifications. Automatically hides while NoteKar is open and docks into a slim edge line when hidden.'
                      .localized(context),
              value: _floatingTimerEnabled,
              color: p.green,
              onChanged: _toggleFloatingTimer,
            ),
            if (_floatingTimerEnabled) ...[
              Builder(
                builder: (rowCtx) => SettingsRow(
                  p: p,
                  title: 'Single Tap'.localized(context),
                  status: _singleTapAction == 'quick_log'
                      ? 'Quick Log'.localized(context)
                      : 'Expand'.localized(context),
                  rowKind: 'none',
                  color: p.accent,
                  onTap: () => _showGesturePicker(rowCtx, isSingleTap: true),
                ),
              ),
              Builder(
                builder: (rowCtx) => SettingsRow(
                  p: p,
                  title: 'Double Tap'.localized(context),
                  status: _doubleTapAction == 'quick_menu'
                      ? 'Modes Menu'.localized(context)
                      : 'Expand'.localized(context),
                  rowKind: 'none',
                  color: p.accent,
                  onTap: () => _showGesturePicker(rowCtx, isSingleTap: false),
                ),
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Exclusive locking avoids unintentional overlapping across multiple concurrent focus modes.'
                  .localized(context),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
