import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Full-page Apple HIG Device Health & Feature Restriction Onboarding Screen.
///
/// Displayed once on update / first launch to give users transparent visibility
/// into how NoteKar's Adaptive Governor calibrates performance, glass blurs,
/// animation FPS, and background polling to their exact device hardware.
class DeviceHealthIntroScreen extends StatefulWidget {
  const DeviceHealthIntroScreen({
    super.key,
    required this.p,
    this.isStandaloneFromSettings = false,
  });

  final Palette p;
  final bool isStandaloneFromSettings;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    bool isStandaloneFromSettings = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DeviceHealthIntroScreen(
          p: p,
          isStandaloneFromSettings: isStandaloneFromSettings,
        ),
      ),
    );
  }

  @override
  State<DeviceHealthIntroScreen> createState() =>
      _DeviceHealthIntroScreenState();
}

class _DeviceHealthIntroScreenState extends State<DeviceHealthIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = AdaptiveEngine();
    final p = widget.p;

    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.gauge, size: 13, color: p.accent),
                        const SizedBox(width: 5),
                        Text(
                          'HARDWARE TELEMETRY'.localized(context),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isStandaloneFromSettings)
                    PressableScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: p.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: p.text2,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Animated Hero Header
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      final t = _pulseController.value;
                      final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.accent.withValues(
                                  alpha: 0.08 + 0.08 * pulse,
                                ),
                              ),
                            ),
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.accent.withValues(alpha: 0.16),
                                border: Border.all(
                                  color: p.accent.withValues(
                                    alpha: 0.35 + 0.35 * pulse,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                CupertinoIcons.heart_circle_fill,
                                size: 36,
                                color: p.accent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Device Health & Adaptation'.localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NoteKar calibrates every animation, blur, and background service to match your hardware profile for maximum smoothness and battery health.'
                        .localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Hardware Specification Summary Pill Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_android_rounded,
                                  size: 16,
                                  color: p.accent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  engine.model,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (engine.isLowEnd ? p.orange : p.green)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${engine.tierLabel} (${engine.targetFps} FPS)',
                                style: TextStyle(
                                  color: engine.isLowEnd ? p.orange : p.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: p.border.withValues(alpha: 0.4),
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _specSubItem(
                                p: p,
                                icon: Icons.memory_rounded,
                                label: 'Processor Cores',
                                value: '${engine.processors} Cores',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: p.border.withValues(alpha: 0.4),
                            ),
                            Expanded(
                              child: _specSubItem(
                                p: p,
                                icon: Icons.storage_rounded,
                                label: 'RAM Capacity',
                                value: engine.ramGb > 0
                                    ? '${engine.ramGb} GB'
                                    : 'Dynamic Heap',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: p.border.withValues(alpha: 0.4),
                            ),
                            Expanded(
                              child: _specSubItem(
                                p: p,
                                icon: CupertinoIcons.layers_alt,
                                label: 'OS Version',
                                value: engine.osVersion,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Title: Feature Restrictions & Allocations
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'FEATURE ADAPTATION BREAKDOWN'.localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  // 1. Gaussian Blur
                  _FeatureAdaptationCard(
                    p: p,
                    icon: CupertinoIcons.sparkles,
                    title: 'System & Dialog Blur',
                    isRestricted: !engine.supportsBlur,
                    statusText: engine.supportsBlur
                        ? 'Full Real-Time Blur'
                        : 'Power-Saving Opaque Glass',
                    explanation: engine.supportsBlur
                        ? 'Your GPU effortlessly processes Gaussian backdrop blurs without frame drops.'
                        : 'GPU backdrop blurs are restricted to eliminate frame stutter and prevent device heating.',
                  ),
                  const SizedBox(height: 10),

                  // 2. Animation Physics
                  _FeatureAdaptationCard(
                    p: p,
                    icon: CupertinoIcons.arrow_2_circlepath_circle,
                    title: 'Spring Animation Curves',
                    isRestricted: engine.tier == PerformanceTier.low,
                    statusText: '${engine.targetFps} FPS Target Curve',
                    explanation: engine.tier == PerformanceTier.high
                        ? 'Full 120 FPS high refresh-rate physics curves active for silky gestures.'
                        : (engine.tier == PerformanceTier.balanced
                              ? 'Balanced 60 FPS spring transitions optimized for smooth battery life.'
                              : 'Lightweight curve transitions active to preserve processor battery budget.'),
                  ),
                  const SizedBox(height: 10),

                  // 3. Visual Particles
                  _FeatureAdaptationCard(
                    p: p,
                    icon: CupertinoIcons.wand_stars,
                    title: 'Particle Celebrations',
                    isRestricted: !engine.enableParticleEffects,
                    statusText: engine.enableParticleEffects
                        ? 'Dynamic Physics Particle Bursts'
                        : 'Lightweight Fade Celebrations',
                    explanation: engine.enableParticleEffects
                        ? 'Goal milestones render interactive particle physics dynamics.'
                        : 'Milestones use lightweight visual celebrations to save memory heap.',
                  ),
                  const SizedBox(height: 10),

                  // 4. Background Polling
                  _FeatureAdaptationCard(
                    p: p,
                    icon: CupertinoIcons.clock,
                    title: 'Background Engine Precision',
                    isRestricted: engine.isLowEnd,
                    statusText: engine.backgroundPollingStatusLabel,
                    explanation: engine.isLowEnd
                        ? 'Task executions are throttled to hourly batches to protect battery life.'
                        : 'Adaptive 15-minute sync intervals maintain up-to-date tracking accuracy.',
                  ),
                  const SizedBox(height: 10),

                  // 5. Tactile Haptics
                  _FeatureAdaptationCard(
                    p: p,
                    icon: CupertinoIcons.hand_point_right,
                    title: 'Sensory Haptics',
                    isRestricted: false,
                    statusText: 'Active & Calibrated',
                    explanation:
                        'Subtle mechanical haptics calibrated for tactile reassurance without excessive motor draw.',
                  ),

                  const SizedBox(height: 24),

                  // Local Guarantee Notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.surface2.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.lock_shield,
                          size: 18,
                          color: p.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'All hardware telemetry is measured 100% locally on your device. Zero data is ever sent to external servers.'
                                .localized(context),
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: p.accent.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.isStandaloneFromSettings
                            ? 'Done'.localized(context)
                            : 'Continue to NoteKar'.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Always accessible anytime in Settings → Diagnostics → Device Health'
                        .localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.text3, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specSubItem({
    required Palette p,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: p.text3),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: p.text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(color: p.text3, fontSize: 9.5),
        ),
      ],
    );
  }
}

class _FeatureAdaptationCard extends StatelessWidget {
  const _FeatureAdaptationCard({
    required this.p,
    required this.icon,
    required this.title,
    required this.isRestricted,
    required this.statusText,
    required this.explanation,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final bool isRestricted;
  final String statusText;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final statusColor = isRestricted ? p.orange : p.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: p.text),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText.localized(context),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isRestricted
                      ? p.orange.withValues(alpha: 0.12)
                      : p.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isRestricted ? 'RESTRICTED' : 'ENABLED',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              explanation.localized(context),
              style: TextStyle(color: p.text2, fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
