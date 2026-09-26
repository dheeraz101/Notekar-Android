import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/goals_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

/// Standalone Settings page for managing Targets & Goals.
class GoalsSettingsPage extends StatelessWidget {
  const GoalsSettingsPage({super.key, required this.p, required this.moments});

  final Palette p;
  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Configure intentional target allocations across week, month, year, or all-time, tracking invested duration vs remaining deficit.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        GoalsContentView(
          p: p,
          moments: moments,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
