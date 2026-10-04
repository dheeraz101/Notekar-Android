import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/dialogs/timeline_filter_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class SearchNotesSettingsPage {
  static List<Widget> buildSlivers({
    required BuildContext context,
    required Palette p,
    required List<Moment> entries,
    required String settingsQuery,
    required ValueChanged<String> onQueryChanged,
    required VoidCallback onClearQuery,
    required TextEditingController settingsSearchController,
    required FocusNode settingsSearchFocusNode,
    required bool compactHistory,
    required bool reduceMotion,
    required bool enableTranslucency,
    required List<String> recentSearches,
    required ValueChanged<String> onSaveRecentSearch,
    required VoidCallback onClearRecentSearches,
    TimelineFilterCriteria filterCriteria = const TimelineFilterCriteria(),
    ValueChanged<TimelineFilterCriteria>? onFilterCriteriaChanged,
    List<Moment> selectedMoments = const [],
    ValueChanged<Moment>? onToggleSelectMoment,
    VoidCallback? onClearSelection,
    bool rainbowCards = false,
    ValueChanged<Moment>? onEditNote,
  }) {
    final q = settingsQuery.trim().toLowerCase();
    final allTags = SearchIndexService.instance
        .getAllKnownTags()
        .where((tag) => !tag.toLowerCase().contains('godmode'))
        .toList();

    final daySections = buildTimelineDaySections(entries);
    final Map<int, TimelineSessionItem> sessionLookup = {};
    for (final sec in daySections) {
      for (final item in sec.items) {
        if (item is TimelineSessionItem) {
          sessionLookup[item.inMoment.id] = item;
          if (item.outMoment != null) {
            sessionLookup[item.outMoment!.id] = item;
          }
        }
      }
    }

    final notes = SearchIndexService.instance
        .search(
          allMoments: entries,
          query: q,
          mode: filterCriteria.mode,
          category: filterCriteria.category,
          hashtag: filterCriteria.hashtag,
          sessionLookup: sessionLookup,
        )
        .where(
          (e) =>
              e.note.trim().isNotEmpty &&
              !e.note.contains('God Mode Unlocked') &&
              !e.note.contains('#godmode'),
        )
        .toList();

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: SliverStickyHeaderDelegate(
          height: 72,
          child: Container(
            color: p.surface.withValues(
              alpha:
                  !reduceMotion &&
                      enableTranslucency &&
                      AdaptiveEngine().supportsBlur
                  ? 0.65
                  : 1.0,
            ),
            padding: const EdgeInsets.fromLTRB(0, spacing8, 0, spacing8),
            child: SearchNotesBox(
              p: p,
              controller: settingsSearchController,
              focusNode: settingsSearchFocusNode,
              onChanged: onQueryChanged,
              onClear: onClearQuery,
              isFilterActive: filterCriteria.isActive,
              onTapFilter: () async {
                final cats = await CategoryService().getCategories();
                if (!context.mounted) return;
                final res = await TimelineFilterSheet.show(
                  context,
                  p: p,
                  initial: filterCriteria,
                  categories: cats,
                  hashtags: allTags,
                  largeText: false,
                  blur: enableTranslucency,
                );
                if (res != null) {
                  onFilterCriteriaChanged?.call(res);
                }
              },
            ),
          ),
        ),
      ),

      // Selection banner for 2-moment time difference comparison
      if (selectedMoments.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows_rounded, color: p.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1 moment selected. Tap another to compare time.'
                          .localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PressableScale(
                    onTap: onClearSelection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cancel'.localized(context),
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      // Recent searches horizontal chips if query is empty
      if (q.isEmpty && recentSearches.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT SEARCHES',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: onClearRecentSearches,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              children: [
                for (final term in recentSearches)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 12),
                    child: PressableScale(
                      onTap: () {
                        settingsSearchController.text = term;
                        onQueryChanged(term);
                        onSaveRecentSearch(term);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: p.border.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: p.text3,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              term,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],

      // Empty state if zero notes exist or zero match filter
      if (notes.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 48),
            child: HIGEmptyState(
              p: p,
              icon: q.isEmpty
                  ? Icons.speaker_notes_off_rounded
                  : Icons.search_off_rounded,
              title: q.isEmpty ? 'No Notes Recorded' : 'No Matching Notes',
              message: q.isEmpty
                  ? 'Capture your first note by holding the clock face.'
                  : 'No notes match "$q".',
              compact: true,
            ),
          ),
        )
      else ...[
        // Header note count summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Text(
              q.isEmpty
                  ? 'ALL NOTES (${notes.length})'
                  : 'FOUND (${notes.length})',
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        // Full length notes list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, spacing24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= notes.length) return null;
              final entry = notes[index];
              final session = sessionLookup[entry.id];
              final isTwoWay =
                  entry.type == 'in' || entry.type == 'out' || session != null;

              final startTs = session != null
                  ? session.startTimestamp
                  : (entry.type == 'in' ? entry.timestamp : null);
              final endTs = session != null
                  ? session.outMoment?.timestamp
                  : (entry.type == 'out' ? entry.timestamp : null);
              final isOngoing = session != null
                  ? session.isOngoing
                  : (entry.type == 'in');
              final duration = session != null
                  ? session.duration
                  : (startTs != null
                        ? Duration(
                            milliseconds:
                                DateTime.now().millisecondsSinceEpoch - startTs,
                          )
                        : Duration.zero);

              final isSelected = selectedMoments.any((m) => m.id == entry.id);
              final meta = getCategoryMeta(
                entry.category ?? (isTwoWay ? 'two-way' : 'single'),
                p,
              );
              final Color? catColor = entry.category != null
                  ? meta.color
                  : null;
              final Color cardBg = (rainbowCards && catColor != null)
                  ? Color.alphaBlend(
                      catColor.withValues(alpha: 0.12),
                      p.surface2,
                    )
                  : p.surface2;
              final Color cardBorder = isSelected
                  ? p.accent
                  : (rainbowCards && catColor != null)
                  ? Color.alphaBlend(
                      catColor.withValues(alpha: 0.35),
                      p.border.withValues(alpha: 0.6),
                    )
                  : p.border.withValues(alpha: 0.6);

              return Padding(
                padding: EdgeInsets.only(bottom: compactHistory ? 10 : 14),
                child: PressableScale(
                  onTap: () {
                    if (selectedMoments.isNotEmpty) {
                      onToggleSelectMoment?.call(entry);
                      return;
                    }
                    if (q.isNotEmpty) onSaveRecentSearch(q);
                    HapticFeedback.selectionClick();
                    NotePreviewSheet.show(
                      context,
                      p: p,
                      note: entry.note,
                      title: entry.category ?? 'Note',
                      category: entry.category,
                      dateStr: datePretty(startTs ?? entry.timestamp),
                      onEdit: onEditNote != null
                          ? () => onEditNote(entry)
                          : null,
                    );
                  },
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    onToggleSelectMoment?.call(entry);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(spacing16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: cardBorder,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      boxShadow: p.name == 'amoled'
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 20% Top Metadata Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mode Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isTwoWay
                                                ? p.accent
                                                : momentColor(p, 'single'))
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          (isTwoWay
                                                  ? p.accent
                                                  : momentColor(p, 'single'))
                                              .withValues(alpha: 0.25),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isTwoWay
                                            ? Icons.sync_alt_rounded
                                            : Icons.touch_app_rounded,
                                        size: 11,
                                        color: isTwoWay
                                            ? p.accent
                                            : momentColor(p, 'single'),
                                      ),
                                      const SizedBox(width: 4.5),
                                      Text(
                                        isTwoWay ? '2-WAY' : 'SINGLE',
                                        style: TextStyle(
                                          color: isTwoWay
                                              ? p.accent
                                              : momentColor(p, 'single'),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (entry.note.length > 500) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.accent.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: p.accent.withValues(alpha: 0.25),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.doc_text,
                                          size: 10,
                                          color: p.accent,
                                        ),
                                        const SizedBox(width: 3.5),
                                        Text(
                                          '${entry.note.trim().split(RegExp(r'\s+')).length} words',
                                          style: TextStyle(
                                            color: p.accent,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Date & Compare Action
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (onEditNote != null)
                                  PressableScale(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      onEditNote(entry);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        CupertinoIcons.square_pencil,
                                        size: 15,
                                        color: p.accent,
                                      ),
                                    ),
                                  ),
                                PressableScale(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    onToggleSelectMoment?.call(entry);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.compare_arrows_rounded,
                                      size: 16,
                                      color: isSelected ? p.accent : p.text3,
                                    ),
                                  ),
                                ),
                                Text(
                                  datePretty(startTs ?? entry.timestamp),
                                  style: TextStyle(
                                    color: p.text3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Sub-row: Times & Counter / Duration
                        if (isTwoWay) ...[
                          Row(
                            children: [
                              // IN node
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
                                startTs != null
                                    ? 'IN ${timeOnly(startTs)}'
                                    : 'IN —',
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 11,
                                color: p.text3,
                              ),
                              const SizedBox(width: 8),
                              // OUT node
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOngoing ? p.green : p.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isOngoing
                                    ? 'ONGOING'.localized(context)
                                    : (endTs != null
                                          ? 'OUT ${timeOnly(endTs)}'
                                          : 'OUT —'),
                                style: TextStyle(
                                  color: isOngoing ? p.green : p.text2,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Duration count pill
                              if (duration > Duration.zero || isOngoing)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isOngoing ? p.green : p.accent)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      color: isOngoing ? p.green : p.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: momentColor(p, 'single'),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                timeOnly(entry.timestamp),
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 10),
                        Container(
                          height: 0.6,
                          color: p.border.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 10),

                        // 80% Hero Content: Full Note
                        IosEmojiText(
                          entry.note,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: notes.length),
          ),
        ),
      ],
    ];
  }

  static String _formatDuration(Duration d) {
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
}
