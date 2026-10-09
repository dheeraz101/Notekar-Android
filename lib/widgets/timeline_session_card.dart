import 'package:flutter/material.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/swipeable_card_bed.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

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
    this.rainbowCards = false,
    this.isOngoing,
    this.goals,
    this.isImageCollapsed = false,
    this.onToggleImageCollapse,
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
  final bool rainbowCards;
  final bool? isOngoing;
  final List<Goal>? goals;
  final bool isImageCollapsed;
  final VoidCallback? onToggleImageCollapse;

  Goal? _findMatchingGoal() {
    final gList = goals;
    if (gList == null || gList.isEmpty) return null;
    final cat = session.category;
    if (cat != null && cat.trim().isNotEmpty) {
      return gList
          .where(
            (g) =>
                !g.isArchived &&
                g.category != null &&
                g.category!.toLowerCase() == cat.toLowerCase(),
          )
          .firstOrNull;
    }
    return gList
        .where(
          (g) =>
              !g.isArchived &&
              (g.category == null || g.category!.trim().isEmpty),
        )
        .firstOrNull;
  }

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
    final isOngoing = this.isOngoing ?? session.isOngoing;
    final matchingGoal = _findMatchingGoal();
    final durationStr = _formatDuration(session.duration);
    final noteMoment = session.noteMoment;
    final hasMedia =
        noteMoment.imagePath != null || noteMoment.voicePath != null;
    final hasNote = session.note.isNotEmpty;
    final cardRadius = BorderRadius.circular(compact ? 16 : 24);
    final cat = session.category ?? 'Session';
    final meta = getCategoryMeta(cat, p);

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
              color: selected
                  ? p.surface3
                  : (rainbowCards
                        ? Color.alphaBlend(
                            meta.color.withValues(alpha: 0.12),
                            p.surface2,
                          )
                        : p.surface2),
              borderRadius: cardRadius,
              border: Border.all(
                color: selected
                    ? p.accent.withValues(alpha: 0.5)
                    : isOngoing
                    ? p.green.withValues(alpha: 0.4)
                    : (rainbowCards
                          ? ((cat.toLowerCase() == 'rest' ||
                                    cat.toLowerCase() == 'recovery')
                                ? p.border.withValues(alpha: 0.6)
                                : meta.color.withValues(alpha: 0.35))
                          : p.border.withValues(alpha: 0.6)),
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
                          timeOnly(
                            session.endTimestamp ??
                                DateTime.now().millisecondsSinceEpoch,
                          ),
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
                    hasMedia ||
                    !compact ||
                    (session.category != null &&
                        session.category!.trim().isNotEmpty)) ...[
                  SizedBox(height: compact ? 6 : 10),
                  GestureDetector(
                    onTap: () {
                      if (hasNote) {
                        NotePreviewSheet.show(
                          context,
                          p: p,
                          note: session.note,
                          title: 'Session Note',
                          category: session.category,
                          onEdit: onEditNote,
                        );
                      } else {
                        onEditNote();
                      }
                    },
                    onLongPress: onEditNote,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((session.category != null &&
                                  session.category!.trim().isNotEmpty) ||
                              matchingGoal != null) ...[
                            if (session.category != null &&
                                session.category!.trim().isNotEmpty)
                              _SessionCategoryBadge(
                                p: p,
                                category: session.category!,
                                compact: compact,
                              ),
                            if (matchingGoal != null) ...[
                              if (session.category != null &&
                                  session.category!.trim().isNotEmpty)
                                SizedBox(width: compact ? 4 : 5),
                              _SessionGoalBadge(
                                p: p,
                                goalTitle: matchingGoal.title,
                                durationStr: durationStr,
                                compact: compact,
                              ),
                            ],
                            SizedBox(width: compact ? 5 : 7),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                (hasNote || hasMedia)
                                    ? Icons.notes_rounded
                                    : Icons.add_comment_outlined,
                                size: compact ? 12 : 14,
                                color: (hasNote || hasMedia)
                                    ? p.accent
                                    : p.text3,
                              ),
                            ),
                            SizedBox(width: compact ? 6 : 8),
                          ],
                          Expanded(
                            child: (hasNote || hasMedia)
                                ? Builder(
                                    builder: (ctx) {
                                      final tags =
                                          NoteTagExtractor.extractHashtags(
                                            session.note,
                                          );
                                      final clean =
                                          NoteTagExtractor.cleanBodyText(
                                            session.note,
                                          );
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (clean.isNotEmpty)
                                            IosEmojiText(
                                              clean,
                                              maxLines: compact ? 1 : 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: p.text,
                                                fontSize: compact ? 11.5 : 12.5,
                                                height: 1.3,
                                              ),
                                            ),
                                          if (tags.isNotEmpty) ...[
                                            if (clean.isNotEmpty)
                                              const SizedBox(height: 3.5),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: tags.map((t) {
                                                final actTag = TagService
                                                    .instance
                                                    .findActivityTag(t);
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: p.surface3,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: p.border
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      width: 0.7,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        actTag?.icon ??
                                                            Icons.label_rounded,
                                                        size: 9.5,
                                                        color: p.accent,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        actTag?.label ??
                                                            TagService.stripHash(
                                                              t,
                                                            ),
                                                        style: TextStyle(
                                                          color: p.text2,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                          if (noteMoment.voicePath != null) ...[
                                            const SizedBox(height: 4),
                                            TimelineVoicePlayerPill(
                                              p: p,
                                              voicePath: noteMoment.voicePath!,
                                              durationMs:
                                                  noteMoment.voiceDurationMs ??
                                                  0,
                                            ),
                                          ],
                                          if (noteMoment.imagePath != null) ...[
                                            const SizedBox(height: 5),
                                            TimelineMediaAttachmentCard(
                                              p: p,
                                              imagePath: noteMoment.imagePath!,
                                              isCollapsed: isImageCollapsed,
                                              onToggleCollapse:
                                                  onToggleImageCollapse,
                                            ),
                                          ],
                                        ],
                                      );
                                    },
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
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: compact ? 13 : 15,
                              color: p.text3.withValues(alpha: 0.6),
                            ),
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
      constraints: BoxConstraints(maxWidth: compact ? 90 : 120),
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
          Flexible(
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: meta.color,
                fontSize: compact ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionGoalBadge extends StatelessWidget {
  const _SessionGoalBadge({
    required this.p,
    required this.goalTitle,
    required this.durationStr,
    required this.compact,
  });

  final Palette p;
  final String goalTitle;
  final String durationStr;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 110 : 140),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6.5,
        vertical: compact ? 1.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.accent.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: compact ? 9.5 : 11, color: p.accent),
          const SizedBox(width: 3.5),
          Flexible(
            child: Text(
              '$goalTitle • $durationStr',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.accent,
                fontSize: compact ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
