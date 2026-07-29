import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppIconsSettingsPage extends StatelessWidget {
  const AppIconsSettingsPage({
    super.key,
    required this.p,
    required this.appIconStyle,
    required this.onAppIconStyleChanged,
  });

  final Palette p;
  final String appIconStyle;
  final ValueChanged<String> onAppIconStyleChanged;

  @override
  Widget build(BuildContext context) {
    const icons = {
      'default': ('Default', 'icon-maskable-512.png'),
      'black': ('Black', 'app_icons/black.png'),
      'blue': ('Blue', 'app_icons/blue.png'),
      'gold': ('Gold', 'app_icons/gold.png'),
      'green': ('Green', 'app_icons/green.png'),
      'orange': ('Orange', 'app_icons/orange.png'),
      'red': ('Red', 'app_icons/red.png'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing12),
        SizedBox(
          height: 125, // Gallery height
          child: RepaintBoundary(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: spacing16),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final entry = icons.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: AppIconChoice(
                    p: p,
                    label: entry.value.$1,
                    asset: entry.value.$2,
                    active: appIconStyle == entry.key,
                    onTap: () {
                      if (entry.key == appIconStyle) return;
                      NotekarHaptics.selection('standard');
                      onAppIconStyleChanged(entry.key);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        SettingsPageDescription(
          p: p,
          showIcon: true,
          text:
              'App Icons change the Android launcher icon. Note: Some launchers may take a few seconds to update.'
                  .localized(context),
        ),
      ],
    );
  }
}
