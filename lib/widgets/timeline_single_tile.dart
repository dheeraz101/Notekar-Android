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
    this.compact = false,
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
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isGodMode =
        moment.note.contains('God Mode Unlocked') ||
        moment.note.contains('#godmode');
    final hasNote = moment.note.trim().isNotEmpty;
    final color = momentColor(p, moment.type);

    final tileRadius = BorderRadius.circular(compact ? 9 : 12);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1.5 : 3),
      child: ClipRRect(
        borderRadius: tileRadius,
        child: Dismissible(
          key: ValueKey('single-${moment.id}'),
          direction: isGodMode
              ? DismissDirection.none
              : DismissDirection.horizontal,
          background: Container(
            color: p.accent,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
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
            color: p.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
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
                Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vertical Timeline Rail & Node (Line is never behind the circle or dot)
                SizedBox(
                  width: compact ? 20 : 28,
                  child: Column(
                    children: [
                      // Top rail segment (stops before the node)
                      Expanded(
                        child: isFirst
                            ? const SizedBox()
                            : Center(
                                child: Container(
                                  width: 1.5,
                                  color: p.border.withValues(alpha: 0.5),
                                ),
                              ),
                      ),
                      // Timeline Node (Solid opaque background, completely isolating from line)
                      Container(
                        width: moment.type == 'single' && singleNumber != null
                            ? (compact ? 18 : 22)
                            : (compact ? 9 : 12),
                        height: moment.type == 'single' && singleNumber != null
                            ? (compact ? 18 : 22)
                            : (compact ? 9 : 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isGodMode
                              ? const Color(0xFFFF007A)
                              : p.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isGodMode ? Colors.white : color,
                            width: compact ? 1.2 : 1.5,
                          ),
                        ),
                        child: moment.type == 'single' && singleNumber != null
                            ? Text(
                                singleNumber!.localizedDigits(context),
                                style: TextStyle(
                                  color: color,
                                  fontSize: compact ? 8.5 : 9.5,
                                  fontWeight: FontWeight.w900,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              )
                            : Container(
                                width: compact ? 3.5 : 5,
                                height: compact ? 3.5 : 5,
                                decoration: BoxDecoration(
                                  color: isGodMode ? Colors.white : color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                      // Bottom rail segment (starts below the node)
                      Expanded(
                        child: isLast
                            ? const SizedBox()
                            : Center(
                                child: Container(
                                  width: 1.5,
                                  color: p.border.withValues(alpha: 0.5),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: compact ? 6 : 8),

                // Content Bubble
                Expanded(
                  child: PressableScale(
                    onTap: onTap ?? onEditNote,
                    onLongPress: onLongPress,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 9 : 12,
                        vertical: compact ? 5 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? p.surface3
                            : p.surface2.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(compact ? 9 : 12),
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
                              fontSize: compact ? 11.5 : 12.5,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          SizedBox(width: compact ? 6 : 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: p.text3,
                              fontSize: compact ? 10 : 12,
                            ),
                          ),
                          SizedBox(width: compact ? 6 : 8),
                          Expanded(
                            child: hasNote
                                ? IosEmojiText(
                                    moment.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: p.text2,
                                      fontSize: compact ? 11 : 12,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: onEditNote,
                                    child: Text(
                                      'Tap to add quick note...'.localized(
                                        context,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: p.text3.withValues(alpha: 0.8),
                                        fontSize: compact ? 10.5 : 11.5,
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
                                size: compact ? 12 : 14,
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
      ),
    );
  }
}
