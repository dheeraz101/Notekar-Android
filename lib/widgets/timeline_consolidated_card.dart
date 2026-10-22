import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

/// A sleek consolidated summary card that groups multiple entries under a shared
/// category or tag into one expandable container to dramatically reduce timeline clutter.
class TimelineConsolidatedCard extends StatefulWidget {
  const TimelineConsolidatedCard({
    super.key,
    required this.p,
    required this.consolidatedItem,
    required this.onEditNote,
    this.onDeleteMoment,
    this.rainbowCards = false,
    this.compact = false,
  });

  final Palette p;
  final TimelineConsolidatedItem consolidatedItem;
  final ValueChanged<Moment> onEditNote;
  final ValueChanged<Moment>? onDeleteMoment;
  final bool rainbowCards;
  final bool compact;

  @override
  State<TimelineConsolidatedCard> createState() =>
      _TimelineConsolidatedCardState();
}

class _TimelineConsolidatedCardState extends State<TimelineConsolidatedCard> {
  bool _isExpanded = false;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final item = widget.consolidatedItem;
    final cat = item.category;
    final meta = getCategoryMeta(cat, p);
    final count = item.count;
    final tracked = item.totalTrackedDuration;

    final cardBg = widget.rainbowCards
        ? Color.alphaBlend(meta.color.withValues(alpha: 0.12), p.surface2)
        : p.surface2;

    final borderColor = widget.rainbowCards
        ? meta.color.withValues(alpha: 0.45)
        : p.border.withValues(alpha: 0.6);

    // Collect all preview items for this consolidated card for seamless note browsing
    final noteItems = item.items.where((it) {
      if (it is TimelineSessionItem) return it.note.isNotEmpty;
      if (it is TimelineSingleItem) return it.moment.note.isNotEmpty;
      return false;
    }).toList();

    final previewItems = noteItems.map((it) {
      if (it is TimelineSessionItem) {
        return NotePreviewItem(
          note: it.note,
          title: it.category ?? 'Session Note',
          category: it.category,
          dateStr: datePretty(it.startTimestamp),
          onEdit: () => widget.onEditNote(it.noteMoment),
        );
      } else {
        final s = it as TimelineSingleItem;
        return NotePreviewItem(
          note: s.moment.note,
          title: s.moment.category ?? 'Moment Note',
          category: s.moment.category,
          dateStr: datePretty(s.moment.timestamp),
          onEdit: () => widget.onEditNote(s.moment),
        );
      }
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary strip (Tappable to expand/collapse)
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: meta.color.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(meta.icon, size: 17, color: meta.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cat,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface3,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: p.border.withValues(alpha: 0.5),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  '$count logs',
                                  style: TextStyle(
                                    color: p.text2,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tracked > Duration.zero
                                ? '${_formatDuration(tracked)} tracked total'
                                : '${item.items.firstOrNull != null ? timeOnly(item.items.first.primaryTimestamp) : ""} • Consolidated Card',
                            style: TextStyle(
                              color: tracked > Duration.zero
                                  ? p.green
                                  : p.text3,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'GROUP'.localized(context),
                        style: TextStyle(
                          color: meta.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _isExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 15,
                      color: p.text3,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Child Entries List
            if (_isExpanded) ...[
              Container(height: 1, color: p.border.withValues(alpha: 0.35)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < item.items.length; i++) ...[
                      _buildChildEntry(
                        context,
                        item.items[i],
                        previewItems,
                        noteItems.indexOf(item.items[i]),
                      ),
                      if (i < item.items.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            color: p.border.withValues(alpha: 0.25),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChildEntry(
    BuildContext context,
    TimelineItem entry,
    List<NotePreviewItem> previewItems,
    int noteIdx,
  ) {
    final p = widget.p;

    if (entry is TimelineSessionItem) {
      final range =
          '${timeOnly(entry.startTimestamp)} → ${entry.endTimestamp != null ? timeOnly(entry.endTimestamp!) : "Live"}';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: p.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        range,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(entry.duration),
                        style: TextStyle(
                          color: p.green,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    PressableScale(
                      onTap: () {
                        NotePreviewSheet.show(
                          context,
                          p: p,
                          note: entry.note,
                          title: entry.category ?? 'Session Note',
                          category: entry.category,
                          dateStr: datePretty(entry.startTimestamp),
                          items: previewItems,
                          initialIndex: noteIdx >= 0 ? noteIdx : 0,
                          onEdit: () => widget.onEditNote(entry.noteMoment),
                        );
                      },
                      child: IosEmojiText(
                        entry.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (entry is TimelineSingleItem) {
      final m = entry.moment;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeOnly(m.timestamp),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'SINGLE',
                        style: TextStyle(
                          color: p.text3,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (m.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    PressableScale(
                      onTap: () {
                        NotePreviewSheet.show(
                          context,
                          p: p,
                          note: m.note,
                          title: m.category ?? 'Moment Note',
                          category: m.category,
                          dateStr: datePretty(m.timestamp),
                          items: previewItems,
                          initialIndex: noteIdx >= 0 ? noteIdx : 0,
                          onEdit: () => widget.onEditNote(m),
                        );
                      },
                      child: IosEmojiText(
                        m.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                  if (m.voicePaths.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    for (final vp in m.voicePaths)
                      TimelineVoicePlayerPill(
                        p: p,
                        voicePath: vp,
                        durationMs: m.voiceDurationMs ?? 0,
                      ),
                  ],
                  if (m.imagePath != null &&
                      m.imagePath!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    TimelineMediaAttachmentCard(
                      p: p,
                      imagePath: m.imagePath!,
                      isCollapsed: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
