import 'package:flutter/material.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/swipeable_card_bed.dart';

class TimelineSessionCard extends StatelessWidget {
  const TimelineSessionCard({
    super.key,
    required this.p,
    required this.session,
    required this.onEditNote,
    required this.onDeleteSession,
    this.onEndSession,
    this.onTapCard,
    this.onLongPressCard,
    this.selected = false,
    this.compact = false,
  });

  final Palette p;
  final TimelineSessionItem session;
  final VoidCallback onEditNote;
  final VoidCallback onDeleteSession;
  final VoidCallback? onEndSession;
  final VoidCallback? onTapCard;
  final VoidCallback? onLongPressCard;
  final bool selected;
  final bool compact;

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
    final cardRadius = BorderRadius.circular(compact ? 12 : 16);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2.5 : 4),
      child: SwipeableCardBed(
        key: ValueKey(
          'session-${session.inMoment.id}-${session.outMoment?.id ?? 'live'}',
        ),
        borderRadius: cardRadius,
        deleteColor: p.red,
        editColor: p.accent,
        deleteLabel: 'Delete',
        editLabel: 'Note',
        actionIconSize: compact ? 20 : 22,
        actionFontSize: compact ? 12 : 13,
        onDelete: onDeleteSession,
        onEdit: onEditNote,
        child: PressableScale(
          onTap: onTapCard ?? onEditNote,
          onLongPress: onLongPressCard,
          child: Container(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 11, vertical: 8)
                : const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? p.surface3 : p.surface2,
              borderRadius: cardRadius,
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
                      width: compact ? 6 : 8,
                      height: compact ? 6 : 8,
                      decoration: BoxDecoration(
                        color: p.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timeOnly(session.startTimestamp),
                        style: TextStyle(
                          color: p.text,
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    // Duration Connector or Live Activity Pill
                    if (isOngoing) ...[
                      SizedBox(width: compact ? 6 : 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 6 : 9,
                          vertical: compact ? 2 : 3.5,
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
                              width: compact ? 5 : 6,
                              height: compact ? 5 : 6,
                              decoration: BoxDecoration(
                                color: p.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: compact ? 4 : 5),
                            Text(
                              'LIVE $durationStr',
                              style: TextStyle(
                                color: p.green,
                                fontSize: compact ? 10 : 11,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onEndSession != null) ...[
                        SizedBox(width: compact ? 4 : 6),
                        PressableScale(
                          onTap: onEndSession,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 6 : 8,
                              vertical: compact ? 2 : 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: p.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: p.red.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stop_circle_rounded,
                                  size: compact ? 11 : 12,
                                  color: p.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'End'.localized(context),
                                  style: TextStyle(
                                    color: p.red,
                                    fontSize: compact ? 9.5 : 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 4 : 6,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  height: 1,
                                  color: p.border.withValues(alpha: 0.6),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: compact ? 3 : 5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 5 : 7,
                                  vertical: compact ? 1.5 : 2.5,
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
                                    fontSize: compact ? 9.5 : 10.5,
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
                            fontSize: compact ? 12 : 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 4 : 6),
                      Container(
                        width: compact ? 6 : 8,
                        height: compact ? 6 : 8,
                        decoration: BoxDecoration(
                          color: p.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                // Note Content / Mode & Note area
                if (hasNote ||
                    !compact ||
                    (session.category != null &&
                        session.category!.trim().isNotEmpty)) ...[
                  SizedBox(height: compact ? 6 : 10),
                  GestureDetector(
                    onTap: onEditNote,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 10,
                        vertical: compact ? 4 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface3.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(compact ? 6 : 8),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (session.category != null &&
                              session.category!.trim().isNotEmpty) ...[
                            _SessionCategoryBadge(
                              p: p,
                              category: session.category!,
                              compact: compact,
                            ),
                            SizedBox(width: compact ? 5 : 7),
                          ] else ...[
                            Icon(
                              hasNote
                                  ? Icons.notes_rounded
                                  : Icons.add_comment_outlined,
                              size: compact ? 12 : 14,
                              color: hasNote ? p.accent : p.text3,
                            ),
                            SizedBox(width: compact ? 6 : 8),
                          ],
                          Expanded(
                            child: hasNote
                                ? IosEmojiText(
                                    session.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: p.text,
                                      fontSize: compact ? 11.5 : 12.5,
                                      height: 1.3,
                                    ),
                                  )
                                : Text(
                                    'Tap to add session note...'.localized(
                                      context,
                                    ),
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
                            size: compact ? 13 : 15,
                            color: p.text3.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCategoryBadge extends StatelessWidget {
  const _SessionCategoryBadge({
    required this.p,
    required this.category,
    required this.compact,
  });

  final Palette p;
  final String category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final meta = getCategoryMeta(category, p);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 1.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: meta.color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: compact ? 9 : 11, color: meta.color),
          const SizedBox(width: 3.5),
          Text(
            category,
            style: TextStyle(
              color: meta.color,
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
