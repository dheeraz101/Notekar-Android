import 'dart:convert';
import 'dart:math' as math;

import 'package:notekar/models/moment.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prediction result from [AutoCategorizationEngine].
class CategoryPrediction {
  const CategoryPrediction({required this.category, required this.confidence});

  final String? category;
  final double confidence; // 0.0 to 1.0

  bool get isHighConfidence => confidence >= 0.75 && category != null;

  @override
  String toString() =>
      'CategoryPrediction(category: $category, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// 100% Offline, On-Device Naive Bayes Text Classifier for NoteKar Moments.
///
/// Learns word-frequency distributions strictly from the user's own past categorized notes
/// with zero cloud AI or network telemetry (MAJ-01).
class AutoCategorizationEngine {
  AutoCategorizationEngine._();
  static final AutoCategorizationEngine instance = AutoCategorizationEngine._();

  static const String prefsStorageKey = 'notekar_auto_category_model_v1';

  static const Set<String> _stopwords = {
    'the',
    'and',
    'a',
    'to',
    'in',
    'of',
    'is',
    'it',
    'for',
    'on',
    'with',
    'at',
    'by',
    'from',
    'up',
    'about',
    'into',
    'over',
    'after',
    'beneath',
    'this',
    'that',
    'these',
    'those',
    'i',
    'me',
    'my',
    'we',
    'us',
    'our',
    'you',
    'your',
    'he',
    'him',
    'his',
    'she',
    'her',
    'they',
    'them',
    'their',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'an',
    'as',
    'if',
    'or',
    'because',
    'while',
    'until',
    'so',
  };

  // Word frequencies per category: category -> word -> count
  final Map<String, Map<String, int>> _wordCounts = {};
  // Total words per category: category -> total word count
  final Map<String, int> _totalWordsPerCategory = {};
  // Total moments per category: category -> moment count
  final Map<String, int> _momentCounts = {};
  // Set of all unique words seen across all categories (vocabulary)
  final Set<String> _vocabulary = {};

  int _totalMoments = 0;
  bool _isTrained = false;
  bool get isTrained => _isTrained;

  /// Tokenizes a note into clean lowercase alphabetic terms, removing stopwords and digits.
  static List<String> tokenize(String text) {
    if (text.isEmpty) return const [];
    return text
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{M}\p{N}#_]+', unicode: true))
        .where((t) => t.length >= 3 && !_stopwords.contains(t))
        .toList();
  }

  /// Clears in-memory model data.
  void clear() {
    _wordCounts.clear();
    _totalWordsPerCategory.clear();
    _momentCounts.clear();
    _vocabulary.clear();
    _totalMoments = 0;
    _isTrained = false;
  }

  /// Trains the classifier over historical moments.
  /// Ignores moments without a category or notes that are empty.
  void train(List<Moment> moments) {
    clear();

    for (final moment in moments) {
      final cat = moment.category?.trim();
      if (cat == null || cat.isEmpty || cat.toLowerCase() == 'all') continue;
      final tokens = tokenize(moment.note);
      if (tokens.isEmpty) continue;

      _totalMoments++;
      _momentCounts[cat] = (_momentCounts[cat] ?? 0) + 1;

      final catWords = _wordCounts.putIfAbsent(cat, () => <String, int>{});
      for (final word in tokens) {
        catWords[word] = (catWords[word] ?? 0) + 1;
        _totalWordsPerCategory[cat] = (_totalWordsPerCategory[cat] ?? 0) + 1;
        _vocabulary.add(word);
      }
    }

    _isTrained = _wordCounts.isNotEmpty && _vocabulary.isNotEmpty;
  }

  /// Predicts the most likely category for [noteText] using Laplace-smoothed Naive Bayes.
  CategoryPrediction predict(String noteText) {
    if (!_isTrained || _totalMoments == 0 || _vocabulary.isEmpty) {
      return const CategoryPrediction(category: null, confidence: 0.0);
    }

    final tokens = tokenize(
      noteText,
    ).where((w) => _vocabulary.contains(w)).toList();

    if (tokens.isEmpty) {
      return const CategoryPrediction(category: null, confidence: 0.0);
    }

    final vocabSize = _vocabulary.length;
    final Map<String, double> logLikelihoods = {};

    for (final cat in _wordCounts.keys) {
      final prior = (_momentCounts[cat] ?? 0) / _totalMoments;
      double logProb = math.log(prior);

      final catWords = _wordCounts[cat]!;
      final totalCatWords = _totalWordsPerCategory[cat] ?? 0;
      final denominator = totalCatWords + vocabSize; // Laplace add-1 smoothing

      for (final token in tokens) {
        final count = catWords[token] ?? 0;
        final wordProb = (count + 1) / denominator;
        logProb += math.log(wordProb);
      }

      logLikelihoods[cat] = logProb;
    }

    if (logLikelihoods.isEmpty) {
      return const CategoryPrediction(category: null, confidence: 0.0);
    }

    // Convert log-likelihoods to probabilities using Log-Sum-Exp trick
    final maxLog = logLikelihoods.values.reduce(math.max);
    double expSum = 0.0;
    final Map<String, double> expProbs = {};

    for (final entry in logLikelihoods.entries) {
      final e = math.exp(entry.value - maxLog);
      expProbs[entry.key] = e;
      expSum += e;
    }

    String? bestCat;
    double highestProb = 0.0;

    for (final entry in expProbs.entries) {
      final prob = expSum > 0 ? entry.value / expSum : 0.0;
      if (prob > highestProb) {
        highestProb = prob;
        bestCat = entry.key;
      }
    }

    return CategoryPrediction(
      category: bestCat,
      confidence: highestProb.clamp(0.0, 1.0),
    );
  }

  /// Serializes model to SharedPreferences for fast instant warmup on boot.
  Future<void> saveToPrefs({SharedPreferences? prefs}) async {
    if (!_isTrained) return;
    final p = prefs ?? await SharedPreferences.getInstance();
    final modelData = {
      'wordCounts': _wordCounts,
      'totalWords': _totalWordsPerCategory,
      'momentCounts': _momentCounts,
      'vocabulary': _vocabulary.toList(),
      'totalMoments': _totalMoments,
    };
    await p.setString(prefsStorageKey, jsonEncode(modelData));
  }

  /// Loads serialized model from SharedPreferences.
  Future<bool> loadFromPrefs({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(prefsStorageKey);
    if (raw == null || raw.isEmpty) return false;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      clear();

      final rawWordCounts = data['wordCounts'] as Map<String, dynamic>? ?? {};
      for (final cat in rawWordCounts.keys) {
        final wordsMap = rawWordCounts[cat] as Map<String, dynamic>? ?? {};
        _wordCounts[cat] = wordsMap.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
      }

      final rawTotalWords = data['totalWords'] as Map<String, dynamic>? ?? {};
      for (final cat in rawTotalWords.keys) {
        _totalWordsPerCategory[cat] = (rawTotalWords[cat] as num).toInt();
      }

      final rawMomentCounts =
          data['momentCounts'] as Map<String, dynamic>? ?? {};
      for (final cat in rawMomentCounts.keys) {
        _momentCounts[cat] = (rawMomentCounts[cat] as num).toInt();
      }

      final rawVocab = data['vocabulary'] as List<dynamic>? ?? [];
      _vocabulary.addAll(rawVocab.map((e) => e.toString()));

      _totalMoments = (data['totalMoments'] as num?)?.toInt() ?? 0;
      _isTrained = _wordCounts.isNotEmpty && _vocabulary.isNotEmpty;
      return _isTrained;
    } catch (_) {
      clear();
      return false;
    }
  }
}
