import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;

  // Preferences state
  String _theme = 'dark';
  String _locale = 'system';
  String _accentColor = 'blue';
  String _appIconStyle = 'default';
  bool _showSeconds = true;
  bool _highlightSeconds = true;
  bool _buttonLabels = true;
  bool _largeControls = false;
  bool _homeMenuPill = false;
  bool _homeMenuAnimations = false;
  bool _enableTranslucency = true;
  bool _showHistoryText = true;
  bool _showLastSavedHint = true;
  String _defaultMode = 'single';
  int _tapDelay = 0;
  bool _requireLongPressNote = false;
  bool _compactHistory = false;
  bool _confirmDelete = true;
  bool _extendedDuration = false;
  bool _minimalMomentOptions = false;
  bool _reduceMotion = false;
  bool _largeText = false;
  bool _highContrast = false;
  String _historyDensity = 'comfortable';

  // Getters
  String get theme => _theme;
  String get locale => _locale;
  String get accentColor => _accentColor;
  String get appIconStyle => _appIconStyle;
  bool get showSeconds => _showSeconds;
  bool get highlightSeconds => _highlightSeconds;
  bool get buttonLabels => _buttonLabels;
  bool get largeControls => _largeControls;
  bool get homeMenuPill => _homeMenuPill;
  bool get homeMenuAnimations => _homeMenuAnimations;
  bool get enableTranslucency => _enableTranslucency;
  bool get showHistoryText => _showHistoryText;
  bool get showLastSavedHint => _showLastSavedHint;
  String get defaultMode => _defaultMode;
  int get tapDelay => _tapDelay;
  bool get requireLongPressNote => _requireLongPressNote;
  bool get compactHistory => _compactHistory;
  bool get confirmDelete => _confirmDelete;
  bool get extendedDuration => _extendedDuration;
  bool get minimalMomentOptions => _minimalMomentOptions;
  bool get reduceMotion => _reduceMotion;
  bool get largeText => _largeText;
  bool get highContrast => _highContrast;
  String get historyDensity => _historyDensity;

  void _loadFromPrefs() {
    _theme = _prefs.getString('theme') ?? 'dark';
    _locale = _prefs.getString('locale') ?? 'system';
    _accentColor = _prefs.getString('accent_color') ?? 'blue';
    _appIconStyle = _prefs.getString('app_icon_style') ?? 'default';
    _showSeconds = _prefs.getBool('show_seconds') ?? true;
    _highlightSeconds = _prefs.getBool('highlight_seconds') ?? true;
    _buttonLabels = _prefs.getBool('button_labels') ?? true;
    _largeControls = _prefs.getBool('large_controls') ?? false;
    _homeMenuPill = _prefs.getBool('home_menu_pill') ?? false;
    _homeMenuAnimations = _prefs.getBool('home_menu_animations') ?? false;
    _enableTranslucency = _prefs.getBool('enable_translucency') ?? true;
    _showHistoryText = _prefs.getBool('show_history_text') ?? true;
    _showLastSavedHint = _prefs.getBool('show_last_saved_hint') ?? true;
    _defaultMode = _prefs.getString('default_mode') ?? 'single';
    _tapDelay = _prefs.getInt('tap_delay') ?? 0;
    _requireLongPressNote = _prefs.getBool('require_long_press_note') ?? false;
    _compactHistory = _prefs.getBool('compact_history') ?? false;
    _confirmDelete = _prefs.getBool('confirm_delete') ?? true;
    _extendedDuration = _prefs.getBool('extended_duration') ?? false;
    _minimalMomentOptions = _prefs.getBool('minimal_moment_options') ?? false;
    _reduceMotion = _prefs.getBool('reduce_motion') ?? false;
    _largeText = _prefs.getBool('large_text') ?? false;
    _highContrast = _prefs.getBool('high_contrast') ?? false;
    _historyDensity = _prefs.getString('history_density') ?? 'comfortable';
  }

  // Setters with persistent storage
  Future<void> setTheme(String value) async {
    if (_theme == value) return;
    _theme = value;
    await _prefs.setString('theme', value);
    notifyListeners();
  }

  Future<void> setLocale(String value) async {
    if (_locale == value) return;
    _locale = value;
    await _prefs.setString('locale', value);
    notifyListeners();
  }

  Future<void> setAccentColor(String value) async {
    if (_accentColor == value) return;
    _accentColor = value;
    await _prefs.setString('accent_color', value);
    notifyListeners();
  }

  Future<void> setAppIconStyle(String value) async {
    if (_appIconStyle == value) return;
    _appIconStyle = value;
    await _prefs.setString('app_icon_style', value);
    notifyListeners();
  }

  Future<void> setShowSeconds(bool value) async {
    if (_showSeconds == value) return;
    _showSeconds = value;
    await _prefs.setBool('show_seconds', value);
    notifyListeners();
  }

  Future<void> setHighlightSeconds(bool value) async {
    if (_highlightSeconds == value) return;
    _highlightSeconds = value;
    await _prefs.setBool('highlight_seconds', value);
    notifyListeners();
  }

  Future<void> setButtonLabels(bool value) async {
    if (_buttonLabels == value) return;
    _buttonLabels = value;
    await _prefs.setBool('button_labels', value);
    notifyListeners();
  }

  Future<void> setLargeControls(bool value) async {
    if (_largeControls == value) return;
    _largeControls = value;
    await _prefs.setBool('large_controls', value);
    notifyListeners();
  }

  Future<void> setHomeMenuPill(bool value) async {
    if (_homeMenuPill == value) return;
    _homeMenuPill = value;
    await _prefs.setBool('home_menu_pill', value);
    notifyListeners();
  }

  Future<void> setHomeMenuAnimations(bool value) async {
    if (_homeMenuAnimations == value) return;
    _homeMenuAnimations = value;
    await _prefs.setBool('home_menu_animations', value);
    notifyListeners();
  }

  Future<void> setEnableTranslucency(bool value) async {
    if (_enableTranslucency == value) return;
    _enableTranslucency = value;
    await _prefs.setBool('enable_translucency', value);
    notifyListeners();
  }

  Future<void> setShowHistoryText(bool value) async {
    if (_showHistoryText == value) return;
    _showHistoryText = value;
    await _prefs.setBool('show_history_text', value);
    notifyListeners();
  }

  Future<void> setShowLastSavedHint(bool value) async {
    if (_showLastSavedHint == value) return;
    _showLastSavedHint = value;
    await _prefs.setBool('show_last_saved_hint', value);
    notifyListeners();
  }

  Future<void> setDefaultMode(String value) async {
    if (_defaultMode == value) return;
    _defaultMode = value;
    await _prefs.setString('default_mode', value);
    notifyListeners();
  }

  Future<void> setTapDelay(int value) async {
    if (_tapDelay == value) return;
    _tapDelay = value;
    await _prefs.setInt('tap_delay', value);
    notifyListeners();
  }

  Future<void> setRequireLongPressNote(bool value) async {
    if (_requireLongPressNote == value) return;
    _requireLongPressNote = value;
    await _prefs.setBool('require_long_press_note', value);
    notifyListeners();
  }

  Future<void> setCompactHistory(bool value) async {
    if (_compactHistory == value) return;
    _compactHistory = value;
    await _prefs.setBool('compact_history', value);
    notifyListeners();
  }

  Future<void> setConfirmDelete(bool value) async {
    if (_confirmDelete == value) return;
    _confirmDelete = value;
    await _prefs.setBool('confirm_delete', value);
    notifyListeners();
  }

  Future<void> setExtendedDuration(bool value) async {
    if (_extendedDuration == value) return;
    _extendedDuration = value;
    await _prefs.setBool('extended_duration', value);
    notifyListeners();
  }

  Future<void> setMinimalMomentOptions(bool value) async {
    if (_minimalMomentOptions == value) return;
    _minimalMomentOptions = value;
    await _prefs.setBool('minimal_moment_options', value);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    if (value) _homeMenuAnimations = false;
    await _prefs.setBool('reduce_motion', value);
    notifyListeners();
  }

  Future<void> setLargeText(bool value) async {
    if (_largeText == value) return;
    _largeText = value;
    await _prefs.setBool('large_text', value);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    _highContrast = value;
    await _prefs.setBool('high_contrast', value);
    notifyListeners();
  }

  Future<void> setHistoryDensity(String value) async {
    if (_historyDensity == value) return;
    _historyDensity = value;
    await _prefs.setString('history_density', value);
    notifyListeners();
  }

  Future<void> resetAllSettings() async {
    _theme = 'dark';
    _accentColor = 'blue';
    _appIconStyle = 'default';
    _showSeconds = true;
    _highlightSeconds = true;
    _buttonLabels = true;
    _largeControls = false;
    _homeMenuPill = false;
    _homeMenuAnimations = false;
    _enableTranslucency = true;
    _showHistoryText = true;
    _showLastSavedHint = true;
    _defaultMode = 'single';
    _tapDelay = 0;
    _requireLongPressNote = false;
    _compactHistory = false;
    _confirmDelete = true;
    _extendedDuration = false;
    _minimalMomentOptions = false;
    _reduceMotion = false;
    _largeText = false;
    _highContrast = false;
    _historyDensity = 'comfortable';

    await _prefs.clear();
    notifyListeners();
  }
}
