import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class TimelineSingleTile extends StatelessWidget {
  const TimelineSingleTile({
    super.key,
    required this.p,
    required this.moment,
    required this.onEditNote,
    required this.onDelete,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.singleNumber,
    this.isFirst = false,
    this.isLast = false,
  });

  final Palette p;
  final Moment moment;
  final VoidCallback onEditNote;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final String? singleNumber;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isGodMode =
        moment.note.contains('God Mode Unlocked') ||
        moment.note.contains('#godmode');
    final hasNote = moment.note.trim().isNotEmpty;
    final color = momentColor(p, moment.type);

    return Dismissible(
      key: ValueKey('single-${moment.id}'),
      direction: isGodMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: p.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Note',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: p.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          AppHaptics.light();
          onEditNote();
          return false;
        } else {
          AppHaptics.heavy();
          onDelete();
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vertical Timeline Rail & Node
              SizedBox(
                width: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Continuous vertical rail line
                    Positioned(
                      top: isFirst ? 14 : 0,
                      bottom: isLast ? 14 : 0,
                      child: Container(
                        width: 1.5,
                        color: p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    // Timeline Node
                    Container(
                      width: moment.type == 'single' && singleNumber != null
                          ? 22
                          : 12,
                      height: moment.type == 'single' && singleNumber != null
                          ? 22
                          : 12,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isGodMode
                            ? const Color(0xFFFF007A)
                            : color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isGodMode ? Colors.white : color,
                          width: 1.5,
                        ),
                      ),
                      child: moment.type == 'single' && singleNumber != null
                          ? Text(
                              singleNumber!.localizedDigits(context),
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            )
                          : Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isGodMode ? Colors.white : color,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Content Bubble
              Expanded(
                child: PressableScale(
                  onTap: onTap ?? onEditNote,
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? p.surface3
                          : p.surface2.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? p.accent.withValues(alpha: 0.4)
                            : p.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          timeOnly(moment.timestamp),
                          style: TextStyle(
                            color: p.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: p.text3, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: hasNote
                              ? IosEmojiText(
                                  moment.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.text2,
                                    fontSize: 12,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: onEditNote,
                                  child: Text(
                                    'Tap to add quick note...'.localized(
                                      context,
                                    ),
                                    style: TextStyle(
                                      color: p.text3.withValues(alpha: 0.8),
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                        ),
                        if (hasNote) ...[
                          const SizedBox(width: 4),
                          PressableScale(
                            onTap: onEditNote,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: p.text3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
