import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class WelcomeSheet extends StatefulWidget {
  const WelcomeSheet({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    this.blur = false,
    required this.onTheme,
    required this.onDefaultMode,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final bool blur;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;

  @override
  State<WelcomeSheet> createState() => _WelcomeSheetState();
}

class _WelcomeSheetState extends State<WelcomeSheet> {
  late String theme;
  late String defaultMode;

  @override
  void initState() {
    super.initState();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteFor(theme);
    return AppSheet(
      p: p,
      title: 'NoteKar',
      docked: true,
      blur: widget.blur,
      child: SizedBox(
        width: 430,
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'A quiet, offline-first way to mark moments the second they happen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: spacing8),
            Text(
              'No account. No clutter. Just fast logging, notes, history, and backup when you need them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: spacing16),
            Row(
              children: [
                for (final option in const ['dark', 'light']) ...[
                  Expanded(
                    child: ThemeChoice(
                      p: p,
                      label: option == 'dark' ? 'Dark' : 'Light',
                      active: theme == option,
                      color: option == 'dark'
                          ? Colors.black
                          : const Color(0xFFF2F2F7),
                      onTap: () {
                        setState(() => theme = option);
                        widget.onTheme(option);
                      },
                    ),
                  ),
                  if (option == 'dark') const SizedBox(width: spacing8),
                ],
              ],
            ),
            const SizedBox(height: spacing24),
            SegmentedSetting(
              p: p,
              title: 'Startup Mode',
              subtitle: 'Choose how NoteKar starts when you open it',
              value: defaultMode,
              blur: widget.blur,
              values: const {'single': 'Single', 'two-way': 'Two-Way'},
              onChanged: (value) {
                setState(() => defaultMode = value);
                widget.onDefaultMode(value);
              },
            ),
            const SizedBox(height: spacing12),
            SettingsGroup(
              p: p,
              children: [
                WelcomeRow(
                  p: p,
                  icon: Icons.touch_app_rounded,
                  title: 'Tap to save',
                  text: 'Log a moment instantly from the main screen.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.swap_vert_rounded,
                  title: 'Track starts and stops',
                  text: 'Use Single or Two-Way mode based on your flow.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.edit_note_rounded,
                  title: 'Hold for notes',
                  text: 'Attach context without slowing the app down.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.history_rounded,
                  title: 'Review and export',
                  text: 'Filter history, compare moments, export, or backup.',
                ),
              ],
            ),
            const SizedBox(height: spacing16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Logging'),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeRow extends StatelessWidget {
  const WelcomeRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: p.text2, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
