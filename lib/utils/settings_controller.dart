import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;

  String _theme = 'dark';
  String _defaultMode = 'two-way';
  String _locale = 'system';
  String _hapticStyle = 'standard';
  String _accentColor = 'blue';
  String _appIconStyle = 'default';
  String _csvDelimiter = ',';
  String _historyDensity = 'comfortable';
  String _privacyLockType = 'system';
  String _clockFont = 'BebasNeue';
  String _sobrietyResetType = 'any';
  String _sobrietyMilestoneTheme = 'science';
  String _toolbarAppearance = 'standard';
  bool _remoteNotices = false;
  bool _reduceMotion = false;
  bool _haptics = true;
  bool _acousticFeedback = true;
  bool _privacyLock = false;
  bool _largeText = false;
  bool _highContrast = false;
  bool _compactHistory = false;
  bool _confirmDelete = true;
  bool _showSeconds = true;
  bool _highlightSeconds = true;
  bool _use24HourFormat = true;
  bool _buttonLabels = true;
  bool _largeControls = false;
  bool _homeMenuPill = true;
  bool _homeMenuAnimations = false;
  bool _enableTranslucency = false;
  bool _extendedDuration = false;
  bool _minimalMomentOptions = false;
  bool _useNumbersInSingle = false;
  bool _resetSingleDaily = false;
  bool _countOnSave = false;
  bool _floatingTimerEnabled = false;
  bool _enableNoteOnClick = false;
  bool _enableSobrietyMode = false;
  bool _showHistoryText = true;
  bool _showLastSavedHint = true;
  bool _adaptiveModeColor = false;
  bool _showGapCards = false;
  bool _godModeUnlocked = false;
  int _tapDelay = 0;
  int _backupReminderDays = 0;
  int _privacyLockDelayMinutes = 0;

  // Getters
  String get theme => _theme;
  String get defaultMode => _defaultMode;
  String get locale => _locale;
  String get hapticStyle => _hapticStyle;
  String get accentColor => _accentColor;
  String get appIconStyle => _appIconStyle;
  String get csvDelimiter => _csvDelimiter;
  String get historyDensity => _historyDensity;
  String get privacyLockType => _privacyLockType;
  String get clockFont => _clockFont;
  String get sobrietyResetType => _sobrietyResetType;
  String get sobrietyMilestoneTheme => _sobrietyMilestoneTheme;
  String get toolbarAppearance => _toolbarAppearance;
  bool get remoteNotices => _remoteNotices;
  bool get reduceMotion => _reduceMotion;
  bool get haptics => _haptics;
  bool get acousticFeedback => _acousticFeedback;
  bool get privacyLock => _privacyLock;
  bool get largeText => _largeText;
  bool get highContrast => _highContrast;
  bool get compactHistory => _compactHistory;
  bool get confirmDelete => _confirmDelete;
  bool get showSeconds => _showSeconds;
  bool get highlightSeconds => _highlightSeconds;
  bool get use24HourFormat => _use24HourFormat;
  bool get buttonLabels => _buttonLabels;
  bool get largeControls => _largeControls;
  bool get homeMenuPill => _homeMenuPill;
  bool get homeMenuAnimations => _homeMenuAnimations;
  bool get enableTranslucency => _enableTranslucency;
  bool get extendedDuration => _extendedDuration;
  bool get minimalMomentOptions => _minimalMomentOptions;
  bool get useNumbersInSingle => _useNumbersInSingle;
  bool get resetSingleDaily => _resetSingleDaily;
  bool get countOnSave => _countOnSave;
  bool get floatingTimerEnabled => _floatingTimerEnabled;
  bool get enableNoteOnClick => _enableNoteOnClick;
  bool get enableSobrietyMode => _enableSobrietyMode;
  bool get showHistoryText => _showHistoryText;
  bool get showLastSavedHint => _showLastSavedHint;
  bool get adaptiveModeColor => _adaptiveModeColor;
  bool get showGapCards => _showGapCards;
  bool get godModeUnlocked => _godModeUnlocked;
  int get tapDelay => _tapDelay;
  int get backupReminderDays => _backupReminderDays;
  int get privacyLockDelayMinutes => _privacyLockDelayMinutes;

  void _loadFromPrefs() {
    _theme = _prefs.getString('m-theme') ?? 'dark';
    _defaultMode = _prefs.getString('m-default-mode') ?? 'two-way';
    _locale = _prefs.getString('m-locale') ?? 'system';
    _hapticStyle = _prefs.getString('haptic_style') ?? 'standard';
    _accentColor = _prefs.getString('m-accent-color') ?? 'blue';
    _appIconStyle = _prefs.getString('app_icon_style') ?? 'default';
    _csvDelimiter = _prefs.getString('csv_delimiter') ?? ',';
    _historyDensity = _prefs.getString('history_density') ?? 'comfortable';
    _privacyLockType = _prefs.getString('m-privacy-lock-type') ?? 'system';
    _clockFont = _prefs.getString('clock_font') ?? 'BebasNeue';
    _sobrietyResetType = _prefs.getString('sobriety_reset_type') ?? 'any';
    _sobrietyMilestoneTheme =
        _prefs.getString('sobriety_milestone_theme') ?? 'science';
    _toolbarAppearance = _prefs.getString('toolbar_appearance') ?? 'standard';
    _remoteNotices = _prefs.getBool('remote_notices') ?? false;
    _reduceMotion = _prefs.getBool('reduce_motion') ?? false;
    _haptics = _prefs.getBool('m-haptics') ?? true;
    _acousticFeedback = _prefs.getBool('acoustic_feedback') ?? true;
    _privacyLock = _prefs.getBool('m-privacy-lock') ?? false;
    _largeText = _prefs.getBool('large_text') ?? false;
    _highContrast = _prefs.getBool('m-high-contrast') ?? false;
    _compactHistory = _prefs.getBool('compact_history') ?? false;
    _confirmDelete = _prefs.getBool('confirm_delete') ?? true;
    _showSeconds = _prefs.getBool('show_seconds') ?? true;
    _highlightSeconds = _prefs.getBool('highlight_seconds') ?? true;
    _use24HourFormat = _prefs.getBool('use_24h_format') ?? true;
    _buttonLabels = _prefs.getBool('button_labels') ?? true;
    _largeControls = _prefs.getBool('large_controls') ?? false;
    _homeMenuPill = _prefs.getBool('home_menu_pill') ?? true;
    _homeMenuAnimations = _prefs.getBool('home_menu_animations') ?? false;
    _enableTranslucency = _prefs.getBool('enable_translucency') ?? false;
    _extendedDuration = _prefs.getBool('extended_duration') ?? false;
    _minimalMomentOptions = _prefs.getBool('minimal_moment_options') ?? false;
    _useNumbersInSingle = _prefs.getBool('use_numbers_in_single') ?? false;
    _resetSingleDaily = _prefs.getBool('reset_single_daily') ?? false;
    _countOnSave = _prefs.getBool('count_on_save') ?? false;
    _floatingTimerEnabled = _prefs.getBool('floating_timer_enabled') ?? false;
    _enableNoteOnClick = _prefs.getBool('enable_note_on_click') ?? false;
    _enableSobrietyMode = _prefs.getBool('enable_sobriety_mode') ?? false;
    _showHistoryText = _prefs.getBool('show_history_text') ?? true;
    _showLastSavedHint = _prefs.getBool('show_last_saved_hint') ?? true;
    _adaptiveModeColor = _prefs.getBool('m-adaptive-color') ?? false;
    _showGapCards = _prefs.getBool('show_gap_cards') ?? false;
    _godModeUnlocked = _prefs.getBool('god_mode_unlocked') ?? false;
    _tapDelay = _prefs.getInt('tap_delay') ?? 0;
    _backupReminderDays = _prefs.getInt('m-backup-reminder-days') ?? 0;
    _privacyLockDelayMinutes = _prefs.getInt('m-privacy-lock-delay') ?? 0;
  }

  // Setters
  Future<void> setTheme(String value) async {
    if (_theme == value) return;
    _theme = value;
    await _prefs.setString('m-theme', value);
    await _prefs.setString('theme', value);
    notifyListeners();
  }

  Future<void> setDefaultMode(String value) async {
    if (_defaultMode == value) return;
    _defaultMode = value;
    await _prefs.setString('m-default-mode', value);
    notifyListeners();
  }

  Future<void> setLocale(String value) async {
    if (_locale == value) return;
    _locale = value;
    await _prefs.setString('m-locale', value);
    notifyListeners();
  }

  Future<void> setHapticStyle(String value) async {
    if (_hapticStyle == value) return;
    _hapticStyle = value;
    await _prefs.setString('haptic_style', value);
    notifyListeners();
  }

  Future<void> setAccentColor(String value) async {
    if (_accentColor == value) return;
    _accentColor = value;
    await _prefs.setString('m-accent-color', value);
    notifyListeners();
  }

  Future<void> setAppIconStyle(String value) async {
    if (_appIconStyle == value) return;
    _appIconStyle = value;
    await _prefs.setString('app_icon_style', value);
    notifyListeners();
  }

  Future<void> setCsvDelimiter(String value) async {
    if (_csvDelimiter == value) return;
    _csvDelimiter = value;
    await _prefs.setString('csv_delimiter', value);
    notifyListeners();
  }

  Future<void> setHistoryDensity(String value) async {
    if (_historyDensity == value) return;
    _historyDensity = value;
    await _prefs.setString('history_density', value);
    notifyListeners();
  }

  Future<void> setPrivacyLockType(String value) async {
    if (_privacyLockType == value) return;
    _privacyLockType = value;
    await _prefs.setString('m-privacy-lock-type', value);
    notifyListeners();
  }

  Future<void> setClockFont(String value) async {
    if (_clockFont == value) return;
    _clockFont = value;
    await _prefs.setString('clock_font', value);
    notifyListeners();
  }

  Future<void> setSobrietyResetType(String value) async {
    if (_sobrietyResetType == value) return;
    _sobrietyResetType = value;
    await _prefs.setString('sobriety_reset_type', value);
    notifyListeners();
  }

  Future<void> setSobrietyMilestoneTheme(String value) async {
    if (_sobrietyMilestoneTheme == value) return;
    _sobrietyMilestoneTheme = value;
    await _prefs.setString('sobriety_milestone_theme', value);
    notifyListeners();
  }

  Future<void> setToolbarAppearance(String value) async {
    if (_toolbarAppearance == value) return;
    _toolbarAppearance = value;
    await _prefs.setString('toolbar_appearance', value);
    notifyListeners();
  }

  Future<void> setRemoteNotices(bool value) async {
    if (_remoteNotices == value) return;
    _remoteNotices = value;
    await _prefs.setBool('remote_notices', value);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    await _prefs.setBool('reduce_motion', value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    if (_haptics == value) return;
    _haptics = value;
    await _prefs.setBool('m-haptics', value);
    notifyListeners();
  }

  Future<void> setAcousticFeedback(bool value) async {
    if (_acousticFeedback == value) return;
    _acousticFeedback = value;
    await _prefs.setBool('acoustic_feedback', value);
    notifyListeners();
  }

  Future<void> setPrivacyLock(bool value) async {
    if (_privacyLock == value) return;
    _privacyLock = value;
    await _prefs.setBool('m-privacy-lock', value);
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
    await _prefs.setBool('m-high-contrast', value);
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

  Future<void> setUse24HourFormat(bool value) async {
    if (_use24HourFormat == value) return;
    _use24HourFormat = value;
    await _prefs.setBool('use_24h_format', value);
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

  Future<void> setUseNumbersInSingle(bool value) async {
    if (_useNumbersInSingle == value) return;
    _useNumbersInSingle = value;
    await _prefs.setBool('use_numbers_in_single', value);
    notifyListeners();
  }

  Future<void> setResetSingleDaily(bool value) async {
    if (_resetSingleDaily == value) return;
    _resetSingleDaily = value;
    await _prefs.setBool('reset_single_daily', value);
    notifyListeners();
  }

  Future<void> setCountOnSave(bool value) async {
    if (_countOnSave == value) return;
    _countOnSave = value;
    await _prefs.setBool('count_on_save', value);
    notifyListeners();
  }

  Future<void> setFloatingTimerEnabled(bool value) async {
    if (_floatingTimerEnabled == value) return;
    _floatingTimerEnabled = value;
    await _prefs.setBool('floating_timer_enabled', value);
    notifyListeners();
  }

  Future<void> setEnableNoteOnClick(bool value) async {
    if (_enableNoteOnClick == value) return;
    _enableNoteOnClick = value;
    await _prefs.setBool('enable_note_on_click', value);
    notifyListeners();
  }

  Future<void> setEnableSobrietyMode(bool value) async {
    if (_enableSobrietyMode == value) return;
    _enableSobrietyMode = value;
    await _prefs.setBool('enable_sobriety_mode', value);
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

  Future<void> setAdaptiveModeColor(bool value) async {
    if (_adaptiveModeColor == value) return;
    _adaptiveModeColor = value;
    await _prefs.setBool('m-adaptive-color', value);
    notifyListeners();
  }

  Future<void> setShowGapCards(bool value) async {
    if (_showGapCards == value) return;
    _showGapCards = value;
    await _prefs.setBool('show_gap_cards', value);
    notifyListeners();
  }

  Future<void> setGodModeUnlocked(bool value) async {
    if (_godModeUnlocked == value) return;
    _godModeUnlocked = value;
    await _prefs.setBool('god_mode_unlocked', value);
    notifyListeners();
  }

  Future<void> setTapDelay(int value) async {
    if (_tapDelay == value) return;
    _tapDelay = value;
    await _prefs.setInt('tap_delay', value);
    notifyListeners();
  }

  Future<void> setBackupReminderDays(int value) async {
    if (_backupReminderDays == value) return;
    _backupReminderDays = value;
    await _prefs.setInt('m-backup-reminder-days', value);
    notifyListeners();
  }

  Future<void> setPrivacyLockDelayMinutes(int value) async {
    if (_privacyLockDelayMinutes == value) return;
    _privacyLockDelayMinutes = value;
    await _prefs.setInt('m-privacy-lock-delay', value);
    notifyListeners();
  }
}
