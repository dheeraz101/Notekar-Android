import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.p,
    required this.children,
    this.title,
    this.showDividers = true,
  });

  final Palette p;
  final List<Widget> children;
  final String? title;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8), // Official iOS Title padding
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                fontWeight: FontWeight.w400, // iOS titles are lighter but uppercase
                letterSpacing: 0.2,
              ),
            ),
          ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(10), // Tighter iOS 17 radius
            border: Border.all(color: p.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (showDividers && i < children.length - 1)
                  Divider(height: 0.5, color: p.border), // iOS dividers touch both sides in inset grouped
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.color,
    this.status,
    this.active = false,
    this.highlight,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;
  final String? status;
  final bool active;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? p.accent;

    return PressableScale(
      enabled: onTap != null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? rowColor.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 9), // Synchronized with title
              decoration: BoxDecoration(
                color: rowColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: rowColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3), // Visual center-line sync
                  HighlightedText(
                    text: title,
                    query: highlight,
                    baseStyle: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                    ),
                    highlightStyle: TextStyle(
                      color: rowColor,
                      fontWeight: FontWeight.w900,
                      backgroundColor: rowColor.withValues(alpha: 0.12),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text2, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SettingsStatusPill(p: p, label: status!, color: rowColor),
              ),
            ],
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(Icons.chevron_right_rounded, color: p.text3, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class SegmentedSetting extends StatelessWidget {
  const SegmentedSetting({
    super.key,
    required this.p,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
    this.status,
    this.blur = false,
  });

  final Palette p;
  final String title;
  final String subtitle;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;
  final String? status;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return Glass(
      p: p,
      radius: 12,
      blur: blur,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (status != null)
                SettingsStatusPill(p: p, label: status!, color: p.accent),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: values.entries.map((e) {
                final active = e.key == value;
                return Expanded(
                  child: PressableScale(
                    onTap: () => onChanged(e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? p.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: active
                            ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: active ? p.text : p.text2,
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSwitchRow extends StatefulWidget {
  const SettingsSwitchRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.color,
    this.enabled = true,
    this.disabledMessage,
    this.onDisabledTap,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;
  final bool enabled;
  final String? disabledMessage;
  final ValueChanged<String>? onDisabledTap;

  @override
  State<SettingsSwitchRow> createState() => _SettingsSwitchRowState();
}

class _SettingsSwitchRowState extends State<SettingsSwitchRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stretchController;

  @override
  void initState() {
    super.initState();
    _stretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _stretchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final switchColor = widget.color ?? p.accent;
    final enabled = widget.enabled;
    final value = widget.value;

    return GestureDetector(
      onTapDown: (_) {
        _stretchController.forward();
      },
      onTapUp: (_) {
        _stretchController.reverse();
      },
      onTapCancel: () {
        _stretchController.reverse();
      },
      onTap: () {
        if (!enabled) {
          final message = widget.disabledMessage;
          if (message != null) widget.onDisabledTap?.call(message);
          return;
        }
        widget.onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 9), // Synchronized
              decoration: BoxDecoration(
                color: (enabled && value ? switchColor : p.text3).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: enabled && value ? switchColor : p.text2,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3), // Center-line sync
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: enabled ? p.text : p.text2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: enabled ? p.text2 : p.text3,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(top: 3),
              width: 60,
              height: 32,
              padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: enabled && value ? switchColor : p.surface3,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: enabled && value ? switchColor : p.border,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment:
                          value ? Alignment.centerRight : Alignment.centerLeft,
                      child: AnimatedBuilder(
                        animation: _stretchController,
                        builder: (context, child) {
                          final stretch = _stretchController.value * 12;
                          return Container(
                            width: 32 + stretch,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeChoice extends StatelessWidget {
  const ThemeChoice({
    super.key,
    required this.p,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? p.accent : p.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: p.border),
              ),
              child: active
                  ? Icon(Icons.check_rounded, color: p.accent, size: 18)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? p.text : p.text2,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppIconChoice extends StatelessWidget {
  const AppIconChoice({
    super.key,
    required this.p,
    required this.label,
    required this.asset,
    required this.active,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final String asset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  active ? p.accent.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active ? p.accent : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                asset, // Direct asset path from map
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: p.surface3,
                  child: Icon(Icons.broken_image_rounded, color: p.text3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2), // Tight visual iOS spacing
          Text(
            label,
            style: TextStyle(
              color: active ? p.text : p.text2,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorChoiceSetting extends StatelessWidget {
  const ColorChoiceSetting({
    super.key,
    required this.p,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.blur = false,
  });

  final Palette p;
  final String title;
  final String subtitle;
  final String value;
  final ValueChanged<String> onChanged;
  final bool blur;

  static const _choices = [
    ('blue', Color(0xFF0A84FF)),
    ('green', Color(0xFF30D158)),
    ('purple', Color(0xFFBF5AF2)),
    ('pink', Color(0xFFFF6B8A)),
    ('orange', Color(0xFFFF9F0A)),
    ('graphite', Color(0xFF8E8E93)),
    ('teal', Color(0xFF40C8C0)),
    ('mint', Color(0xFF63D7A5)),
    ('cyan', Color(0xFF64D2FF)),
    ('indigo', Color(0xFF7D89FF)),
    ('violet', Color(0xFFA78BFA)),
    ('lavender', Color(0xFFC4B5FD)),
    ('rose', Color(0xFFFF8FAB)),
    ('coral', Color(0xFFFF8A7A)),
    ('amber', Color(0xFFFFC857)),
    ('sand', Color(0xFFD6B86A)),
    ('sage', Color(0xFFA3B18A)),
    ('olive', Color(0xFFB6C667)),
    ('slate', Color(0xFF9BAAB3)),
    ('brown', Color(0xFFB08A78)),
  ];

  @override
  Widget build(BuildContext context) {
    return Glass(
      p: p,
      radius: 16,
      blur: blur,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _choices.map((entry) {
                final key = entry.$1;
                final color = entry.$2;
                final active = value == key;
                return GestureDetector(
                  onTap: () => onChanged(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? color.withValues(alpha: 0.18) : p.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? color : p.border,
                        width: active ? 2.5 : 1,
                      ),
                      boxShadow: active
                          ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ]
                          : null,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: active ? 32 : 36,
                      height: active ? 32 : 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DelayStepButton extends StatelessWidget {
  const DelayStepButton({
    super.key,
    required this.p,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.blur = false,
  });

  final Palette p;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: enabled,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: p.surface3,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
        ),
        child: Icon(icon, color: enabled ? p.accent : p.text3, size: 20),
      ),
    );
  }
}

class SliderScale extends StatelessWidget {
  const SliderScale({super.key, required this.p, required this.activeValue});
  final Palette p;
  final int activeValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final val in delayValues)
          Container(
            width: 2,
            height: 4,
            color:
                val == activeValue ? p.accent : p.text3.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class SettingsSearchBox extends StatelessWidget {
  const SettingsSearchBox({
    super.key,
    required this.p,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: p.text, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          suffixIcon:
              controller.text.isEmpty
                  ? null
                  : IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                  ),
          hintText: 'Search settings',
          hintStyle: TextStyle(color: p.text3),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class SettingsAboutBlock extends StatelessWidget {
  const SettingsAboutBlock({
    super.key,
    required this.p,
    required this.onEmailTap,
    required this.onGitHubTap,
    required this.onVersionLongPress,
  });

  final Palette p;
  final VoidCallback onEmailTap;
  final VoidCallback onGitHubTap;
  final VoidCallback onVersionLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Text(
            'NoteKar',
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Built by YABP as a small, offline-first timestamp logger for real work: quick taps, focused notes, private local storage, and exports developers can inspect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialCircleButton(
                p: p,
                icon: Icons.mail_rounded,
                onTap: onEmailTap,
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onLongPress: onVersionLongPress,
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: p.surface3,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.border),
                  ),
                  child: Text(
                    'v$appVersion ($appBuildNumber)',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SocialCircleButton(
                p: p,
                icon: Icons.code_rounded,
                onTap: onGitHubTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Build date $appBuildDate',
            style: TextStyle(color: p.text3, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SocialCircleButton extends StatelessWidget {
  const SocialCircleButton({
    super.key,
    required this.p,
    required this.icon,
    required this.onTap,
  });

  final Palette p;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: p.name == 'light' ? Colors.white : p.surface3,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: p.name == 'light' ? 0.08 : 0.22,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: icon == Icons.code_rounded
            ? CustomPaint(painter: GitHubMarkPainter(color: p.text))
            : Icon(icon, color: p.accent, size: 18),
      ),
    );
  }
}

class GitHubMarkPainter extends CustomPainter {
  GitHubMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.75
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final scale = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);
    final path =
        Path()
          ..moveTo(12, 2)
          ..cubicTo(6.47, 2, 2, 6.47, 2, 12)
          ..cubicTo(2, 16.41, 4.87, 20.17, 8.84, 21.5)
          ..cubicTo(9.34, 21.58, 9.5, 21.27, 9.5, 21.0)
          ..cubicTo(9.5, 20.77, 9.5, 20.14, 9.5, 19.31)
          ..cubicTo(6.73, 19.91, 6.14, 17.97, 6.14, 17.97)
          ..cubicTo(5.68, 16.81, 5.03, 16.5, 5.03, 16.5)
          ..cubicTo(4.12, 15.88, 5.1, 15.9, 5.1, 15.9)
          ..cubicTo(6.1, 15.97, 6.63, 16.93, 6.63, 16.93)
          ..cubicTo(7.5, 18.45, 8.97, 18.01, 9.54, 17.76)
          ..cubicTo(9.63, 17.11, 9.89, 16.67, 10.17, 16.42)
          ..cubicTo(7.95, 16.17, 5.62, 15.31, 5.62, 11.5)
          ..cubicTo(5.62, 10.41, 6, 9.51, 6.63, 8.8)
          ..cubicTo(6.52, 8.55, 6.17, 7.53, 6.73, 6.15)
          ..cubicTo(6.73, 6.15, 7.58, 5.88, 9.5, 7.17)
          ..cubicTo(10.3, 6.92, 11.15, 6.8, 12, 6.8)
          ..cubicTo(12.85, 6.8, 13.7, 6.92, 14.5, 7.17)
          ..cubicTo(16.42, 5.88, 17.27, 6.15, 17.27, 6.15)
          ..cubicTo(17.83, 7.53, 17.48, 8.55, 17.37, 8.8)
          ..cubicTo(18, 9.51, 18.38, 10.41, 18.38, 11.5)
          ..cubicTo(18.38, 15.32, 16.04, 16.17, 13.81, 16.42)
          ..cubicTo(14.17, 16.72, 14.5, 17.33, 14.5, 18.26)
          ..cubicTo(14.5, 19.6, 14.5, 20.68, 14.5, 21.0)
          ..cubicTo(14.5, 21.27, 14.66, 21.59, 15.17, 21.5)
          ..cubicTo(19.14, 20.16, 22, 16.42, 22, 12)
          ..cubicTo(22, 6.47, 17.53, 2, 12, 2)
          ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
