part of '../note_kar_home.dart';

extension _HomeResetLifecycleExtension on _NoteKarHomeState {
  Future<void> _resetAll() async {
    update(() {
      _entries = [];
      _lastId = null;
      _lastDeletedPreview = null;
      _inout = 'in';
      _sessionStart = null;
      _sobrietyCustomStart = null;
      _streakShields = 1;
    });

    await _prefs?.remove('m-inout');
    await _prefs?.remove('m-ses');
    await _prefs?.remove('sobriety_custom_start_ms');
    await _prefs?.setInt('streak_shields', 1);
    await _prefs?.setInt('last_shield_granted_threshold', 0);
    await _prefs?.remove('recent_note_searches');
    await _prefs?.remove('notekar.categories_v1');
    await _prefs?.remove('m-last-backup-at');
    await _repository.clearAll();
    await _repository.clearTrash();
    _trashNotifier.value = [];
    update(() => _nextId = _repository.getNextId());
    unawaited(_updateAndroidWidget());
  }

  Future<void> _factoryReset() async {
    final prefs = _prefs;
    update(() {
      _factoryResetVisible = true;
      _factoryResetComplete = false;
      _factoryResetProgress = 0.0;
      _factoryResetText = 'Preparing Factory Reset...';
      _factoryResetSubText = 'Initializing secure wipe sequence...';
      _factoryResetIcon = Icons.settings_suggest_rounded;
      _factoryResetWelcomePrefs = prefs;
      _entries = [];
      _lastId = null;
      _lastDeletedPreview = null;
      _lastTapPosition = null;
      _theme = 'dark';
      _defaultMode = 'two-way';
      _mode = 'two-way';
      _inout = 'in';
      _sessionStart = null;
      _tapDelay = 0;
      _accentColor = 'blue';
      _appIconStyle = 'default';
      _hapticStyle = 'standard';
      _historyDensity = 'comfortable';
      _privacyLock = false;
      _privacyUnlocked = false;
      _backupReminderDays = 0;
      _lastBackupAt = null;
      _remoteNotices = false;
      _reduceMotion = false;
      _haptics = true;
      _largeText = false;
      _highContrast = false;
      _confirmDelete = false;
      _showSeconds = true;
      _highlightSeconds = true;
      _use24HourFormat = true;
      _buttonLabels = true;
      _largeControls = false;
      _homeMenuPill = true;
      _homeMenuAnimations = false;
      _showHistoryText = true;
      _showLastSavedHint = true;
      _extendedDuration = false;
      _enableTranslucency = true;
      _minimalMomentOptions = false;
      _useNumbersInSingle = false;
      _resetSingleDaily = false;
      _countOnSave = false;
      _privacyLockDelayMinutes = 0;
      _updateStatus = 'v$appVersion - Check for available updates';
      _lastUpdateCheckedAt = null;
      _nextId = 1;
      _enableSobrietyMode = false;
      _sobrietyResetType = 'any';
      _sobrietyCustomStart = null;
      _sobrietyMilestoneTheme = 'science';
      _streakShields = 0;
    });
    _applySystemUiStyle();

    // Stage 1: Prep (1s)
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    update(() {
      _factoryResetProgress = 0.20;
      _factoryResetText = 'Deleting Database Records...';
      _factoryResetSubText =
          'Securely clearing moments, notes, and trash data...';
      _factoryResetIcon = Icons.delete_sweep_rounded;
    });

    // Stage 2: Clear DB (1.2s)
    await _repository.clearAll();
    await _repository.clearTrash();
    _trashNotifier.value = [];
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    update(() {
      _factoryResetProgress = 0.55;
      _factoryResetText = 'Purging Shared Preferences...';
      _factoryResetSubText =
          'Resetting personalization settings and secure keys...';
      _factoryResetIcon = Icons.lock_reset_rounded;
    });

    // Stage 3: Wipe Prefs (1.2s)
    if (prefs != null) {
      for (final key in [
        'notekar.nextId',
        _NoteKarHomeState._welcomeSeenKey,
        _NoteKarHomeState._lastSeenVersionKey,
        'enable_sobriety_mode',
        'sobriety_reset_type',
        'sobriety_custom_start_ms',
        'sobriety_milestone_theme',
        'streak_shields',
        'last_shield_granted_threshold',
        'notekar.sobrietyWalkthroughSeen_v6',
        'notekar.singleNumberingWalkthroughSeen_v7',
        'notekar.appIconsWalkthroughSeen_v8',
        'notekar.securityWalkthroughSeen_v5',
        'notekar.networkWalkthroughSeen_v5',
        'notekar.remindersWalkthroughSeen',
        'notekar.autoStartCardDismissed',
        'm-locale',
        'm-theme',
        'm-default-mode',
        'm-mode',
        'm-inout',
        'm-ses',
        'm-delay',
        'm-accent-color',
        'm-app-icon-style',
        'm-haptic-style',
        'm-history-density',
        'm-privacy-lock',
        'm-privacy-lock-type',
        'm-backup-reminder-days',
        'm-last-backup-at',
        'm-last-backup-reminder-day',
        'm-remote-notices',
        'm-reduce-motion',
        'm-haptics',
        'm-reduced-haptics',
        'm-acoustic-feedback',
        'm-large-text',
        'm-high-contrast',
        'm-compact-history',
        'm-confirm-delete',
        'm-show-seconds',
        'm-highlight-seconds',
        'm-button-labels',
        'm-large-controls',
        'm-home-menu-pill',
        'm-home-menu-animations',
        'm-show-history-text',
        'm-show-last-saved-hint',
        'm-extended-duration',
        'm-translucency',
        'm-minimal-moment-options',
        'm-use-numbers-in-single',
        'm-reset-single-daily',
        'm-count-on-save',
        'm-privacy-lock-delay',
        'm-update-status',
        'm-last-update-check',
        'reminder_daily_enabled',
        'reminder_daily_hour',
        'reminder_daily_minute',
        'reminder_daily_body',
        'reminder_inactivity_enabled',
        'reminder_inactivity_interval_mins',
        'reminder_weekly_enabled',
        'reminder_weekly_days',
        'reminder_weekly_hour',
        'reminder_weekly_minute',
        'reminder_weekly_body',
        'reminder_monthly_enabled',
        'reminder_monthly_day',
        'reminder_monthly_hour',
        'reminder_monthly_minute',
        'reminder_monthly_body',
        'reminder_reflection_enabled',
        'reminder_reflection_interval_mins',
        'reminder_reflection_sound',
        'reminder_reflection_body',
        'reminder_reflection_start_hour',
        'reminder_reflection_start_minute',
        'reminder_reflection_end_hour',
        'reminder_reflection_end_minute',
        'enable_note_on_click',
        'obfuscate_in_recents',
        'show_persistent_notification',
        'recent_settings_searches',
        'recent_note_searches',
        'time_audit_sleep_hours',
        'time_audit_essentials_hours',
        'notekar.batteryOptimizationCardDismissed',
        'notekar.categories_v1',
        'god_mode_unlocked',
        'use_12h_format',
        'm-use-12h',
        'notekar.commits_cache',
        'notekar.commits_cache_time',
      ]) {
        await prefs.remove(key);
      }
    }
    await _setAppIconStyle('default', showToast: false);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    update(() {
      _factoryResetProgress = 0.85;
      _factoryResetText = 'Cancelling Scheduled Alarms...';
      _factoryResetSubText = 'De-registering background broadcast receivers...';
      _factoryResetIcon = Icons.alarm_off_rounded;
    });

    // Stage 4: Wiping background alarms & notices (1.0s)
    try {
      await _NoteKarHomeState._fileChannel.invokeMethod<void>(
        'configureRemoteNotices',
        {'enabled': false, 'feedUrl': notificationFeed},
      );
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    update(() {
      _factoryResetProgress = 0.96;
      _factoryResetText = 'Finalizing System Recovery...';
      _factoryResetSubText =
          'Wipe completed. Setting up system for a clean launch...';
      _factoryResetIcon = Icons.published_with_changes_rounded;
    });

    // Stage 5: Done (0.6s)
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    update(() {
      _factoryResetProgress = 1.0;
      _factoryResetComplete = true;
      _factoryResetText = 'Restore complete';
      _factoryResetSubText = 'Click Start to begin new setup';
      _factoryResetIcon = Icons.check_circle_rounded;
    });
    unawaited(_updateAndroidWidget());
  }

  Future<void> _finishFactoryResetOverlay() async {
    final prefs = _factoryResetWelcomePrefs;
    if (mounted) {
      NoteKarApp.of(context)?.setLocale('system');
    }
    if (mounted && prefs != null) {
      unawaited(_showWelcomeIfNeeded(prefs));
    }
    // Delay setting overlay visibility to false by 50ms so navigation transaction has started
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      update(() {
        _locale = 'system';
        _factoryResetVisible = false;
      });
    }
  }

  Future<void> _resetSettingsOnly() async {
    update(() {
      _theme = 'dark';
      _defaultMode = 'two-way';
      _tapDelay = 0;
      _accentColor = 'blue';
      _appIconStyle = 'default';
      _hapticStyle = 'standard';
      _historyDensity = 'comfortable';
      _privacyLock = false;
      _backupReminderDays = 0;
      _remoteNotices = false;
      _reduceMotion = false;
      _haptics = true;
      _acousticFeedback = true;
      _largeText = false;
      _highContrast = false;
      _confirmDelete = false;
      _showSeconds = true;
      _highlightSeconds = true;
      _buttonLabels = true;
      _largeControls = false;
      _homeMenuPill = true;
      _homeMenuAnimations = false;
      _showHistoryText = true;
      _showLastSavedHint = true;
      _extendedDuration = false;
      _enableTranslucency = true;
      _minimalMomentOptions = false;
      _useNumbersInSingle = false;
      _resetSingleDaily = false;
      _countOnSave = false;
      _privacyLockDelayMinutes = 0;
      _locale = 'system';
      _enableSobrietyMode = false;
      _sobrietyResetType = 'any';
      _sobrietyCustomStart = null;
      _sobrietyMilestoneTheme = 'science';
      _streakShields = 0;
    });
    await _prefs?.setBool('enable_sobriety_mode', _enableSobrietyMode);
    await _prefs?.setString('sobriety_reset_type', _sobrietyResetType);
    await _prefs?.remove('sobriety_custom_start_ms');
    await _prefs?.setString(
      'sobriety_milestone_theme',
      _sobrietyMilestoneTheme,
    );
    await _prefs?.setInt('streak_shields', 0);
    await _prefs?.setInt('last_shield_granted_threshold', 0);
    await _prefs?.remove('notekar.sobrietyWalkthroughSeen_v6');
    await _prefs?.remove('notekar.singleNumberingWalkthroughSeen_v7');
    await _prefs?.remove('notekar.appIconsWalkthroughSeen_v8');
    await _prefs?.setString('m-theme', _theme);
    await _prefs?.setString('m-default-mode', _defaultMode);
    await _prefs?.setInt('m-delay', _tapDelay);
    await _prefs?.setString('m-accent-color', _accentColor);
    await _prefs?.setString('m-app-icon-style', _appIconStyle);
    await _prefs?.setString('m-haptic-style', _hapticStyle);
    await _prefs?.setString('m-history-density', _historyDensity);
    await _prefs?.setBool('m-privacy-lock', _privacyLock);
    await _prefs?.setInt('m-backup-reminder-days', _backupReminderDays);
    await _prefs?.setBool('m-remote-notices', _remoteNotices);
    await _prefs?.setBool('m-reduce-motion', _reduceMotion);
    await _prefs?.setBool('m-haptics', _haptics);
    await _prefs?.remove('m-reduced-haptics');
    await _prefs?.setBool('m-large-text', _largeText);
    await _prefs?.setBool('m-high-contrast', _highContrast);
    await _prefs?.setBool('m-confirm-delete', _confirmDelete);
    await _prefs?.setBool('m-show-seconds', _showSeconds);
    await _prefs?.setBool('m-highlight-seconds', _highlightSeconds);
    await _prefs?.setBool('m-use-24-hour', _use24HourFormat);
    await _prefs?.setBool('m-button-labels', _buttonLabels);
    await _prefs?.setBool('m-largeControls', _largeControls);
    await _prefs?.setBool('m-home-menu-pill', _homeMenuPill);
    await _prefs?.setBool('m-home-menu-animations', _homeMenuAnimations);
    await _prefs?.setBool('m-show-history-text', _showHistoryText);
    await _prefs?.setBool('m-show-last-saved-hint', _showLastSavedHint);
    await _prefs?.setBool('m-extended-duration', _extendedDuration);
    await _prefs?.setBool('m-minimal-moment-options', _minimalMomentOptions);
    await _prefs?.setBool('m-use-numbers-in-single', _useNumbersInSingle);
    await _prefs?.setBool('m-reset-single-daily', _resetSingleDaily);
    await _prefs?.setBool('m-count-on-save', _countOnSave);
    await _prefs?.setBool('m-translucency', _enableTranslucency);
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    await _prefs?.setString('m-locale', _locale);
    await _prefs?.remove('reminder_daily_enabled');
    await _prefs?.remove('reminder_daily_hour');
    await _prefs?.remove('reminder_daily_minute');
    await _prefs?.remove('reminder_daily_body');
    await _prefs?.remove('reminder_inactivity_enabled');
    await _prefs?.remove('reminder_inactivity_interval_mins');
    await _prefs?.remove('reminder_weekly_enabled');
    await _prefs?.remove('reminder_weekly_days');
    await _prefs?.remove('reminder_weekly_hour');
    await _prefs?.remove('reminder_weekly_minute');
    await _prefs?.remove('reminder_weekly_body');
    await _prefs?.remove('reminder_monthly_enabled');
    await _prefs?.remove('reminder_monthly_day');
    await _prefs?.remove('reminder_monthly_hour');
    await _prefs?.remove('reminder_monthly_minute');
    await _prefs?.remove('reminder_monthly_body');
    await _prefs?.remove('reminder_reflection_enabled');
    await _prefs?.remove('reminder_reflection_interval_mins');
    await _prefs?.remove('reminder_reflection_sound');
    await _prefs?.remove('reminder_reflection_body');
    await _prefs?.remove('reminder_reflection_start_hour');
    await _prefs?.remove('reminder_reflection_start_minute');
    await _prefs?.remove('reminder_reflection_end_hour');
    await _prefs?.remove('reminder_reflection_end_minute');
    await _prefs?.remove('time_audit_sleep_hours');
    await _prefs?.remove('time_audit_essentials_hours');
    await _prefs?.remove('notekar.autoStartCardDismissed');
    await _prefs?.remove('notekar.batteryOptimizationCardDismissed');
    await _prefs?.remove('notekar.categories_v1');
    await _prefs?.remove('recent_settings_searches');
    await _prefs?.remove('recent_note_searches');
    await _prefs?.remove('enable_note_on_click');
    await _prefs?.remove('obfuscate_in_recents');
    await _prefs?.remove('show_persistent_notification');
    await _prefs?.remove('use_12h_format');
    await _prefs?.remove('m-use-12h');
    await _setAppIconStyle('default', showToast: false);
    if (mounted) {
      NoteKarApp.of(context)?.setLocale(_locale);
    }
    try {
      await _NoteKarHomeState._fileChannel.invokeMethod<void>(
        'configureRemoteNotices',
        {'enabled': false, 'feedUrl': notificationFeed},
      );
    } catch (_) {}
    _applySystemUiStyle();
  }

  Future<void> _restoreSettings(Map<String, Object> snapshot) async {
    update(() {
      _theme = snapshot['theme'] as String;
      _defaultMode = snapshot['defaultMode'] as String;
      _tapDelay = snapshot['tapDelay'] as int;
      _accentColor = snapshot['accentColor'] as String;
      _appIconStyle = snapshot['appIconStyle'] as String;
      _hapticStyle = snapshot['hapticStyle'] as String;
      _historyDensity = snapshot['historyDensity'] as String;
      _privacyLock = snapshot['privacyLock'] as bool;
      _backupReminderDays = snapshot['backupReminderDays'] as int;
      _remoteNotices = snapshot['remoteNotices'] as bool;
      _reduceMotion = snapshot['reduceMotion'] as bool;
      _haptics = _hapticStyle != 'off';
      _largeText = snapshot['largeText'] as bool;
      _highContrast = snapshot['highContrast'] as bool;
      _confirmDelete = snapshot['confirmDelete'] as bool;
      _showSeconds = snapshot['showSeconds'] as bool;
      _highlightSeconds = snapshot['highlightSeconds'] as bool;
      _buttonLabels = snapshot['buttonLabels'] as bool;
      _largeControls = snapshot['largeControls'] as bool;
      _homeMenuPill = snapshot['homeMenuPill'] as bool;
      _homeMenuAnimations = snapshot['homeMenuAnimations'] as bool;
      _showHistoryText = snapshot['showHistoryText'] as bool;
      _showLastSavedHint = snapshot['showLastSavedHint'] as bool;
      _extendedDuration = snapshot['extendedDuration'] as bool? ?? false;
      _enableTranslucency = snapshot['enableTranslucency'] as bool? ?? true;
      _minimalMomentOptions =
          snapshot['minimalMomentOptions'] as bool? ?? false;
      _useNumbersInSingle = snapshot['useNumbersInSingle'] as bool? ?? false;
      _resetSingleDaily = snapshot['resetSingleDaily'] as bool? ?? false;
      _countOnSave = snapshot['countOnSave'] as bool? ?? false;
      _privacyLockDelayMinutes = snapshot['privacyLockDelayMinutes'] as int;
    });
    await _prefs?.setString('m-theme', _theme);
    await _prefs?.setString('m-default-mode', _defaultMode);
    await _prefs?.setInt('m-delay', _tapDelay);
    await _prefs?.setString('m-accent-color', _accentColor);
    await _prefs?.setString('m-app-icon-style', _appIconStyle);
    await _prefs?.setString('m-haptic-style', _hapticStyle);
    await _prefs?.setString('m-history-density', _historyDensity);
    await _prefs?.setBool('m-privacy-lock', _privacyLock);
    await _prefs?.setInt('m-backup-reminder-days', _backupReminderDays);
    await _prefs?.setBool('m-remote-notices', _remoteNotices);
    await _prefs?.setBool('m-reduce-motion', _reduceMotion);
    await _prefs?.setBool('m-haptics', _haptics);
    await _prefs?.remove('m-reduced-haptics');
    await _prefs?.setBool('m-large-text', _largeText);
    await _prefs?.setBool('m-high-contrast', _highContrast);
    await _prefs?.setBool('m-confirm-delete', _confirmDelete);
    await _prefs?.setBool('m-show-seconds', _showSeconds);
    await _prefs?.setBool('m-highlight-seconds', _highlightSeconds);
    await _prefs?.setBool('m-button-labels', _buttonLabels);
    await _prefs?.setBool('m-large-controls', _largeControls);
    await _prefs?.setBool('m-home-menu-pill', _homeMenuPill);
    await _prefs?.setBool('m-home-menu-animations', _homeMenuAnimations);
    await _prefs?.setBool('m-show-history-text', _showHistoryText);
    await _prefs?.setBool('m-show-last-saved-hint', _showLastSavedHint);
    await _prefs?.setBool('m-extended-duration', _extendedDuration);
    await _prefs?.setBool('m-minimal-moment-options', _minimalMomentOptions);
    await _prefs?.setBool('m-use-numbers-in-single', _useNumbersInSingle);
    await _prefs?.setBool('m-reset-single-daily', _resetSingleDaily);
    await _prefs?.setBool('m-count-on-save', _countOnSave);
    await _prefs?.setBool('m-translucency', _enableTranslucency);
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    _applySystemUiStyle();
    _showToast('Settings restored');
    unawaited(_updateAndroidWidget());
  }
}
