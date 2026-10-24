/// Central in-memory registry for saving and restoring scroll positions
/// across sheets, settings categories, history, and cards.
class AppScrollState {
  AppScrollState._();

  static final Map<String, double> _positions = <String, double>{};

  /// Save the scroll offset for a given [key].
  static void save(String key, double offset) {
    if (offset >= 0.0) {
      _positions[key] = offset;
    }
  }

  /// Retrieve the saved scroll offset for a given [key], default 0.0.
  static double get(String key) => _positions[key] ?? 0.0;

  /// Check whether an offset has been stored for [key].
  static bool has(String key) => _positions.containsKey(key);

  /// Clear the saved offset for a given [key].
  static void clear(String key) => _positions.remove(key);

  /// Reset all stored scroll positions.
  static void resetAll() => _positions.clear();
}
