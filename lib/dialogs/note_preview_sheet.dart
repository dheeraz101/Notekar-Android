import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';

/// Read-only note preview bottom sheet with full text viewing, copying, and edit action.
class NotePreviewSheet extends StatelessWidget {
  const NotePreviewSheet({
    super.key,
    required this.p,
    required this.note,
    required this.title,
    this.category,
    this.onEdit,
    this.dateStr,
  });

  final Palette p;
  final String note;
  final String title;
  final String? category;
  final VoidCallback? onEdit;
  final String? dateStr;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required String note,
    required String title,
    String? category,
    VoidCallback? onEdit,
    String? dateStr,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => NotePreviewSheet(
        p: p,
        note: note,
        title: title,
        category: category,
        onEdit: onEdit,
        dateStr: dateStr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanNote = note.trim();

    return AppSheet(
      p: p,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category != null || dateStr != null) ...[
            Row(
              children: [
                if (category != null && category!.trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      category!,
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (dateStr != null)
                  Text(
                    dateStr!,
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: spacing12),
          ],

          // Note text card
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 340),
            padding: const EdgeInsets.all(spacing16),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: IosEmojiText(
                        cleanNote.isEmpty ? 'No text in note.' : cleanNote,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: spacing16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text2,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cleanNote));
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                  label: const Text('Copy Note'),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit!();
                    },
                    icon: const Icon(CupertinoIcons.pencil, size: 16),
                    label: const Text(
                      'Edit Note',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
