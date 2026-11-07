import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

/// Apple HIG & BitChord-inspired Sliding Pill Segmented Control.
///
/// Features:
/// - Track in Apple tertiary fill (0.12 light / 0.24 dark) with hairline border
/// - Lifted squircle pill (White on light, #636366 / lifted surface on dark)
/// - Single-pass spring motion (220ms, damping: 0.78)
/// - Selection click haptic on segment change
/// - Accessible semantics (selected, button role, label) for TalkBack / screen readers
/// - Resilience under unconstrained horizontal flex/scroll layouts (infinite width safety)
/// - Scaled height adaptation for accessibility font scaling
class NkPillSegmentedControl<T> extends StatelessWidget {
  const NkPillSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.labelBuilder,
    this.enabled = true,
    this.padding = const EdgeInsets.all(4.0),
    this.height = 38.0,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T value)? labelBuilder;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final p = context.palette;
    final isLight = !p.isDark;

    // Apple tertiary fill
    final trackColor = isLight
        ? const Color(0xFF767680).withValues(alpha: 0.12)
        : const Color(0xFF767680).withValues(alpha: 0.24);

    final pillColor = isLight ? Colors.white : const Color(0xFF636366);
    final selectedTextColor = isLight ? Colors.black : Colors.white;
    final unselectedTextColor = p.text3;

    final rawIndex = options.indexOf(selected);
    final hasSelection = rawIndex >= 0;
    final selectedIndex = hasSelection ? rawIndex : 0;

    final textScaler = MediaQuery.textScalerOf(context);
    final scaledHeight = (height * textScaler.scale(1.0)).clamp(height, 56.0);

    return Container(
      height: scaledHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(scaledHeight / 2),
        border: Border.all(
          color: p.border.withValues(alpha: isLight ? 0.3 : 0.2),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = options.length;
          // Guard against unconstrained width in horizontal scroll views or rows
          final effectiveWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : math.max(120.0, count * 96.0);
          final segmentWidth = effectiveWidth / count;

          return SizedBox(
            width: constraints.maxWidth.isFinite ? null : effectiveWidth,
            child: Stack(
              children: [
                // Sliding Selection Pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: const Cubic(0.25, 0.9, 0.35, 1.0),
                  left: selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: hasSelection ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(
                          (scaledHeight - 8) / 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isLight ? 0.08 : 0.22,
                            ),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1.5),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 1.0,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Segment Labels Row
                Row(
                  children: [
                    for (int i = 0; i < count; i++) ...[
                      Expanded(
                        child: Semantics(
                          selected: i == rawIndex,
                          button: true,
                          enabled: enabled,
                          label: labelBuilder != null
                              ? labelBuilder!(options[i])
                              : options[i].toString(),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: enabled
                                ? () {
                                    if (options[i] != selected) {
                                      AppHaptics.select();
                                      onChanged(options[i]);
                                    }
                                  }
                                : null,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: i == selectedIndex && hasSelection
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  letterSpacing: 0.05,
                                  color: i == selectedIndex && hasSelection
                                      ? selectedTextColor
                                      : unselectedTextColor,
                                ),
                                child: Text(
                                  labelBuilder != null
                                      ? labelBuilder!(options[i])
                                      : options[i].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
