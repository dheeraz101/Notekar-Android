import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';

/// Minimal Apple HIG modal notification announcing unlocked Experimental Builds.
class ExperimentalBuildUnlockedSheet extends StatelessWidget {
  const ExperimentalBuildUnlockedSheet({
    super.key,
    required this.p,
    required this.onNavigateToBuildChoose,
  });

  final Palette p;
  final VoidCallback onNavigateToBuildChoose;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required VoidCallback onNavigateToBuildChoose,
  }) {
    AppHaptics.selection('standard');
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) => ExperimentalBuildUnlockedSheet(
        p: p,
        onNavigateToBuildChoose: onNavigateToBuildChoose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: p.border.withValues(
            alpha: p.name == 'amoled' ? 0.45 : (!p.isDark ? 0.35 : 0.40),
          ),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4.5,
            decoration: BoxDecoration(
              color: p.text3.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),

          // Sparkles emblem
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.sparkles,
                color: Color(0xFFFFD700),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            'Experimental Build Unlocked'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'You have unlocked early access to Developer Experiments. These bleeding-edge builds contain prototype interfaces and upcoming framework architecture.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 22),

          // Primary Button: Navigate to Build Choose
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                AppHaptics.selection('standard');
                Navigator.of(context).pop();
                onNavigateToBuildChoose();
              },
              child: Text(
                'Choose Experimental Build'.localized(context),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Dismiss Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: p.text3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                AppHaptics.selection('standard');
                Navigator.of(context).pop();
              },
              child: Text(
                'Dismiss'.localized(context),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
