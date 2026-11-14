import 'package:flutter/material.dart';
import 'package:notekar/utils/l10n_utils.dart';

/// Centralized Text Copy Catalog for NoteKar.
///
/// Houses all canonical UI strings, titles, action labels, guidance tooltips,
/// and accessibility narratives in a single, accessible repository.
///
/// Enables seamless copy editing, consistency audits, and provides a direct
/// bridge to `.localized(context)` for multilingual localization.
class AppStrings {
  AppStrings._();

  // ===========================================================================
  // 1. General & Common Actions
  // ===========================================================================
  static const String appName = 'NoteKar';
  static const String cancel = 'Cancel';
  static const String done = 'Done';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String edit = 'Edit';
  static const String share = 'Share';
  static const String copy = 'Copy';
  static const String copied = 'Copied to clipboard';
  static const String loading = 'Loading...';
  static const String search = 'Search...';
  static const String clear = 'Clear';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String dismiss = 'Dismiss';

  // ===========================================================================
  // 2. Home Screen, Chronometer & Modes
  // ===========================================================================
  static const String singleMode = 'Single';
  static const String twoWayMode = 'Two-Way';
  static const String history = 'History';
  static const String settings = 'Settings';
  static const String allModes = 'All';
  static const String tapToLog = 'Tap to log · Hold to add a note';
  static const String tapToStart = 'Tap to start · Hold to add a note';
  static const String tapToEnd = 'Tap to end · Hold to add a note';
  static const String pressBackAgain = 'Press back again to exit';
  static const String sessionActiveInFlow =
      'Active session in flow • Tap to inspect';

  // ===========================================================================
  // 3. Routine Habits & Checkpoints
  // ===========================================================================
  static const String habitCheckpoints = 'Habit Checkpoints';
  static const String habitsTitle = 'Habits';
  static const String insights = 'Insights';
  static const String logCheckpoint = 'Log Checkpoint';
  static const String editHabit = 'Edit Habit';
  static const String deleteHabit = 'Delete Habit';
  static const String manageHabitSubtitle = 'Manage this habit checkpoint';
  static const String habitSessionStarted = 'session started!';
  static const String habitSessionLogged = 'session logged';
  static const String habitRoutineCompleted =
      'Routine target reached! Tap to end session';
  static const String habitConsistencyBreakdown = 'Habit Consistency Breakdown';
  static const String stableRoutine = 'Stable Routine';
  static const String earlyRhythm = 'Early Rhythm';
  static const String buildingMomentum = 'Building Momentum';
  static const String last7Days = 'Last 7 Days';
  static const String noCheckpointsYet =
      'No checkpoint logs recorded for this habit yet.\nTap "Log Now" to record your first checkpoint!';

  // ===========================================================================
  // 4. Official Bulletins & Notices
  // ===========================================================================
  static const String officialBulletins = 'Official Bulletins';
  static const String fullScreen = 'Full Screen';
  static const String viewNotice = 'View Notice';
  static const String bulletinDismissed = 'Bulletin dismissed';
  static const String cachedBulletins = 'Offline — showing cached bulletins';
  static const String bulletinsUpdated = 'Bulletins updated';
  static const String neverChecked = 'Never checked';

  // ===========================================================================
  // 5. Goals & Time Targets
  // ===========================================================================
  static const String goalsAndTargets = 'Goals & Targets';
  static const String createGoal = 'Create Goal';
  static const String editGoal = 'Edit Goal';
  static const String targetDuration = 'Target Duration';
  static const String dailyTarget = 'Daily Target';
  static const String weeklyTarget = 'Weekly Target';

  // ===========================================================================
  // 6. Security, Vault & Sandbox Storage
  // ===========================================================================
  static const String zeroKnowledgeVault = 'Zero-Knowledge Vault';
  static const String enterPin = 'Enter PIN';
  static const String pinSetSuccess = 'In-App PIN set successfully.';
  static const String storageError = 'Storage error: Moment not saved';
  static const String backupSuccess = 'Vault backup exported successfully';

  // ===========================================================================
  // Helper for localized context access
  // ===========================================================================
  static String tr(String text, BuildContext context) =>
      text.localized(context);
}
