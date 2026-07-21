import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class CaptureSettingsPage extends StatelessWidget {
  const CaptureSettingsPage({
    super.key,
    required this.p,
    required this.controller,
  });

  final Palette p;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          children: [
            const SizedBox(height: 8),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Require Note on Hold',
                  color: p.accent,
                  value: controller.requireLongPressNote,
                  onChanged: (val) => controller.setRequireLongPressNote(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Prompt for a note when long-pressing primary capture buttons.',
            ),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }
}
