import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

/// Reusable Apple HIG Cupertino Date & Time picker bottom sheet.
/// Conforms to native iOS modal presentation guidelines and can be reused app-wide.
class AppDatePickerSheet extends StatelessWidget {
  const AppDatePickerSheet({
    super.key,
    required this.p,
    required this.title,
    required this.initialDateTime,
    required this.mode,
    this.minimumDate,
    this.maximumDate,
  });

  final Palette p;
  final String title;
  final DateTime initialDateTime;
  final CupertinoDatePickerMode mode;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  /// Shows the Cupertino date/time picker bottom sheet and returns the selected [DateTime].
  static Future<DateTime?> show(
    BuildContext context, {
    required Palette p,
    required String title,
    required DateTime initialDateTime,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) {
    return showCupertinoModalPopup<DateTime>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (BuildContext sheetContext) {
        return AppDatePickerSheet(
          p: p,
          title: title,
          initialDateTime: initialDateTime,
          mode: mode,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime selected = initialDateTime;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: TextStyle(
          color: p.text,
          decoration: TextDecoration.none,
          fontFamily: '.SF Pro Text',
        ),
        child: Container(
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: p.border.withValues(alpha: 0.6),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Apple modal grab handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: p.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Top Toolbar (Cancel, Title, Done)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, null);
                        },
                        child: Text(
                          'Cancel'.localized(context),
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Text(
                        title.localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context, selected);
                        },
                        child: Text(
                          'Done'.localized(context),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: p.border.withValues(alpha: 0.4),
                ),

                // Native Cupertino Wheel Picker
                SizedBox(
                  height: 220,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: p.isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: p.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: mode,
                      initialDateTime: initialDateTime,
                      minimumDate: minimumDate,
                      maximumDate: maximumDate,
                      onDateTimeChanged: (DateTime newDateTime) {
                        HapticFeedback.selectionClick();
                        selected = newDateTime;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
