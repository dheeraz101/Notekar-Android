import 'package:flutter/cupertino.dart';
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
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: p.name == 'light' ? Brightness.light : Brightness.dark,
          primaryColor: p.accent,
        ),
        child: CupertinoAlertDialog(
          title: Text(title.localized(dialogContext)),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message.localized(dialogContext)),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancel'.localized(dialogContext)),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(confirmLabel.localized(dialogContext)),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
