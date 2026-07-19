import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class FeedbackDialog extends StatelessWidget {
  const FeedbackDialog({
    super.key,
    required this.p,
    required this.onOpenLink,
    this.blur = false,
  });

  final Palette p;
  final ValueChanged<String> onOpenLink;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: p,
      title: 'Feedback',
      blur: blur,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsGroup(
            p: p,
            children: [
              SettingsRow(
                p: p,
                icon: Icons.bug_report_rounded,
                title: 'Report a Bug',
                subtitle: 'Something isn\'t working as expected.',
                color: p.red,
                onTap: () {
                  Navigator.pop(context);
                  onOpenLink('$githubIssues/new?labels=bug&template=bug_report.md');
                },
              ),
              SettingsRow(
                p: p,
                icon: Icons.auto_awesome_rounded,
                title: 'Request a Feature',
                subtitle: 'Suggest a new idea for NoteKar.',
                color: p.accent,
                onTap: () {
                  Navigator.pop(context);
                  onOpenLink('$githubIssues/new?labels=enhancement&template=feature_request.md');
                },
              ),
            ],
          ),
          const SizedBox(height: spacing12),
          SettingsPageDescription(
            p: p,
            text: 'Feedback helps NoteKar grow. You can also send an email for direct support.',
          ),
          const SizedBox(height: spacing8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: p.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              Navigator.pop(context);
              onOpenLink(supportEmail);
            },
            child: const Text('Email Support'),
          ),
        ],
      ),
    );
  }
}
