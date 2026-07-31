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
import 'package:notekar/widgets/settings_widgets.dart';

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
      if (settingsQuery.trim().isEmpty) ...[
        if (recentSearches.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: HIGEmptyState(
                p: p,
                icon: Icons.search_rounded,
                title: 'Search Notes'.localized(context),
                message:
                    'Search for your moments by note content, date, time, or category.'
                        .localized(context),
                compact: true,
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT SEARCHES',
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SettingsGroup(
                  p: p,
                  insetDividers: true,
                  children: [
                    for (final term in recentSearches)
                      SettingsRow(
                        p: p,
                        icon: Icons.history_rounded,
                        title: term,
                        color: p.text3,
                        onTap: () {
                          settingsSearchController.text = term;
                          onQueryChanged(term);
                          onSaveRecentSearch(term);
                        },
                      ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ] else
        ...() {
          final notes = entries.where((e) => e.note.isNotEmpty).where((e) {
            final q = settingsQuery.trim().toLowerCase();
            if (q.isEmpty) return true;
            return e.note.toLowerCase().contains(q) ||
                datePretty(e.timestamp).contains(q) ||
                timeOnly(e.timestamp).contains(q);
          }).toList();

          if (notes.isEmpty) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: HIGEmptyState(
                    p: p,
                    icon: Icons.speaker_notes_off_rounded,
                    title: 'No Notes Found',
                    message: settingsQuery.isEmpty
                        ? 'Capture your first note by holding the clock.'
                        : 'No notes match "${settingsQuery.trim()}".',
                    compact: true,
                  ),
                ),
              ),
            ];
          }

          return [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                spacing16,
                spacing4,
                spacing16,
                spacing16,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= notes.length) return null;
                  final entry = notes[index];

                  return Padding(
                    padding: EdgeInsets.only(bottom: compactHistory ? 10 : 16),
                    child: PressableScale(
                      onTap: () {
                        onSaveRecentSearch(settingsQuery);
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
                          borderRadius: BorderRadius.circular(32),
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
                                  child: Text(
                                    entry.type.toUpperCase(),
                                    style: TextStyle(
                                      color: momentColor(p, entry.type),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
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
                            IosEmojiText(
                              entry.note,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 16,
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
          ];
        }(),
    ];
  }
}
