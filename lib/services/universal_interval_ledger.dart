import 'dart:math' as math;

import 'package:notekar/models/moment.dart';

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

  /// Reconstructs canonical intervals from raw moments with multi-track category pairing
  /// and midnight boundary slicing.
  static List<CanonicalInterval> reconstructAndSlice(
    List<Moment> rawMoments, {
    DateTime? referenceNow,
  }) {
    if (rawMoments.isEmpty) return const [];
    final nowMs = (referenceNow ?? DateTime.now()).millisecondsSinceEpoch;

    // 1. Sort all moments chronologically ascending
    final sorted = List<Moment>.from(rawMoments)
      ..sort((a, b) {
        final cmp = a.timestamp.compareTo(b.timestamp);
        if (cmp != 0) return cmp;
        if (a.type == 'in' && b.type != 'in') return -1;
        if (b.type == 'in' && a.type != 'in') return 1;
        return a.id.compareTo(b.id);
      });

    // 2. Multi-track pairing by category & goal key
    final Map<String, List<Moment>> streams = {};
    final List<Moment> singles = [];

    for (final m in sorted) {
      if (m.type == 'single') {
        singles.add(m);
      } else {
        final trackKey = m.effectiveGoalId != null
            ? 'goal_${m.effectiveGoalId}'
            : (m.category?.toLowerCase() ?? 'default');
        streams.putIfAbsent(trackKey, () => []).add(m);
      }
    }

    final rawIntervals = <CanonicalInterval>[];

    // Process single moments
    for (final s in singles) {
      rawIntervals.add(
        CanonicalInterval(
          id: 'single_${s.id}',
          startMs: s.timestamp,
          endMs: s.timestamp,
          dateKey: s.date,
          category: s.category ?? 'General',
          goalId: s.effectiveGoalId,
          isSession: false,
          note: s.note,
          tags: s.tags,
          inMomentId: s.id,
        ),
      );
    }

    // Process multi-track session streams
    for (final entry in streams.entries) {
      final streamMoments = entry.value;
      Moment? activeIn;

      for (final m in streamMoments) {
        if (m.type == 'in') {
          if (activeIn != null) {
            // Auto-close preceding session at start of new IN
            final endTs = m.timestamp > activeIn.timestamp
                ? m.timestamp
                : activeIn.timestamp + 1000;
            rawIntervals.add(
              CanonicalInterval(
                id: 'sess_${activeIn.id}_${m.id}',
                startMs: activeIn.timestamp,
                endMs: endTs,
                dateKey: activeIn.date,
                category: activeIn.category ?? 'General',
                goalId: activeIn.effectiveGoalId,
                isSession: true,
                note: activeIn.note,
                tags: activeIn.tags,
                inMomentId: activeIn.id,
                outMomentId: m.id,
                isOngoing: false,
              ),
            );
          }
          activeIn = m;
        } else if (m.type == 'out') {
          if (activeIn != null) {
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
            activeIn = null;
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

      if (activeIn != null) {
        // Ongoing session
        final endTs = math.max(activeIn.timestamp + 1000, nowMs);
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
            isOngoing: true,
          ),
        );
      }
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
