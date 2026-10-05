part of '../note_kar_home.dart';

extension _HomeBackupLifecycleExtension on _NoteKarHomeState {
  String _csvExport({DateTime? since}) {
    final exportedAt = DateTime.now().toIso8601String();
    final d = _csvDelimiter;
    final buffer = StringBuffer(
      'app${d}version${d}exported_at${d}id${d}timestamp${d}iso${d}date${d}time${d}type${d}note\n',
    );
    final rows =
        _entries
            .where(
              (entry) =>
                  since == null ||
                  DateTime.fromMillisecondsSinceEpoch(
                    entry.timestamp,
                  ).isAfter(since),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (final e in rows) {
      final iso = DateTime.fromMillisecondsSinceEpoch(
        e.timestamp,
      ).toIso8601String();
      final escapedNote = e.note.replaceAll('"', '""');
      buffer.writeln(
        '"NoteKar"$d"$appVersion"$d"$exportedAt"$d${e.id}$d${e.timestamp}$d'
        '"$iso"$d"${e.date}"$d"${timeOnly(e.timestamp)}"$d"${e.type}"$d'
        '"$escapedNote"',
      );
    }
    return buffer.toString();
  }

  String _jsonExport() {
    final rows = [..._entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'NoteKar',
      'version': appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': rows
          .map(
            (e) => {
              ...e.toJson(),
              'iso': DateTime.fromMillisecondsSinceEpoch(
                e.timestamp,
              ).toIso8601String(),
            },
          )
          .toList(),
    });
  }

  String _backupExport() {
    final rows = [..._entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'NoteKar',
      'kind': 'backup',
      'version': appVersion,
      'build': kAppBuildNumber,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'theme': _theme,
        'defaultMode': _defaultMode,
        'tapDelay': _tapDelay,
        'accentColor': _accentColor,
        'appIconStyle': _appIconStyle,
        'hapticStyle': _hapticStyle,
        'historyDensity': _historyDensity,
        'backupReminderDays': _backupReminderDays,
        'homeMenuPill': _homeMenuPill,
        'homeMenuAnimations': _homeMenuAnimations,
        'showHistoryText': _showHistoryText,
        'privacyLockDelayMinutes': _privacyLockDelayMinutes,
      },
      'entries': rows
          .map(
            (e) => {
              ...e.toJson(),
              'iso': DateTime.fromMillisecondsSinceEpoch(
                e.timestamp,
              ).toIso8601String(),
            },
          )
          .toList(),
    });
  }

  Future<bool> _exportFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      await _NoteKarHomeState._fileChannel.invokeMethod<String>(
        'saveTextFile',
        {'fileName': fileName, 'content': content, 'mimeType': mimeType},
      );

      if (mounted) _showToast('Export saved to Downloads');
      return true;
    } catch (_) {
      if (mounted) _showToast('Export failed. Try again.', warning: true);
      return false;
    }
  }

  Future<Directory> _getLocalBackupDir() async {
    const channel = MethodChannel('notekar/files');
    final dataDir = await channel.invokeMethod<String>('appDataDir');
    final path = dataDir ?? Directory.systemTemp.path;
    final dir = Directory('$path/local_backups');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _saveLocalBackup(String content) async {
    try {
      final dir = await _getLocalBackupDir();
      final dateStr = exportDateStamp();
      final targetPath = '${dir.path}/notekar-backup-$dateStr.json';
      final tempFile = File('$targetPath.tmp');

      // 1. Atomic write to temporary file first
      await tempFile.writeAsString(content, flush: true);
      await tempFile.rename(targetPath);

      // 2. Automated retention pruning (keep latest 15 local backups)
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<File> backupFiles = entities
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      if (backupFiles.length > 15) {
        backupFiles.sort((a, b) {
          final aTime = a.lastModifiedSync();
          final bTime = b.lastModifiedSync();
          return bTime.compareTo(aTime);
        });

        for (int i = 15; i < backupFiles.length; i++) {
          try {
            await backupFiles[i].delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      developer.log('Error saving local backup: $e');
    }
  }

  Future<void> _createQuickLocalBackup() async {
    try {
      final content = _backupExport();
      await _saveLocalBackup(content);
      _showToast('Quick local backup created');
      final now = DateTime.now().millisecondsSinceEpoch;
      update(() => _lastBackupAt = now);
      await _prefs?.setInt('m-last-backup-at', now);
    } catch (_) {
      _showToast('Failed to create local backup', warning: true);
    }
  }

  Future<void> _exportBackupFile() async {
    final content = _backupExport();
    await _saveLocalBackup(content);

    final ok = await _exportFile(
      fileName: 'notekar-backup-${exportDateStamp()}.json',
      content: content,
      mimeType: 'application/json',
    );

    if (!ok) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    update(() => _lastBackupAt = now);
    await _prefs?.setInt('m-last-backup-at', now);
  }

  Future<void> _importBackupFile() async {
    String? content;

    try {
      content = await _NoteKarHomeState._fileChannel.invokeMethod<String>(
        'openTextFile',
        {'mimeType': '*/*'},
      );
    } catch (_) {
      _showToast('Could not open file', warning: true);
      return;
    }

    if (content == null || content.trim().isEmpty) {
      _showToast('Import cancelled', warning: true);
      return;
    }

    await _restoreBackupFromString(content);
  }

  Future<bool> _restoreBackupFromString(String content) async {
    try {
      final importTask = developer.TimelineTask()
        ..start('notekar.backup_import');
      var validation = developer.Timeline.timeSync(
        'notekar.backup_import.validate',
        () => validateNoteKarBackupContent(content),
      );
      if (!validation.isValid) {
        final migration = MigrationImportService.parseMigrationContent(content);
        if (migration.success && migration.moments.isNotEmpty) {
          validation = BackupValidationResult.valid(
            entries: migration.moments,
            settings: const {},
            exportedAt: DateTime.now(),
          );
        } else {
          importTask.finish();
          final errorMessage =
              migration.errorMessage ??
              validation.error ??
              'Invalid backup or migration file.';
          _logger.warning('Backup/migration validation failed: $errorMessage');
          _showToast(errorMessage, warning: true);
          return false;
        }
      }

      final imported = validation.entries;
      final dryRun = buildBackupDryRunSummary(
        validation: validation,
        existingEntries: _entries,
      );
      if (imported.isEmpty) {
        importTask.finish();
        if (_entries.isNotEmpty) {
          _showToast('Backup has no new moments', warning: true);
        } else {
          _showToast('This backup contains no moments', warning: true);
        }
        return false;
      }

      final confirmed = await _confirmBackupImport(dryRun);
      if (confirmed != true) {
        importTask.finish();
        _showToast('Import cancelled');
        return false;
      }

      final settings = validation.settings;

      final importedTheme = settings['theme'] as String?;
      final importedDefaultMode = settings['defaultMode'] as String?;
      final importedAccentColor = settings['accentColor'] as String?;
      final importedAppIconStyle = settings['appIconStyle'] as String?;
      final importedHapticStyle = settings['hapticStyle'] as String?;
      final importedHistoryDensity = settings['historyDensity'] as String?;
      final importedBackupReminderDays = settings['backupReminderDays'];
      final importedHomeMenuAnimations = settings['homeMenuAnimations'];
      final importedTapDelay = settings['tapDelay'];

      final nextTheme =
          (importedTheme == 'dark' ||
              importedTheme == 'light' ||
              importedTheme == 'amoled')
          ? importedTheme!
          : _theme;
      final nextDefaultMode =
          (importedDefaultMode == 'single' ||
              importedDefaultMode == 'two-way' ||
              importedDefaultMode == 'last-used')
          ? importedDefaultMode!
          : _defaultMode;
      final nextTapDelay =
          importedTapDelay is num &&
              delayValues.contains(importedTapDelay.toInt())
          ? importedTapDelay.toInt()
          : _tapDelay;
      final nextAccentColor = accentOptions.contains(importedAccentColor)
          ? importedAccentColor!
          : _accentColor;
      final nextAppIconStyle = isAppIconStyle(importedAppIconStyle)
          ? importedAppIconStyle!
          : _appIconStyle;
      final nextHapticStyle =
          ['off', 'light', 'standard'].contains(importedHapticStyle)
          ? importedHapticStyle!
          : _hapticStyle;
      final nextHistoryDensity =
          ['comfortable', 'compact'].contains(importedHistoryDensity)
          ? importedHistoryDensity == 'compact'
                ? 'compact'
                : 'comfortable'
          : _historyDensity;
      final nextBackupReminderDays =
          importedBackupReminderDays is num &&
              [0, 7, 14, 30].contains(importedBackupReminderDays.toInt())
          ? importedBackupReminderDays.toInt()
          : _backupReminderDays;
      final nextHomeMenuAnimations = importedHomeMenuAnimations is bool
          ? importedHomeMenuAnimations
          : _homeMenuAnimations;

      var nextId = math.max(
        _nextId,
        _entries.isEmpty
            ? 1
            : _entries.map((entry) => entry.id).reduce(math.max) + 1,
      );

      final existingKeys = _entries
          .map((entry) => '${entry.timestamp}|${entry.type}|${entry.note}')
          .toSet();

      final merged = List<Moment>.from(_entries);
      var addedCount = 0;

      for (final entry in imported) {
        final key = '${entry.timestamp}|${entry.type}|${entry.note}';
        if (existingKeys.contains(key)) continue;

        existingKeys.add(key);
        merged.add(
          Moment(
            id: nextId++,
            timestamp: entry.timestamp,
            type: entry.type,
            date: entry.date,
            note: entry.note,
          ),
        );
        addedCount++;
      }

      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final oldNextId = _nextId;
      _nextId = nextId;
      final persistTask = developer.TimelineTask()
        ..start('notekar.backup_import.persist');
      try {
        await _replaceStoredEntries(merged);
        await _saveSetting('m-theme', nextTheme);
        await _saveSetting('m-default-mode', nextDefaultMode);
        await _saveSetting(
          'm-mode',
          nextDefaultMode == 'last-used' ? _mode : nextDefaultMode,
        );
        await _saveSetting('m-delay', nextTapDelay);
        await _saveSetting('m-accent-color', nextAccentColor);
        await _saveSetting('m-app-icon-style', nextAppIconStyle);
        await _saveSetting('m-haptic-style', nextHapticStyle);
        await _saveSetting('m-history-density', nextHistoryDensity);
        await _prefs?.setInt('m-backup-reminder-days', nextBackupReminderDays);
        await _prefs?.setBool('m-home-menu-animations', nextHomeMenuAnimations);
        await _prefs?.remove('m-inout');
        await _prefs?.remove('m-ses');
      } catch (_) {
        _nextId = oldNextId;
        importTask.finish();
        _showToast(
          'Import stopped safely. Your current data was not changed.',
          warning: true,
        );
        return false;
      } finally {
        persistTask.finish();
      }

      update(() {
        _entries = merged;
        _nextId = nextId;
        _lastId = null;
        _lastDeletedPreview = null;
        _theme = nextTheme;
        _defaultMode = nextDefaultMode;
        _mode = nextDefaultMode == 'last-used' ? _mode : nextDefaultMode;
        _tapDelay = nextTapDelay;
        _accentColor = nextAccentColor;
        _appIconStyle = nextAppIconStyle;
        _hapticStyle = nextHapticStyle;
        _haptics = _hapticStyle != 'off';
        _historyDensity = nextHistoryDensity;
        _backupReminderDays = nextBackupReminderDays;
        _homeMenuAnimations = nextHomeMenuAnimations;
        _inout = 'in';
        _sessionStart = null;
      });

      if (_homeMenuAnimations) {
        final motionAvailable = await _canUseMotionSensor();

        if (motionAvailable) {
          _startMotionIfNeeded();
        } else {
          if (mounted) update(() => _homeMenuAnimations = false);

          _motion.value = Offset.zero;

          await _prefs?.setBool('m-home-menu-animations', false);
          _showToast('Motion sensor unavailable', warning: true);
        }
      }

      _showToast(
        addedCount == 0
            ? 'Backup has no new moments'
            : 'Imported $addedCount new moments',
        warning: addedCount == 0,
      );
      importTask.finish();
      unawaited(_updateAndroidWidget());
      return true;
    } catch (_) {
      _showToast(
        'Import failed. The backup file looks damaged.',
        warning: true,
      );
      return false;
    }
  }

  Future<bool?> _confirmBackupImport(BackupDryRunSummary summary) {
    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close backup preview',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => BackupImportPreviewDialog(
        p: p,
        summary: summary,
        largeText: _largeText,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
      ),
    );
  }
}
