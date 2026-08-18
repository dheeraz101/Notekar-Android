import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

Future<bool> showFeatureConflictDialog(
  BuildContext context, {
  required Palette p,
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.info_outline_rounded,
  Color? iconColor,
}) async {
  HapticFeedback.lightImpact();
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      final effectiveIconColor = iconColor ?? p.accent;

      return PopScope(
        canPop: true,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 320,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: p.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Badge
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: effectiveIconColor.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: effectiveIconColor, size: 26),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      title.localized(dialogContext),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description / Message
                    Text(
                      message.localized(dialogContext),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 13.5,
                        height: 1.45,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions Row
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: p.text2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: Text(
                              'Cancel'.localized(dialogContext),
                              style: TextStyle(
                                color: p.text2,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Confirm & Resolve Button
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: Text(
                              confirmLabel.localized(dialogContext),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
