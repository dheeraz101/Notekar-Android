import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_logger.dart';

/// Scored search result item for ranking moments by relevance.
class ScoredMomentMatch {
  const ScoredMomentMatch({required this.moment, required this.score});

  final Moment moment;
  final int score;
}

/// High-Performance Inverted Index & Tokenized Search Engine for NoteKar.
///
/// Replaces $O(N)$ linear substring scans with an in-memory inverted token index,
/// prefix trie matching, category/hashtag inverted maps, and relevance scoring.
class SearchIndexService {
  SearchIndexService._();

  static final SearchIndexService instance = SearchIndexService._();

  final _logger = AppLogger();

  // Inverted index: word token -> Set of moment IDs
  final Map<String, Set<int>> _tokenInvertedIndex = {};

  // Hashtag index: clean tag (lowercase, no '#') -> Set of moment IDs
  final Map<String, Set<int>> _hashtagInvertedIndex = {};

  // Category index: lowercase category -> Set of moment IDs
  final Map<String, Set<int>> _categoryInvertedIndex = {};

  // Type index: 'single', 'in', 'out' -> Set of moment IDs
  final Map<String, Set<int>> _typeInvertedIndex = {};

  // Cached all unique hashtags (with '#' prefix) sorted for instant autocomplete
  final Set<String> _knownTagsWithHash = {};
  List<String>? _sortedKnownTagsCache;

  bool _isIndexed = false;
  bool get isIndexed => _isIndexed;

  /// Tokenizes a string into normalized lowercase alphanumeric terms.
  static List<String> tokenize(String text) {
    if (text.isEmpty) return const [];
    return text
        .toLowerCase()
        .split(RegExp(r'[\s,\.\?!:;\-_/\\]+'))
        .where((token) => token.trim().isNotEmpty)
        .toList();
  }

  /// Rebuilds the complete index across all moments in memory.
  void buildIndex(List<Moment> moments) {
    clear();
    for (final moment in moments) {
      _indexSingle(moment);
    }
    _isIndexed = true;
    _logger.info(
      'SearchIndexService indexed ${moments.length} moments with ${_tokenInvertedIndex.length} distinct tokens and ${_hashtagInvertedIndex.length} hashtags',
    );
  }

  /// Clears all inverted indices and caches.
  void clear() {
    _tokenInvertedIndex.clear();
    _hashtagInvertedIndex.clear();
    _categoryInvertedIndex.clear();
    _typeInvertedIndex.clear();
    _knownTagsWithHash.clear();
    _sortedKnownTagsCache = null;
    _isIndexed = false;
  }

  /// Index a single moment incrementally.
  void indexMoment(Moment moment) {
    // Clean old entries if it was already indexed
    unindexMoment(moment.id);
    _indexSingle(moment);
    _sortedKnownTagsCache = null;
  }

  void _indexSingle(Moment moment) {
    final id = moment.id;

    // 1. Index note body tokens
    final tokens = tokenize(moment.note);
    for (final token in tokens) {
      _tokenInvertedIndex.putIfAbsent(token, () => <int>{}).add(id);
    }

    // 2. Index category tokens
    if (moment.category != null && moment.category!.trim().isNotEmpty) {
      final catLower = moment.category!.trim().toLowerCase();
      _categoryInvertedIndex.putIfAbsent(catLower, () => <int>{}).add(id);
      for (final catToken in tokenize(catLower)) {
        _tokenInvertedIndex.putIfAbsent(catToken, () => <int>{}).add(id);
      }
    }

    // 3. Index type
    _typeInvertedIndex
        .putIfAbsent(moment.type.toLowerCase(), () => <int>{})
        .add(id);

    // 4. Index hashtags (both explicit tags and inline #tags)
    for (final tag in moment.effectiveTags) {
      final clean = tag.toLowerCase().replaceAll('#', '').trim();
      if (clean.isNotEmpty) {
        _hashtagInvertedIndex.putIfAbsent(clean, () => <int>{}).add(id);
        _knownTagsWithHash.add('#$clean');
        // Also add the tag token to the general token index for full-text queries
        _tokenInvertedIndex.putIfAbsent(clean, () => <int>{}).add(id);
      }
    }

    // 5. Index multimodal tokens if voice or photo is present
    if (moment.voicePath != null) {
      for (final t in ['voice', 'audio', 'memo', 'recording']) {
        _tokenInvertedIndex.putIfAbsent(t, () => <int>{}).add(id);
      }
    }
    if (moment.imagePath != null) {
      for (final t in ['photo', 'image', 'picture', 'attachment']) {
        _tokenInvertedIndex.putIfAbsent(t, () => <int>{}).add(id);
      }
    }
  }

  /// Unindex a single moment (e.g. on deletion or before updating).
  void unindexMoment(int id) {
    for (final set in _tokenInvertedIndex.values) {
      set.remove(id);
    }
    for (final set in _hashtagInvertedIndex.values) {
      set.remove(id);
    }
    for (final set in _categoryInvertedIndex.values) {
      set.remove(id);
    }
    for (final set in _typeInvertedIndex.values) {
      set.remove(id);
    }
    _sortedKnownTagsCache = null;
  }

  /// Returns all known hashtags (e.g. ['#deepwork', '#gym']) in sorted order.
  List<String> getAllKnownTags() {
    if (_sortedKnownTagsCache != null) {
      return _sortedKnownTagsCache!;
    }
    final sorted = _knownTagsWithHash.toList()..sort();
    _sortedKnownTagsCache = sorted;
    return sorted;
  }

  /// Fast $O(K)$ prefix autocomplete for tags.
  List<String> suggestTags(String prefix, {int limit = 8}) {
    final clean = prefix.toLowerCase().replaceAll('#', '').trim();
    if (clean.isEmpty) return const [];
    final all = getAllKnownTags();
    return all
        .where((t) => t.substring(1).startsWith(clean))
        .take(limit)
        .toList();
  }

  /// High-performance search with candidate pre-filtering and relevance scoring.
  ///
  /// Evaluates query tokens against inverted indices and filters by mode,
  /// category, and hashtag in microseconds.
  List<Moment> search({
    required List<Moment> allMoments,
    required String query,
    String? mode, // 'single', 'two-way', or null for all
    String? category,
    String? hashtag,
    Map<int, dynamic>? sessionLookup,
  }) {
    if (!_isIndexed) {
      buildIndex(allMoments);
    }

    final rawQuery = query.trim().toLowerCase();
    final tokens = tokenize(rawQuery);

    // Fast lookup map for all moments by ID
    final Map<int, Moment> momentMap = {for (final m in allMoments) m.id: m};

    // Determine initial candidate ID set
    Set<int>? candidateIds;

    // 1. Filter by hashtag index if requested
    if (hashtag != null && hashtag.trim().isNotEmpty) {
      final cleanTag = hashtag.toLowerCase().replaceAll('#', '').trim();
      final tagMatches = _hashtagInvertedIndex[cleanTag] ?? <int>{};
      candidateIds = Set<int>.from(tagMatches);
      if (candidateIds.isEmpty) return const [];
    }

    // 2. Filter by category index if requested
    if (category != null && category.trim().isNotEmpty) {
      final cleanCat = category.toLowerCase().trim();
      final catMatches = _categoryInvertedIndex[cleanCat] ?? <int>{};
      if (candidateIds == null) {
        candidateIds = Set<int>.from(catMatches);
      } else {
        candidateIds = candidateIds.intersection(catMatches);
      }
      if (candidateIds.isEmpty) return const [];
    }

    // 3. Filter by mode if requested
    if (mode == 'single') {
      final singleIds = _typeInvertedIndex['single'] ?? <int>{};
      if (candidateIds == null) {
        candidateIds = Set<int>.from(singleIds);
      } else {
        candidateIds = candidateIds.intersection(singleIds);
      }
      if (candidateIds.isEmpty) return const [];
    } else if (mode == 'two-way') {
      final inIds = _typeInvertedIndex['in'] ?? <int>{};
      final outIds = _typeInvertedIndex['out'] ?? <int>{};
      final twoWayIds = <int>{...inIds, ...outIds};
      if (candidateIds == null) {
        candidateIds = Set<int>.from(twoWayIds);
      } else {
        candidateIds = candidateIds.intersection(twoWayIds);
      }
      if (candidateIds.isEmpty) return const [];
    }

    // 4. If query tokens are present, intersect token matches
    if (tokens.isNotEmpty) {
      for (final token in tokens) {
        // Collect matches for this token: exact token + prefix token matches
        final tokenMatches = <int>{};
        final exact = _tokenInvertedIndex[token];
        if (exact != null) {
          tokenMatches.addAll(exact);
        }

        // Check prefix matches in token index for incremental typing
        for (final entry in _tokenInvertedIndex.entries) {
          if (entry.key != token && entry.key.startsWith(token)) {
            tokenMatches.addAll(entry.value);
          }
        }

        if (tokenMatches.isEmpty) {
          // No moments match this token
          return const [];
        }

        if (candidateIds == null) {
          candidateIds = tokenMatches;
        } else {
          candidateIds = candidateIds.intersection(tokenMatches);
        }

        if (candidateIds.isEmpty) return const [];
      }
    }

    // If candidateIds is still null (no filters and no query), return all moments sorted
    final matchedIds = candidateIds ?? momentMap.keys.toSet();

    // 5. Score and rank candidates
    if (tokens.isEmpty && rawQuery.isEmpty) {
      final result = matchedIds
          .map((id) => momentMap[id])
          .whereType<Moment>()
          .toList();
      result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return result;
    }

    final scored = <ScoredMomentMatch>[];
    for (final id in matchedIds) {
      final moment = momentMap[id];
      if (moment == null) continue;

      int score = 0;
      final noteLower = moment.note.toLowerCase();

      // Exact full query match
      if (noteLower == rawQuery) {
        score += 1000;
      } else if (noteLower.startsWith(rawQuery)) {
        score += 500;
      } else if (noteLower.contains(rawQuery)) {
        score += 250;
      }

      // Token matches
      for (final token in tokens) {
        if (noteLower.contains(token)) {
          score += 150;
          if (noteLower.startsWith(token)) score += 50;
        }
        if (moment.category != null &&
            moment.category!.toLowerCase().contains(token)) {
          score += 80;
        }
        if (moment.type.toLowerCase().contains(token)) {
          score += 40;
        }
      }

      if (score > 0 || tokens.isEmpty) {
        scored.add(ScoredMomentMatch(moment: moment, score: score));
      }
    }

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return b.moment.timestamp.compareTo(a.moment.timestamp);
    });

    return scored.map((s) => s.moment).toList();
  }
}
