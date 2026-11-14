/// Centralized SharedPreferences & Storage Keys for NoteKar.
///
/// Provides compile-time checked constants for all local preference entries,
/// preventing fragile string typos, duplicate lookups, and ensuring clean
/// architectural maintainability for developers and security auditors.
abstract final class PrefKeys {
  // ===========================================================================
  // Core System & Appearance
  // ===========================================================================
  static const String theme = 'm-theme';
  static const String accentColor = 'm-accent-color';
  static const String adaptiveColor = 'm-adaptive-color';
  static const String legacyAdaptiveColor = 'adaptive_mode_color';
  static const String highContrast = 'm-high-contrast';
  static const String translucency = 'm-translucency';
  static const String toolbarAppearance = 'm-toolbar-appearance';
  static const String largeControls = 'm-large-controls';
  static const String showLabels = 'm-show-labels';
  static const String acousticFeedback = 'm-sound';
  static const String hapticFeedback = 'm-haptics';
  static const String hapticIntensity = 'm-haptic-intensity';

  // ===========================================================================
  // Session & Chronometer Tracking
  // ===========================================================================
  static const String mode = 'm-mode';
  static const String legacyMode = 'mode';
  static const String sessionStart = 'm-ses';
  static const String inout = 'm-inout';
  static const String activeCategory = 'm-active-cat';
  static const String activeGoalId = 'm-active-goal-id';
  static const String activeHabitPresetId = 'm-active-habit-preset-id';
  static const String sessionTargetDurationMins =
      'm-session-target-duration-mins';
  static const String sessionPauseTimestamp = 'm-session-paused-at';
  static const String isSessionPaused = 'm-session-is-paused';

  // ===========================================================================
  // Habits & Routine Checkpoints
  // ===========================================================================
  static const String showCheckpointsOnHome =
      'notekar.show_checkpoints_on_home';
  static const String habitCheckpointsData = 'notekar.habit_checkpoints_data';
  static const String habitActiveDays = 'notekar.habit_active_days_';

  // ===========================================================================
  // Goals, Targets & Analytics
  // ===========================================================================
  static const String goalsStorageKey = 'notekar_goals_v2';
  static const String dailyTargetMinutes = 'm-daily-target-minutes';
  static const String weeklyTargetMinutes = 'm-weekly-target-minutes';

  // ===========================================================================
  // Security, Vault & Privacy
  // ===========================================================================
  static const String appLockEnabled = 'm-app-lock';
  static const String biometricAuthEnabled = 'm-biometric-auth';
  static const String privacyOverlayBlur = 'm-privacy-blur';
  static const String vaultSalt = 'notekar_vault_salt_v2';
}
