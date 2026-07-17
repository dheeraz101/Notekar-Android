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
    this.showDividers = true,
  });

  final Palette p;
  final List<Widget> children;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (showDividers && i != children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Container(height: 1, color: p.border),
                ),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? selectedGlow(p.accent) : null,
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: p.border),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? p.text : p.text2,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
              ),
              if (status != null)
                SettingsStatusPill(p: p, label: status!, color: p.accent),
            ],
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: p.text2, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: values.entries.map((entry) {
              final active = value == entry.key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onChanged(entry.key),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: active ? p.surface3 : p.surface2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: active ? p.accent : p.border),
                        boxShadow: active ? selectedGlow(p.accent) : null,
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: active ? p.text : p.text2,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: p.text, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                ),
          hintText: 'Search Settings',
          hintStyle: TextStyle(color: p.text3),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
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
    final visibleLabels = {0, 10, 20, 60};
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final value in delayValues)
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: value == activeValue ? p.accent : p.text3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 11,
                      child: visibleLabels.contains(value)
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                delayLabel(value),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: value == activeValue
                                      ? p.accent
                                      : p.text3,
                                  fontSize: 8,
                                  fontWeight: value == activeValue
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DelayStepButton extends StatefulWidget {
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
  State<DelayStepButton> createState() => _DelayStepButtonState();
}

class _DelayStepButtonState extends State<DelayStepButton> {
  bool _pressed = false;
  int _tapPulse = 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled ? widget.p.text : widget.p.text3;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled
          ? () {
              setState(() => _tapPulse++);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 130),
        child: Glass(
          p: widget.p,
          radius: 999,
          blur: widget.blur,
          padding: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.enabled ? widget.p.surface3 : widget.p.surface2,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.enabled
                    ? widget.p.border
                    : widget.p.border.withValues(alpha: 0.45),
              ),
            ),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(_tapPulse),
              tween: Tween(begin: 1.18, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(widget.icon, color: color, size: 20),
            ),
          ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? p.accent.withValues(alpha: 0.12) : p.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? p.accent : p.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surface3,
                shape: BoxShape.circle,
                border: Border.all(color: active ? p.accent : p.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Transform.scale(
                scale: 1.18,
                child: Image.asset(
                  asset,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  cacheWidth: 96,
                  cacheHeight: 96,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (active) Icon(Icons.check_rounded, color: p.accent, size: 18),
          ],
        ),
      ),
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
    required this.color,
    this.onTap,
    this.active = false,
    this.status,
    this.statusColor,
    this.highlight,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool active;
  final String? status;
  final Color? statusColor;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      enabled: onTap != null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child:
                  title == 'Check for Update' &&
                      subtitle.toLowerCase().contains('checking')
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      builder: (_, value, child) => Transform.rotate(
                        angle: value * math.pi * 2,
                        child: child,
                      ),
                      onEnd: () {},
                      child: Icon(icon, color: color, size: 18),
                    )
                  : Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    text: title,
                    query: highlight,
                    baseStyle: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                    ),
                    highlightStyle: TextStyle(
                      color: p.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: active ? color : p.text2,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SettingsStatusPill(
                  p: p,
                  label: status!,
                  color: statusColor ?? color,
                ),
              ),
            ],
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(Icons.chevron_right_rounded, color: p.text3),
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.disabledMessage,
    this.onDisabledTap,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final String? disabledMessage;
  final ValueChanged<String>? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final switchColor = p.accent;
    return PressableScale(
      onTap: () {
        if (!enabled) {
          final message = disabledMessage;
          if (message != null) onDisabledTap?.call(message);
          return;
        }
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (enabled && value ? switchColor : p.text3).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: enabled && value ? switchColor : p.text2,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? p.text : p.text2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.only(top: 3),
              width: 51,
              height: 31,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: enabled && value ? switchColor : p.surface3,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: enabled && value ? switchColor : p.border,
                ),
              ),
              child: Align(
                alignment: enabled && value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    final paint = Paint()
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
    final path = Path()
      ..moveTo(9, 19)
      ..cubicTo(4.5, 20.4, 4.5, 16.4, 3, 16)
      ..moveTo(15, 22)
      ..lineTo(15, 18.5)
      ..cubicTo(15, 17.5, 14.7, 16.7, 14.1, 16.2)
      ..cubicTo(17.1, 15.9, 20.1, 14.7, 20.1, 9.4)
      ..cubicTo(20.1, 8, 19.6, 6.8, 18.7, 5.8)
      ..cubicTo(19, 4.8, 18.9, 3.6, 18.6, 2.3)
      ..cubicTo(18.6, 2.3, 17.5, 2, 15, 3.7)
      ..cubicTo(13, 3.1, 10.5, 3.1, 8.5, 3.7)
      ..cubicTo(6, 2, 4.9, 2.3, 4.9, 2.3)
      ..cubicTo(4.6, 3.6, 4.5, 4.8, 4.8, 5.8)
      ..cubicTo(3.9, 6.8, 3.4, 8, 3.4, 9.4)
      ..cubicTo(3.4, 14.7, 6.4, 15.9, 9.4, 16.2)
      ..cubicTo(8.8, 16.8, 8.5, 17.5, 8.5, 18.5)
      ..lineTo(8.5, 22);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GitHubMarkPainter oldDelegate) {
    return oldDelegate.color != color;
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
      radius: 12,
      blur: blur,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: p.text2, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
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
                  width: 50,
                  height: 50,
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
                    width: active ? 28 : 30,
                    height: active ? 28 : 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
