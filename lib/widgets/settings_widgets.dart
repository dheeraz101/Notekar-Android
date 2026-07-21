import 'package:flutter/gestures.dart';
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
    this.description,
    this.showDividers = true,
    this.insetDividers = false,
  });

  final Palette p;
  final List<Widget> children;
  final String? title;
  final String? description;
  final bool showDividers;
  final bool insetDividers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              description!,
              style: TextStyle(
                color: p.text2,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(32), // iOS 26 High-Radius style
            border: p.name == 'amoled' ? Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8) : null,
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (showDividers && i < children.length - 1)
                  Divider(
                    height: 0.5,
                    color: p.border,
                    indent: insetDividers ? 64 : 0, // Inset to align right after squircle icon
                  ),
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
    this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.color,
    this.status,
    this.active = false,
    this.highlight,
    this.trailing,
    this.rowKind = 'nav', // 'nav' | 'link' | 'popup'
  });

  final Palette p;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;
  final String? status;
  final bool active;
  final String? highlight;
  final Widget? trailing;
  /// 'nav'   → chevron_right (default internal navigation)
  /// 'link'  → open_in_new  (opens an external URL)
  /// 'popup' → info_outline  (opens an inline popup/dialog)
  final String rowKind;

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? p.accent;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final hasIcon = icon != null;

    // Trailing indicator icon chosen by rowKind
    Widget? trailingIndicator;
    if (onTap != null && trailing == null) {
      switch (rowKind) {
        case 'link':
          trailingIndicator = Icon(Icons.open_in_new_rounded, color: p.text3, size: 16);
        case 'popup':
          trailingIndicator = Icon(Icons.info_outline_rounded, color: p.text3, size: 18);
        default:
          trailingIndicator = Icon(Icons.chevron_right_rounded, color: p.text3, size: 20);
      }
    }

    return PressableScale(
      enabled: onTap != null,
      onTap: () {
        NotekarHaptics.selection('standard');
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hasIcon ? 16 : 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? rowColor.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          // Always center so trailing tick/chevron is always vertically centered
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rowColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: rowColor, size: 16),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    text: title,
                    query: highlight,
                    baseStyle: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w600,
                      fontVariations: const [FontVariation('wght', 600)],
                      fontSize: hasSubtitle ? 14 : 15,
                    ),
                    highlightStyle: TextStyle(
                      color: rowColor,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation('wght', 700)],
                      backgroundColor: rowColor.withValues(alpha: 0.12),
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.text2, fontSize: 12, height: 1.3),
                    ),
                  ],
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Text(
                status!,
                style: TextStyle(
                  color: p.text2,
                  fontSize: hasSubtitle ? 14 : 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (trailingIndicator != null) ...[
              const SizedBox(width: 6),
              trailingIndicator,
            ],
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
    this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
    this.status,
    this.blur = false,
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;
  final String? status;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    return Glass(
      p: p,
      radius: 32, // iOS 26 style
      blur: blur,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w800,
                        fontSize: hasSubtitle ? 14 : 15,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(color: p.text2, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (status != null)
                Text(
                  status!,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(10),
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
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.color,
    this.enabled = true,
    this.disabledMessage,
    this.onDisabledTap,
  });

  final Palette p;
  final IconData? icon;
  final String title;
  final String? subtitle;
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
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final hasIcon = widget.icon != null;

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
        padding: EdgeInsets.symmetric(horizontal: hasIcon ? 16 : 20, vertical: 12),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: hasSubtitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              Container(
                width: 32,
                height: 32,
                margin: hasSubtitle ? const EdgeInsets.only(top: 9) : null,
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
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSubtitle) const SizedBox(height: 3),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: enabled ? p.text : p.text2,
                      fontWeight: FontWeight.w600,
                      fontVariations: const [FontVariation('wght', 600)],
                      fontSize: hasSubtitle ? 14 : 15,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: enabled ? p.text2 : p.text3,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: EdgeInsets.only(top: hasSubtitle ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 62, // Refined HIG width
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: enabled && value ? switchColor : p.surface3,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: enabled && value ? switchColor : p.border,
                  ),
                ),
                child: RepaintBoundary(
                  child: Stack(
                    children: [
                      // "On" Indicator (Accessibility style)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: value ? 1.0 : 0.0,
                        child: Align(
                          alignment: const Alignment(-0.55, 0),
                          child: Container(
                            width: 1.8,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment:
                            value ? Alignment.centerRight : Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _stretchController,
                          builder: (context, child) {
                            // Fluid "pill" thumb stretch animation
                            final stretch = _stretchController.value * 10;
                            return Container(
                              width: 34 + stretch, // Refined base thumb width 34
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
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
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(32), // iOS 26 style
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
                border: Border.all(color: p.border, width: 0.5),
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
                asset,
                cacheWidth: 144,
                cacheHeight: 144,
                filterQuality: FilterQuality.medium,
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
    required this.value,
    required this.onChanged,
    this.blur = false,
  });

  final Palette p;
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
      radius: 32,
      blur: blur,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: _choices.map((entry) {
            final key = entry.$1;
            final color = entry.$2;
            final active = value == key;
            return GestureDetector(
              onTap: () => onChanged(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 64, // Increased to fit card
                height: 64,
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
                  width: active ? 38 : 42,
                  height: active ? 38 : 42,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26), // Increased by 2px for final exact visual alignment
      child: Row(
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
      ),
    );
  }
}

class SettingsPageSubtitle extends StatelessWidget {
  const SettingsPageSubtitle({
    super.key,
    required this.p,
    required this.text,
  });

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Text(
        text,
        style: TextStyle(
          color: p.text2,
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w400,
          fontVariations: const [FontVariation('wght', 400)],
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class SettingsPageDescription extends StatelessWidget {
  const SettingsPageDescription({
    super.key,
    required this.p,
    required this.text,
    this.bottomPadding = 16.0,
  });

  final Palette p;
  final String text;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, bottomPadding), // Tight 5px gap below settings card
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w400,
                fontVariations: const [FontVariation('wght', 400)],
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsBetaNote extends StatelessWidget {
  const SettingsBetaNote({
    super.key,
    required this.p,
    required this.text,
    required this.onLearnMore,
    this.bottomPadding = 16.0,
  });

  final Palette p;
  final String text;
  final VoidCallback onLearnMore;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.5), // Precisely aligned with 13px Inter cap-height
            child: Icon(
              Icons.info_outline_rounded,
              color: p.text3.withValues(alpha: 0.6),
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                // Baseline style for the entire rich text block
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  fontVariations: const [FontVariation('wght', 400)],
                  letterSpacing: -0.05,
                ),
                children: [
                  TextSpan(text: '$text '),
                  TextSpan(
                    text: 'Learn More',
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      // Force identical font properties to description
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      fontVariations: [FontVariation('wght', 400)],
                      decoration: TextDecoration.none,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onLearnMore,
                  ),
                ],
              ),
            ),
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
    this.focusNode,
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32), // iOS 26 High-Radius style
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        style: TextStyle(color: p.text, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          suffixIcon:
              controller.text.isEmpty
                  ? null
                  : IconButton(
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                  ),
          suffixIconConstraints: const BoxConstraints(minWidth: 32),
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
    required this.onOpenLink,
  });

  final Palette p;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            'NoteKar',
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OPEN SOURCE',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: p.text3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MIT LICENSE',
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              style: TextStyle(color: p.text2, fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: 'Built by '),
                TextSpan(
                  text: 'YABP',
                  style: TextStyle(
                    color: p.accent,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationColor: p.accent.withValues(alpha: 0.3),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => onOpenLink(yabpSite),
                ),
                const TextSpan(
                  text: ' as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Divider(color: p.border.withValues(alpha: 0.5), height: 1, indent: 40, endIndent: 40),
          const SizedBox(height: 20),
          Text(
            '© 2026 NoteKar',
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version $appVersion ($appBuildNumber)',
            style: TextStyle(
              color: p.text3.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
