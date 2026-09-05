import 'package:flutter/material.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class TimelineSessionCard extends StatelessWidget {
  const TimelineSessionCard({
    super.key,
    required this.p,
    required this.session,
    required this.onEditNote,
    required this.onDeleteSession,
    this.onTapCard,
    this.onLongPressCard,
    this.selected = false,
  });

  final Palette p;
  final TimelineSessionItem session;
  final VoidCallback onEditNote;
  final VoidCallback onDeleteSession;
  final VoidCallback? onTapCard;
  final VoidCallback? onLongPressCard;
  final bool selected;

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes <= 0) return '< 1m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = session.isOngoing;
    final durationStr = _formatDuration(session.duration);
    final hasNote = session.note.isNotEmpty;

    return Dismissible(
      key: ValueKey(
        'session-${session.inMoment.id}-${session.outMoment?.id ?? 'live'}',
      ),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: p.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Note',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
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
          onDeleteSession();
          return false;
        }
      },
      child: PressableScale(
        onTap: onTapCard ?? onEditNote,
        onLongPress: onLongPressCard,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? p.surface3 : p.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? p.accent.withValues(alpha: 0.5)
                  : isOngoing
                  ? p.green.withValues(alpha: 0.4)
                  : p.border.withValues(alpha: 0.6),
              width: isOngoing || selected ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isOngoing)
                BoxShadow(
                  color: p.green.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Interval Row: Start ── Duration ── End
              Row(
                children: [
                  // Start node (Emerald)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: p.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timeOnly(session.startTimestamp),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),

                  // Duration Connector or Live Activity Pill
                  if (isOngoing) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: p.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: p.green.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: p.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE $durationStr',
                            style: TextStyle(
                              color: p.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                height: 1,
                                color: p.border.withValues(alpha: 0.6),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: p.surface3,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: p.border.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                durationStr,
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 1,
                                color: p.border.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timeOnly(session.endTimestamp!),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: p.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Note Content / Tap to Add Note area
              GestureDetector(
                onTap: onEditNote,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: p.border.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasNote
                            ? Icons.notes_rounded
                            : Icons.add_comment_outlined,
                        size: 14,
                        color: hasNote ? p.accent : p.text3,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: hasNote
                            ? IosEmojiText(
                                session.note,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 12.5,
                                  height: 1.3,
                                ),
                              )
                            : Text(
                                'Tap to add session note...'.localized(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text3,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: p.text3.withValues(alpha: 0.6),
                      ),
                    ],
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
