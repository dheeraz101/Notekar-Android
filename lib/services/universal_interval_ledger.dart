import 'dart:math' as math;

import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';

/// A mathematically bounded continuous time segment in NoteKar.
class CanonicalInterval {
  const CanonicalInterval({
    required this.id,
    required this.startMs,
    required this.endMs,
    required this.dateKey,
    required this.category,
    this.goalId,
    required this.isSession,
    this.note = '',
    this.tags = const [],
    this.inMomentId,
    this.outMomentId,
    this.isOngoing = false,
    this.isAutoRecovered = false,
  });

  final String id;
  final int startMs;
  final int endMs;
  final String dateKey;
  final String category;
  final String? goalId;
  final bool isSession;
  final String note;
  final List<String> tags;
  final int? inMomentId;
  final int? outMomentId;
  final bool isOngoing;
  final bool isAutoRecovered;

  int get durationMs => math.max(0, endMs - startMs);
  Duration get duration => Duration(milliseconds: durationMs);

  /// Slices this interval across day boundaries so no interval crosses midnight.
  List<CanonicalInterval> sliceAtMidnights() {
    if (endMs <= startMs) return [];

    final slices = <CanonicalInterval>[];
    var currentStart = startMs;

    while (currentStart < endMs) {
      final startDt = DateTime.fromMillisecondsSinceEpoch(currentStart);
      final nextMidnight = DateTime(
        startDt.year,
        startDt.month,
        startDt.day + 1,
      ).millisecondsSinceEpoch;

      final sliceEnd = math.min(endMs, nextMidnight);
      final sliceDateKey =
          '${startDt.year.toString().padLeft(4, '0')}-${startDt.month.toString().padLeft(2, '0')}-${startDt.day.toString().padLeft(2, '0')}';

      slices.add(
        CanonicalInterval(
          id: '${id}_${slices.length}',
          startMs: currentStart,
          endMs: sliceEnd,
          dateKey: sliceDateKey,
          category: category,
          goalId: goalId,
          isSession: isSession,
          note: note,
          tags: tags,
          inMomentId: inMomentId,
          outMomentId: outMomentId,
          isOngoing: isOngoing && sliceEnd == endMs,
          isAutoRecovered: isAutoRecovered,
        ),
      );

      currentStart = sliceEnd;
    }

    return slices;
  }
}

/// The Universal Interval Ledger (UIL) Engine.
/// Reconstructs continuous session intervals globally, performs midnight slicing,
/// and handles multi-track category/goal reconciliation without orphaned endpoints.
class UniversalIntervalLedger {
  const UniversalIntervalLedger._();
  static const UniversalIntervalLedger instance = UniversalIntervalLedger._();

  List<CanonicalInterval> computeIntervals(
    List<Moment> rawMoments, {
    DateTime? referenceNow,
  }) => reconstructAndSlice(rawMoments, referenceNow: referenceNow);

  /// and midnight boundary slicing.
  static List<CanonicalInterval> reconstructAndSlice(
    List<Moment> rawMoments, {
    DateTime? referenceNow,
  }) {
    if (rawMoments.isEmpty) return const [];
    final nowMs = (referenceNow ?? DateTime.now()).millisecondsSinceEpoch;

    // 1. Sort all moments chronologically ascending
    // When timestamps match, OUT precedes IN so a closing session closes
    // before a new session on the same track begins.
    final sorted = List<Moment>.from(rawMoments)
      ..sort((a, b) {
        final cmp = a.timestamp.compareTo(b.timestamp);
        if (cmp != 0) return cmp;
        if (a.type == 'out' && b.type != 'out') return -1;
        if (b.type == 'out' && a.type != 'out') return 1;
        return a.id.compareTo(b.id);
      });

    final rawIntervals = <CanonicalInterval>[];
    final Map<String, Moment> activeInTracks = {};

    String canonicalCategory(Moment m) {
      final cat = m.category?.trim().toLowerCase() ?? '';
      if (cat == 'rest' ||
          cat == 'recovery' ||
          cat == 'rest & recovery' ||
          cat.contains('rest & recovery')) {
        return 'rest';
      }
      if (m.tags.any((t) {
        final lower = t.toLowerCase();
        return lower == 'rest' || lower == '#rest' || lower == 'recovery';
      })) {
        return 'rest';
      }
      final note = m.note.trim().toLowerCase();
      if (note.contains('rest & recovery') ||
          note == 'rest' ||
          note == '#rest') {
        return 'rest';
      }
      if (cat.isNotEmpty) return cat;
      final tagCat = extractHashtagCategory(m.note);
      if (tagCat != null) return tagCat.trim().toLowerCase();
      return '';
    }

    String trackKey(Moment m) =>
        '${canonicalCategory(m)}|${m.effectiveGoalId ?? ''}';

    for (final m in sorted) {
      if (m.type == 'single') {
        rawIntervals.add(
          CanonicalInterval(
            id: 'single_${m.id}',
            startMs: m.timestamp,
            endMs: m.timestamp,
            dateKey: m.date,
            category: m.category ?? 'General',
            goalId: m.effectiveGoalId,
            isSession: false,
            note: m.note,
            tags: m.tags,
            inMomentId: m.id,
          ),
        );
      } else if (m.type == 'in') {
        final exactKey = trackKey(m);
        if (activeInTracks.containsKey(exactKey)) {
          // Auto-close preceding session on the same track at start of new IN
          final prevIn = activeInTracks.remove(exactKey)!;
          final endTs = m.timestamp > prevIn.timestamp
              ? m.timestamp
              : prevIn.timestamp + 1000;
          rawIntervals.add(
            CanonicalInterval(
              id: 'sess_${prevIn.id}_${m.id}',
              startMs: prevIn.timestamp,
              endMs: endTs,
              dateKey: prevIn.date,
              category: prevIn.category ?? 'General',
              goalId: prevIn.effectiveGoalId,
              isSession: true,
              note: prevIn.note,
              tags: prevIn.tags,
              inMomentId: prevIn.id,
              outMomentId: m.id,
              isOngoing: false,
            ),
          );
        }
        activeInTracks[exactKey] = m;
      } else if (m.type == 'out') {
        // Multi-track pairing: exact match -> category match -> oldest open track
        final exactKey = trackKey(m);
        String? matchedKey;

        if (activeInTracks.containsKey(exactKey)) {
          matchedKey = exactKey;
        } else {
          final cat = canonicalCategory(m);
          final matchingCatKey = activeInTracks.keys
              .where(
                (k) =>
                    k.startsWith('$cat|') ||
                    (cat.isNotEmpty && k.split('|').first == cat),
              )
              .firstOrNull;
          if (matchingCatKey != null) {
            matchedKey = matchingCatKey;
          } else if (activeInTracks.isNotEmpty) {
            matchedKey = activeInTracks.keys.first;
          }
        }

        if (matchedKey != null) {
          final activeIn = activeInTracks.remove(matchedKey)!;
          final endTs = m.timestamp > activeIn.timestamp
              ? m.timestamp
              : activeIn.timestamp + 1000;
          rawIntervals.add(
            CanonicalInterval(
              id: 'sess_${activeIn.id}_${m.id}',
              startMs: activeIn.timestamp,
              endMs: endTs,
              dateKey: activeIn.date,
              category: activeIn.category ?? m.category ?? 'General',
              goalId: activeIn.effectiveGoalId ?? m.effectiveGoalId,
              isSession: true,
              note: activeIn.note.isNotEmpty ? activeIn.note : m.note,
              tags: activeIn.tags.isNotEmpty ? activeIn.tags : m.tags,
              inMomentId: activeIn.id,
              outMomentId: m.id,
              isOngoing: false,
            ),
          );
        } else {
          // Standalone OUT without preceding IN: emit 0-duration reference
          rawIntervals.add(
            CanonicalInterval(
              id: 'orphan_out_${m.id}',
              startMs: m.timestamp,
              endMs: m.timestamp,
              dateKey: m.date,
              category: m.category ?? 'General',
              goalId: m.effectiveGoalId,
              isSession: false,
              note: m.note,
              tags: m.tags,
              outMomentId: m.id,
            ),
          );
        }
      }
    }

    // Process unclosed IN moments
    for (final activeIn in activeInTracks.values) {
      final inDt = DateTime.fromMillisecondsSinceEpoch(activeIn.timestamp);
      final inDateKey = activeIn.date;
      final nowDateKey = dateKey(DateTime.fromMillisecondsSinceEpoch(nowMs));
      final isToday = inDateKey == nowDateKey;
      final endTs = isToday
          ? math.max(activeIn.timestamp + 1000, nowMs)
          : math.min(
              DateTime(
                inDt.year,
                inDt.month,
                inDt.day,
                23,
                59,
                59,
                999,
              ).millisecondsSinceEpoch,
              activeIn.timestamp + const Duration(hours: 2).inMilliseconds,
            );
      rawIntervals.add(
        CanonicalInterval(
          id: 'ongoing_${activeIn.id}',
          startMs: activeIn.timestamp,
          endMs: endTs,
          dateKey: activeIn.date,
          category: activeIn.category ?? 'General',
          goalId: activeIn.effectiveGoalId,
          isSession: true,
          note: activeIn.note,
          tags: activeIn.tags,
          inMomentId: activeIn.id,
          isOngoing: isToday,
          isAutoRecovered: !isToday,
        ),
      );
    }

    // 3. Slice all intervals crossing midnight boundaries
    final sliced = <CanonicalInterval>[];
    for (final interval in rawIntervals) {
      if (interval.isSession && interval.durationMs > 0) {
        sliced.addAll(interval.sliceAtMidnights());
      } else {
        sliced.add(interval);
      }
    }

    // Sort chronologically ascending
    sliced.sort((a, b) => a.startMs.compareTo(b.startMs));
    return sliced;
  }
}
