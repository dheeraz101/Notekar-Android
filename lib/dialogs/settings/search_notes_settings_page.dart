import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
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
  }) {
    final q = settingsQuery.trim().toLowerCase();
    final notes = entries.where((e) => e.note.trim().isNotEmpty).where((e) {
      if (q.isEmpty) return true;
      return e.note.toLowerCase().contains(q) ||
          datePretty(e.timestamp).toLowerCase().contains(q) ||
          timeOnly(e.timestamp).toLowerCase().contains(q) ||
          e.type.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: SliverStickyHeaderDelegate(
          height: 80,
          child: Container(
            color: p.surface.withValues(
              alpha:
                  !reduceMotion &&
                      enableTranslucency &&
                      AdaptiveEngine().supportsBlur
                  ? 0.65
                  : 1.0,
            ),
            padding: const EdgeInsets.fromLTRB(
              spacing16,
              spacing8,
              spacing16,
              spacing12,
            ),
            child: SearchNotesBox(
              p: p,
              controller: settingsSearchController,
              focusNode: settingsSearchFocusNode,
              onChanged: onQueryChanged,
              onClear: onClearQuery,
            ),
          ),
        ),
      ),

      // Recent searches horizontal chips if query is empty
      if (q.isEmpty && recentSearches.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
          padding: const EdgeInsets.fromLTRB(
            spacing16,
            0,
            spacing16,
            spacing24,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= notes.length) return null;
              final entry = notes[index];

              return Padding(
                padding: EdgeInsets.only(bottom: compactHistory ? 10 : 14),
                child: PressableScale(
                  onTap: () {
                    if (q.isNotEmpty) onSaveRecentSearch(q);
                    Clipboard.setData(ClipboardData(text: entry.note));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Note copied to clipboard'.localized(context),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(spacing16),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.6),
                        width: 0.8,
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: momentColor(
                                  p,
                                  entry.type,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    entry.type == 'in'
                                        ? Icons.south_west_rounded
                                        : Icons.north_east_rounded,
                                    size: 11,
                                    color: momentColor(p, entry.type),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.type.toUpperCase(),
                                    style: TextStyle(
                                      color: momentColor(p, entry.type),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${datePretty(entry.timestamp)} • ${timeOnly(entry.timestamp)}',
                                style: TextStyle(
                                  color: p.text3,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Complete note text displayed in full length
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
}
