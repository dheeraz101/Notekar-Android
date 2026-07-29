import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/l10n_utils.dart';

void showSecurityDetailsSheet({
  required BuildContext context,
  required Palette p,
  required bool reduceMotion,
  required bool enableTranslucency,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Security Info',
    pageBuilder: (context, _, _) => AppSheet(
      p: p,
      title: 'Security & Integrity'.localized(context),
      docked: true,
      blur:
          !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
      child: SizedBox(
        width: 410,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: p.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.gpp_good_rounded, color: p.green, size: 32),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Is NoteKar Safe to Use?'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NoteKar is built with maximum user safety, open-source integrity, and dynamic cryptosecurity checks:'
                    .localized(context),
                style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.45),
              ),
              const SizedBox(height: 20),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.check_circle_outline_rounded,
                title: 'Zero Malware & Detections',
                text:
                    'NoteKar is audited and verified clean (0/60+ engine detections) by VirusTotal security scanners on every release compilation.',
              ),
              const SizedBox(height: 12),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.lock_outline_rounded,
                title: 'Hardware-Backed Encryption',
                text:
                    'Databases are sealed with 256-bit AES cryptographic keys generated inside the hardware secure Android Keystore.',
              ),
              const SizedBox(height: 12),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.code_rounded,
                title: 'Auditable Open-Source Code',
                text:
                    'Every line of code is hosted publicly on GitHub. You can audit, review, compile, or fork the app independently.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text('Close'.localized(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showPrivacyDetailsSheet({
  required BuildContext context,
  required Palette p,
  required bool reduceMotion,
  required bool enableTranslucency,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Privacy Info',
    pageBuilder: (context, _, _) => AppSheet(
      p: p,
      title: 'Privacy & Offline Model'.localized(context),
      docked: true,
      blur:
          !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
      child: SizedBox(
        width: 410,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.shield_rounded, color: p.accent, size: 32),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Is NoteKar Private?'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Privacy is not a setting; it is our architecture. NoteKar is designed to operate with zero server connections:'
                    .localized(context),
                style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.45),
              ),
              const SizedBox(height: 20),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.cloud_off_rounded,
                title: '100% Offline Database',
                text:
                    'Your check-ins, habits, and notes are saved directly to local storage. There is no cloud sync, meaning your records never leave this device.',
              ),
              const SizedBox(height: 12),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.track_changes_rounded,
                title: 'No Trackers or Analytics',
                text:
                    'NoteKar contains zero telemetry, tracking SDKs, or commercial analytics. We do not inspect your usage habits or profiling details.',
              ),
              const SizedBox(height: 12),
              _buildInfoDetailRow(
                context: context,
                p: p,
                icon: Icons.key_rounded,
                title: 'Local Control & Decryption',
                text:
                    'You have complete command of your data. You can inspect logs, clean databases, export backups, or wipe all records instantly.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text('Close'.localized(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildInfoDetailRow({
  required BuildContext context,
  required Palette p,
  required IconData icon,
  required String title,
  required String text,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: p.accent, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.localized(context),
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text.localized(context),
              style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    ],
  );
}
