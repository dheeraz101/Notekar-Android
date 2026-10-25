import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/update_permission_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/markdown_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCenterView extends StatefulWidget {
  const UpdateCenterView({
    super.key,
    required this.p,
    required this.appVersion,
    required this.enableTranslucency,
    required this.reduceMotion,
    required this.onOpenLink,
    this.prefs,
    required this.onCheckUpdates,
    this.updateInfo,
    required this.checkingUpdates,
    required this.updateStatus,
    required this.currentBuildChannel,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String appVersion;
  final bool enableTranslucency;
  final bool reduceMotion;
  final void Function(String url) onOpenLink;
  final SharedPreferences? prefs;
  final VoidCallback onCheckUpdates;
  final AppUpdateInfo? updateInfo;
  final bool checkingUpdates;
  final String updateStatus;
  final String currentBuildChannel;
  final VoidCallback onLearnMoreBeta;

  @override
  State<UpdateCenterView> createState() => _UpdateCenterViewState();
}

class _UpdateCenterViewState extends State<UpdateCenterView> {
  final _updateService = UpdateService();

  // Download & verification state
  double _downloadProgress = 0.0;
  bool _downloading = false;
  bool _installing = false;
  bool _fetchingApkSize = false;
  String? _downloadedApkPath;
  String _verificationStatus = 'idle'; // idle, verifying, verified, failed

  // Cache state
  double _cacheSizeMb = 0.0;
  bool _updateCancelled = false;

  @override
  void initState() {
    super.initState();
    _initCancelledState();
    _checkCache();
  }

  Future<void> _initCancelledState() async {
    try {
      final prefs = widget.prefs ?? await SharedPreferences.getInstance();
      final cancelledTag = prefs.getString('cancelled_update_tag');
      if (cancelledTag != null &&
          widget.updateInfo != null &&
          widget.updateInfo!.tagName == cancelledTag) {
        if (mounted) setState(() => _updateCancelled = true);
      }
    } catch (_) {}
  }

  Future<void> _cancelUpdate() async {
    final prefs = widget.prefs ?? await SharedPreferences.getInstance();
    if (widget.updateInfo != null) {
      await prefs.setString('cancelled_update_tag', widget.updateInfo!.tagName);
    }
    if (mounted) {
      setState(() => _updateCancelled = true);
      showIosPillToast(
        context: context,
        p: widget.p,
        message: 'Update cancelled'.localized(context),
        icon: CupertinoIcons.xmark_circle_fill,
      );
    }
  }

  void _handleManualCheckUpdates() {
    setState(() => _updateCancelled = false);
    _clearCancelledUpdateTag();
    widget.onCheckUpdates();
  }

  Future<void> _clearCancelledUpdateTag() async {
    try {
      final prefs = widget.prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('cancelled_update_tag');
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant UpdateCenterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkingUpdates) {
      _updateCancelled = false;
    }
    if (widget.updateInfo != oldWidget.updateInfo) {
      _initCancelledState();
    }
    if (widget.updateInfo != oldWidget.updateInfo ||
        widget.checkingUpdates != oldWidget.checkingUpdates ||
        widget.updateStatus != oldWidget.updateStatus) {
      _checkCache();
    }
  }

  Future<void> _checkCache() async {
    try {
      final totalMb = await _updateService.getTotalCacheSizeMb();
      String? currentPath;
      if (widget.updateInfo != null) {
        currentPath = await _updateService.getCachedApkPath(
          widget.updateInfo!.version,
        );
      }
      if (mounted) {
        setState(() {
          _cacheSizeMb = totalMb;
          _downloadedApkPath = currentPath;
          if (currentPath != null) {
            _verificationStatus = 'verified';
          } else {
            _verificationStatus = 'idle';
          }
        });
      }
      final prefs = widget.prefs ?? await SharedPreferences.getInstance();
      final autoDownload = prefs.getBool('m-auto-download-updates') ?? false;
      if (autoDownload &&
          widget.updateInfo != null &&
          currentPath == null &&
          !_downloading &&
          mounted) {
        unawaited(_startDownload());
      }
    } catch (_) {}
  }

  Future<void> _checkBeforeDownload() async {
    if (widget.updateInfo == null || _fetchingApkSize) return;

    final prefs = await SharedPreferences.getInstance();
    final dontShowWarning = prefs.getBool('dont_show_update_warning') ?? false;

    if (dontShowWarning) {
      await _startDownload();
      return;
    }

    setState(() => _fetchingApkSize = true);

    double? fetchedSizeMb;
    try {
      fetchedSizeMb = await _updateService.getApkSizeMb(widget.updateInfo!);
    } catch (_) {}

    if (mounted) {
      setState(() => _fetchingApkSize = false);
    }

    String sizeText = '';
    if (fetchedSizeMb != null) {
      sizeText = '${fetchedSizeMb.toStringAsFixed(1)} MB';
    } else {
      final isSplit =
          widget.updateInfo!.version.toLowerCase().contains('arm') ||
          widget.updateInfo!.version.toLowerCase().contains('x86');
      sizeText = isSplit ? '30 MB (Estimated)' : '60 MB (Estimated)';
    }

    if (!mounted) return;

    bool dontShowCheckbox = false;

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        final p = widget.p;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoTheme(
              data: CupertinoThemeData(
                brightness: p.name == 'light'
                    ? Brightness.light
                    : Brightness.dark,
                primaryColor: p.accent,
              ),
              child: CupertinoAlertDialog(
                title: Text('Network Warning'.localized(context)),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Warning!: The current update will be downloaded via your mobile data, if you wish to switch to Wifi please do so and continue to download the update over Wifi.'
                            .localized(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Download Size: '.localized(context),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            sizeText,
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            dontShowCheckbox = !dontShowCheckbox;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                dontShowCheckbox
                                    ? CupertinoIcons.check_mark_circled_solid
                                    : CupertinoIcons.circle,
                                size: 18,
                                color: dontShowCheckbox
                                    ? p.accent
                                    : CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Don't show this warning again".localized(
                                    context,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'.localized(context)),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final navigator = Navigator.of(context);
                      if (dontShowCheckbox) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('dont_show_update_warning', true);
                      }
                      if (mounted) {
                        navigator.pop();
                        unawaited(_startDownload());
                      }
                    },
                    child: Text('Download'.localized(context)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startDownload() async {
    if (widget.updateInfo == null) return;
    await _updateService.clearCachedBuilds();
    setState(() {
      _downloading = true;
      _downloadProgress = 0.0;
      _verificationStatus = 'idle';
    });

    try {
      final path = await _updateService.downloadApk(widget.updateInfo!, (
        progress,
      ) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      });

      if (path == null) {
        if (mounted) {
          setState(() {
            _downloading = false;
            _verificationStatus = 'failed';
          });
          showIosPillToast(
            context: context,
            p: widget.p,
            message: 'Download failed'.localized(context),
            icon: CupertinoIcons.exclamationmark_circle,
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _downloading = false;
          _downloadedApkPath = path;
          _verificationStatus = 'verifying';
        });
      }

      final ok = await _updateService.verifyApkHash(widget.updateInfo!, path);
      if (mounted) {
        setState(() {
          _verificationStatus = ok ? 'verified' : 'failed';
        });
        if (!ok) {
          showIosPillToast(
            context: context,
            p: widget.p,
            message: 'Integrity check failed: checksum mismatch'.localized(
              context,
            ),
            icon: CupertinoIcons.shield,
          );
        }
      }
      _checkCache();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _verificationStatus = 'failed';
        });
      }
    }
  }

  Future<void> _installApk() async {
    if (_downloadedApkPath == null || _installing || _downloading) return;
    setState(() => _installing = true);

    try {
      final channel = const MethodChannel('notekar/files');

      final canInstall =
          await channel.invokeMethod<bool>('canInstallPackages') ?? false;
      if (!canInstall) {
        if (!mounted) return;
        await showGeneralDialog<void>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.42),
          barrierDismissible: true,
          barrierLabel: 'Close permissions setup',
          transitionDuration: const Duration(milliseconds: 120),
          pageBuilder: (_, _, _) => UpdatePermissionSheet(
            p: widget.p,
            blur:
                !widget.reduceMotion &&
                widget.enableTranslucency &&
                AdaptiveEngine().supportsBlur,
          ),
        );
        final canInstallNow =
            await channel.invokeMethod<bool>('canInstallPackages') ?? false;
        if (!canInstallNow) {
          if (mounted) {
            setState(() => _installing = false);
          }
          return;
        }
      }

      final success = await channel.invokeMethod<bool>('installApk', {
        'filePath': _downloadedApkPath,
      });
      if (success == false && mounted) {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Installation failed to start'.localized(context),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _installing = false);
      }
    } finally {
      // Retain _installing for 2500ms so the OS package installer sheet presents smoothly without button flashing
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _installing = false);
        }
      });
    }
  }

  Future<void> _clearCache() async {
    HapticFeedback.mediumImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutBack,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: widget.p.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: widget.p.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(
                    radius: 14,
                    color: widget.p.accent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Clearing cached update files...'.localized(context),
                    style: TextStyle(
                      color: widget.p.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    await _updateService.clearCachedBuilds();

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      showIosPillToast(
        context: context,
        p: widget.p,
        message: 'Build cache cleared'.localized(context),
        icon: CupertinoIcons.sparkles,
      );
      setState(() {
        _downloadedApkPath = null;
        _verificationStatus = 'idle';
        _cacheSizeMb = 0.0;
      });
    }
  }

  Future<void> _deleteDownloadedApk() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete Downloaded Update?'.localized(context)),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'This will delete the downloaded package from your device.'
                .localized(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.localized(context)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'.localized(context)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateService.clearCachedBuilds();
      if (mounted) {
        setState(() {
          _downloadedApkPath = null;
          _verificationStatus = 'idle';
          _cacheSizeMb = 0.0;
        });
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Downloaded update deleted'.localized(context),
          icon: CupertinoIcons.trash,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing24),

        // Header Logo & Version info
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'icon-maskable-512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: spacing20),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatInstalledDate(appBuildDate).localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing24),

        // Main Download & Install Card
        _buildDownloadInstallCard(p),
        const SizedBox(height: spacing16),

        // Cache cleaner card
        _buildCacheCard(p),
        const SizedBox(height: spacing20),

        // Formal Page Description at the bottom spanning full width
        SettingsPageDescription(
          p: p,
          showIcon: true,
          bottomPadding: 32,
          text:
              'Update Center provides verified, sovereign software releases and security advisories for your device. All distributions undergo cryptographic signature verification and SHA-256 checksum validation prior to installation, maintaining complete offline integrity without intermediary telemetry.'
                  .localized(context),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _buildDownloadInstallCard(Palette p) {
    final blurEnabled =
        !widget.reduceMotion &&
        widget.enableTranslucency &&
        AdaptiveEngine().supportsBlur;
    final availableVersion = widget.updateInfo?.version ?? '';
    final cleanVersion = availableVersion.startsWith('v')
        ? availableVersion
        : 'v$availableVersion';

    // Classify installed build channel dynamically from semver
    final versionParts = widget.appVersion
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map(int.parse)
        .toList();
    final isInstalledExperiment =
        widget.appVersion.contains(RegExp(r'[Ee]\d+')) ||
        widget.appVersion.toLowerCase().contains('experiment') ||
        kAppBuildNumber.toLowerCase().contains('er');
    bool isInstalledBeta =
        !isInstalledExperiment &&
        widget.appVersion.toLowerCase().contains('beta');
    bool isInstalledPriority = false;
    if (!isInstalledExperiment &&
        !isInstalledBeta &&
        versionParts.length >= 3) {
      final minor = versionParts[1];
      final patch = versionParts[2];
      if (minor > 0 && patch == 0) {
        isInstalledPriority = true;
      } else if (patch > 0) {
        isInstalledBeta = true;
      }
    }
    final currentBuildChannel = isInstalledExperiment
        ? 'experiment'
        : (isInstalledPriority
              ? 'priority'
              : (isInstalledBeta ? 'beta' : 'stable'));

    if (widget.checkingUpdates) {
      return _AnimatedUpdateCheckCard(p: p, blur: blurEnabled);
    }

    if (widget.updateInfo == null || _updateCancelled) {
      return Glass(
        p: p,
        radius: 24,
        blur: blurEnabled,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              _updateCancelled
                  ? CupertinoIcons.arrow_counterclockwise_circle
                  : CupertinoIcons.checkmark_circle,
              color: _updateCancelled ? p.orange : p.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              (_updateCancelled ? 'Update postponed' : 'You are up to date')
                  .localized(context),
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (currentBuildChannel.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: currentBuildChannel == 'experiment'
                      ? const Color(0xFFFF3B30).withValues(alpha: 0.12)
                      : (currentBuildChannel == 'priority'
                            ? p.red.withValues(alpha: 0.12)
                            : (currentBuildChannel == 'beta'
                                  ? p.green.withValues(alpha: 0.12)
                                  : p.accent.withValues(alpha: 0.12))),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  (currentBuildChannel == 'experiment'
                          ? 'Experiment Release'
                          : (currentBuildChannel == 'priority'
                                ? 'Priority Release'
                                : (currentBuildChannel == 'beta'
                                      ? 'Beta Release'
                                      : 'Stable Release')))
                      .localized(context),
                  style: TextStyle(
                    color: currentBuildChannel == 'experiment'
                        ? const Color(0xFFFF3B30)
                        : (currentBuildChannel == 'priority'
                              ? p.red
                              : (currentBuildChannel == 'beta'
                                    ? p.green
                                    : p.accent)),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'v$appVersion ($kAppBuildNumber)',
              style: TextStyle(color: p.text3, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.surface3,
                foregroundColor: p.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _handleManualCheckUpdates,
              child: Text('Check for updates'.localized(context)),
            ),
          ],
        ),
      );
    }

    return Glass(
      p: p,
      radius: 24,
      blur: blurEnabled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.arrow_down_circle_fill,
                color: p.accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Update Available'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.updateInfo!.type.contains('Experiment')
                  ? const Color(0xFFFF3B30).withValues(alpha: 0.12)
                  : (widget.updateInfo!.type == 'Security Update'
                        ? p.red.withValues(alpha: 0.12)
                        : (widget.updateInfo!.type == 'Feature Update'
                              ? p.accent.withValues(alpha: 0.12)
                              : p.green.withValues(alpha: 0.12))),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.updateInfo!.type.localized(context),
              style: TextStyle(
                color: widget.updateInfo!.type.contains('Experiment')
                    ? const Color(0xFFFF3B30)
                    : (widget.updateInfo!.type == 'Security Update'
                          ? p.red
                          : (widget.updateInfo!.type == 'Feature Update'
                                ? p.accent
                                : p.green)),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Version $cleanVersion',
            style: TextStyle(
              color: p.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (widget.updateInfo!.type == 'Security Update'
                    ? 'This critical update contains important security patches, bug fixes, and stability improvements.'
                    : (widget.updateInfo!.type == 'Feature Update'
                          ? 'This major update introduces brand new features, improvements, and interface designs to NoteKar.'
                          : 'This pre-release version includes early feature drafts and optimizations for developer testing.'))
                .localized(context),
            style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.45),
          ),
          if (widget.updateInfo!.body.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "What's New:".localized(context),
              style: TextStyle(
                color: p.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 240),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              child: SingleChildScrollView(
                child: MarkdownText(
                  text: widget.updateInfo!.body,
                  p: p,
                  onOpenLink: widget.onOpenLink,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          if (_downloading) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading update...'.localized(context),
                      style: TextStyle(color: p.text2, fontSize: 13),
                    ),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: p.border,
                    color: p.accent,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ] else if (_verificationStatus == 'verifying') ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(radius: 8, color: p.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Verifying package integrity...'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_installing) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(radius: 8, color: p.green),
                  const SizedBox(width: 10),
                  Text(
                    'Preparing system installer...'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_downloadedApkPath != null &&
              _verificationStatus == 'verified') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_shield_fill,
                      color: p.green,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Package verified & ready'.localized(context),
                      style: TextStyle(
                        color: p.green,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _installApk,
                  child: Text(
                    'Install Now'.localized(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.red.withValues(alpha: 0.12),
                    foregroundColor: p.red,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.trash, size: 18),
                  label: Text(
                    'Delete Downloaded Update'.localized(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _deleteDownloadedApk,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.surface3,
                    foregroundColor: p.text,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => widget.onOpenLink(githubReleases),
                  child: Text('Download from GitHub'.localized(context)),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.surface3,
                    foregroundColor: p.text,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _handleManualCheckUpdates,
                  child: Text('Check for updates'.localized(context)),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.surface3.withValues(alpha: 0.6),
                    foregroundColor: p.text2,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _cancelUpdate,
                  child: Text('Cancel Update'.localized(context)),
                ),
              ],
            ),
          ] else ...[
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _fetchingApkSize ? null : _checkBeforeDownload,
              child: _fetchingApkSize
                  ? const CupertinoActivityIndicator(
                      radius: 9,
                      color: Colors.white,
                    )
                  : Text(
                      _verificationStatus == 'failed'
                          ? 'Retry Download'.localized(context)
                          : 'Download & Install'.localized(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.surface3,
                foregroundColor: p.text,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _fetchingApkSize
                  ? null
                  : () => widget.onOpenLink(githubReleases),
              child: Text('Download from GitHub'.localized(context)),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.surface3,
                foregroundColor: p.text,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _fetchingApkSize ? null : _handleManualCheckUpdates,
              child: Text('Check for updates'.localized(context)),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.surface3.withValues(alpha: 0.6),
                foregroundColor: p.text2,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _cancelUpdate,
              child: Text('Cancel Update'.localized(context)),
            ),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text.rich(
              TextSpan(
                text:
                    'By downloading and installing updates, you agree to NoteKar’s '
                        .localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 11,
                  height: 1.35,
                  fontFamily: 'Inter',
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => widget.onOpenLink(termsUrl),
                      child: Text(
                        'Terms of Service'.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: ' and acknowledge our '.localized(context)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => widget.onOpenLink(privacyPolicyUrl),
                      child: Text(
                        'Privacy Policy'.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheCard(Palette p) {
    final blurEnabled =
        !widget.reduceMotion &&
        widget.enableTranslucency &&
        AdaptiveEngine().supportsBlur;
    final hasCache = _cacheSizeMb > 0.0;

    return Glass(
      p: p,
      radius: 24,
      blur: blurEnabled,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                hasCache ? CupertinoIcons.sparkles : CupertinoIcons.archivebox,
                color: hasCache ? p.orange : p.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Cache Size'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCache
                          ? '${_cacheSizeMb.toStringAsFixed(2)} MB of temporary installers'
                                .localized(context)
                          : '0.00 MB (No cached installers)'.localized(context),
                      style: TextStyle(color: p.text3, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: hasCache
                  ? p.red.withValues(alpha: 0.15)
                  : p.surface3,
              foregroundColor: hasCache ? p.red : p.text3,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: hasCache ? _clearCache : null,
            child: Text(
              (hasCache ? 'Delete Cache' : 'Cache Clean').localized(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class ExperimentChannelWarningScreen extends StatelessWidget {
  const ExperimentChannelWarningScreen({
    super.key,
    required this.p,
    this.onBackup,
  });

  final Palette p;
  final VoidCallback? onBackup;

  static Future<bool?> show(
    BuildContext context, {
    required Palette p,
    VoidCallback? onBackup,
  }) {
    return Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        fullscreenDialog: true,
        builder: (ctx) =>
            ExperimentChannelWarningScreen(p: p, onBackup: onBackup),
      ),
    );
  }

  Widget _buildWarningRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description.localized(context),
                  style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: p.bg,
      appBar: CupertinoNavigationBar(
        backgroundColor: p.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: p.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.xmark, size: 18, color: p.text2),
              const SizedBox(width: 4),
              Text(
                'Cancel'.localized(context),
                style: TextStyle(color: p.text2, fontSize: 15),
              ),
            ],
          ),
        ),
        middle: Text(
          'Warning'.localized(context),
          style: TextStyle(
            color: p.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    // Apple HIG Alert Icon Squircle
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: p.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: p.red.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: p.red.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 38,
                        color: p.red,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HIGH INSTABILITY WARNING'.localized(context),
                        style: TextStyle(
                          color: p.red,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Headline
                    Text(
                      'Experiment Release Channel'.localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subhead description
                    Text(
                      'The Experiment channel lets you test brand-new features and designs before anyone else. Because these features are still in active development, you may experience occasional glitches.'
                          .localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // HIG Grouped Cards
                    _buildWarningRow(
                      context: context,
                      icon: CupertinoIcons.sparkles,
                      iconColor: p.orange,
                      title: 'Early Feature Access',
                      description:
                          'Try upcoming tools and design enhancements weeks before they are released to the public.',
                    ),
                    _buildWarningRow(
                      context: context,
                      icon: CupertinoIcons.bolt_badge_a_fill,
                      iconColor: p.red,
                      title: 'Occasional Bugs & Glitches',
                      description:
                          'Some features might feel unpolished, run slower, or occasionally crash while we are refining them.',
                    ),
                    _buildWarningRow(
                      context: context,
                      icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
                      iconColor: p.accent,
                      title: 'Instant Automatic Updates',
                      description:
                          'You will automatically receive every new preview and stable update directly as soon as it is published.',
                    ),
                    _buildWarningRow(
                      context: context,
                      icon: CupertinoIcons.shield_fill,
                      iconColor: const Color(0xFF5856D6),
                      title: 'Protect Your Notes',
                      description:
                          'Your notes are kept safe locally, but we always recommend exporting a quick backup before trying preview channels.',
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Action Dock
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: p.border.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Safe Backup Button
                  PressableScale(
                    onTap: () {
                      Navigator.of(context).pop(false);
                      onBackup?.call();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.archivebox_fill,
                            size: 16,
                            color: p.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Backup Data First'.localized(context),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Agree Button (Red, prominent)
                  PressableScale(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: p.red,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: p.red.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'I Understand & Enable Channel'.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Cancel Text Button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Keep Current Track'.localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef ExperimentChannelWarningDialog = ExperimentChannelWarningScreen;

class BuildTrackSelectPage extends StatelessWidget {
  const BuildTrackSelectPage({
    super.key,
    required this.p,
    required this.betaTrack,
    this.currentChannel,
    required this.onSaveTrackPreference,
    this.onSaveChannelPreference,
    this.onExportBackup,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final bool betaTrack;
  final String? currentChannel;
  final ValueChanged<bool> onSaveTrackPreference;
  final ValueChanged<String>? onSaveChannelPreference;
  final VoidCallback? onExportBackup;
  final VoidCallback onLearnMoreBeta;

  String get _activeChannel =>
      currentChannel ?? (betaTrack ? 'beta' : 'stable');

  Future<void> _handleChannelSelect(
    BuildContext context,
    String targetChannel,
  ) async {
    if (targetChannel == _activeChannel) return;

    if (targetChannel == 'experiment') {
      final confirmed = await ExperimentChannelWarningDialog.show(
        context,
        p: p,
        onBackup: onExportBackup,
      );
      if (confirmed == true) {
        if (onSaveChannelPreference != null) {
          onSaveChannelPreference!(targetChannel);
        } else {
          onSaveTrackPreference(true);
        }
      }
      return;
    }

    if (onSaveChannelPreference != null) {
      onSaveChannelPreference!(targetChannel);
    } else {
      onSaveTrackPreference(targetChannel == 'beta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              title: 'Stable Channel',
              subtitle:
                  'Engineered for maximum daily reliability and verified performance.'
                      .localized(context),
              trailing: _activeChannel == 'stable'
                  ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                  : const SizedBox.shrink(),
              onTap: () => _handleChannelSelect(context, 'stable'),
            ),
            SettingsRow(
              p: p,
              title: 'Beta Channel',
              subtitle:
                  'Experience upcoming innovations and refined capabilities before public release.'
                      .localized(context),
              trailing: _activeChannel == 'beta'
                  ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                  : const SizedBox.shrink(),
              onTap: () => _handleChannelSelect(context, 'beta'),
            ),
            SettingsRow(
              p: p,
              title: 'Developer Experiments',
              subtitle:
                  'Immediate access to cutting-edge features. Intended for early testing.'
                      .localized(context),
              trailing: _activeChannel == 'experiment'
                  ? Icon(CupertinoIcons.checkmark, color: p.red, size: 18)
                  : const SizedBox.shrink(),
              onTap: () => _handleChannelSelect(context, 'experiment'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose how NoteKar receives software updates. Stable ensures maximum continuous reliability, while Beta and Developer channels provide early access to evolving capabilities and UI refinements.'
                    .localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  height: 1.45,
                  letterSpacing: -0.05,
                ),
              ),
              const SizedBox(height: 12),
              _buildNumberingRow(
                context,
                '1.',
                'Enrolling in Stable delivers thoroughly validated releases optimized for everyday dependability.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '2.',
                'Enrolling in Beta provides priority access to pre-release features and direct framework enhancements.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '3.',
                'Beta installations automatically receive all published Stable updates alongside preview builds.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '4.',
                'When moving from Beta to Stable, your device remains on its current build until a higher Stable version is published.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '5.',
                'When moving from Stable to Beta, any newer active pre-release builds become available for immediate installation.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '6.',
                'Developer Experiments introduce prototype interfaces and architecture tests before general consolidation.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '7.',
                'You may switch release channels at any time without impacting your local encrypted database or notes.',
              ),
            ],
          ),
        ),
        SettingsBetaNote(p: p, onLearnMore: onLearnMoreBeta),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildNumberingRow(BuildContext context, String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Text(
            num,
            style: TextStyle(
              color: p.text3,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.05,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 13,
              height: 1.45,
              letterSpacing: -0.05,
            ),
          ),
        ),
      ],
    );
  }
}

class UpdatesNoticesSettingsPage extends StatelessWidget {
  const UpdatesNoticesSettingsPage({
    super.key,
    required this.p,
    required this.checkingUpdates,
    required this.updateInfo,
    required this.betaTrack,
    required this.remoteNotices,
    required this.onRemoteNoticesChanged,
    required this.onOpenCategory,
    required this.onLearnMoreBeta,
    this.onOpenLink,
    this.autoDeleteUpdateCache = false,
    this.onAutoDeleteUpdateCacheChanged,
    this.autoDownloadUpdates = false,
    this.onAutoDownloadUpdatesChanged,
  });

  final Palette p;
  final bool checkingUpdates;
  final AppUpdateInfo? updateInfo;
  final bool betaTrack;
  final bool remoteNotices;
  final ValueChanged<bool> onRemoteNoticesChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback onLearnMoreBeta;
  final void Function(String url)? onOpenLink;
  final bool autoDeleteUpdateCache;
  final ValueChanged<bool>? onAutoDeleteUpdateCacheChanged;
  final bool autoDownloadUpdates;
  final ValueChanged<bool>? onAutoDownloadUpdatesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_2_circlepath_circle,
              title: 'Software Update',
              color: p.text2,
              status: null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (checkingUpdates)
                    const CupertinoActivityIndicator(
                      radius: 6,
                      color: Colors.grey,
                    )
                  else if (updateInfo != null)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            (updateInfo!.isSecurity == true ||
                                updateInfo!.isImportant == true)
                            ? p.red
                            : p.orange,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: p.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: spacing8),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: p.text3,
                    size: 20,
                  ),
                ],
              ),
              onTap: () =>
                  onOpenCategory('Update Center', parent: 'Updates & Notices'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.scope,
              title: 'Build Channel',
              color: p.accent,
              status: betaTrack
                  ? 'Beta'.localized(context)
                  : 'Stable'.localized(context),
              onTap: () =>
                  onOpenCategory('Build Choose', parent: 'Updates & Notices'),
            ),
            if (onAutoDownloadUpdatesChanged != null)
              SettingsSwitchRow(
                p: p,
                icon: CupertinoIcons.arrow_down_circle,
                title: 'Auto-Download Updates',
                color: p.accent,
                value: autoDownloadUpdates,
                onChanged: onAutoDownloadUpdatesChanged!,
              ),
            if (onAutoDeleteUpdateCacheChanged != null)
              SettingsSwitchRow(
                p: p,
                icon: CupertinoIcons.trash,
                title: 'Rm -rf Cache',
                color: p.orange,
                value: autoDeleteUpdateCache,
                onChanged: onAutoDeleteUpdateCacheChanged!,
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Auto-download downloads update packages in the background so updates are immediately ready to install. Rm -rf deletes update packages upon installation to prevent cache build-up.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'App Notices',
              color: p.accent,
              value: remoteNotices,
              onChanged: onRemoteNoticesChanged,
            ),
            if (remoteNotices)
              SettingsRow(
                p: p,
                icon: CupertinoIcons.news,
                title: 'Official Bulletins',
                color: p.accent,
                status: null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View'.localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: spacing4),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: p.text3,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {
                  onOpenCategory(
                    'Official Bulletins',
                    parent: 'Updates & Notices',
                  );
                },
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Official bulletins, critical advisories, and curated release highlights delivered with zero user tracking.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          title: 'Release Notes & History',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.sparkles,
              title: "What's New",
              color: p.orange,
              status: 'Recent'.localized(context),
              onTap: () =>
                  onOpenCategory("What's New", parent: 'Updates & Notices'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.book_fill,
              title: 'Changelog',
              color: p.green,
              status: 'History'.localized(context),
              onTap: () =>
                  onOpenCategory('Changelog', parent: 'Updates & Notices'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'View release highlights, version logs, and bug fix summaries for NoteKar.'
                  .localized(context),
        ),
        SettingsBetaNote(p: p, onLearnMore: onLearnMoreBeta),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _AnimatedUpdateCheckCard extends StatefulWidget {
  const _AnimatedUpdateCheckCard({required this.p, required this.blur});

  final Palette p;
  final bool blur;

  @override
  State<_AnimatedUpdateCheckCard> createState() =>
      _AnimatedUpdateCheckCardState();
}

class _AnimatedUpdateCheckCardState extends State<_AnimatedUpdateCheckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Glass(
      p: p,
      radius: 24,
      blur: widget.blur,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (ctx, child) {
          final t = CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ).value;
          // Progress smoothly advances toward ~92% and holds calmly
          final progressPercent = (t * 92).toInt().clamp(5, 95);

          final statusText = t < 0.45
              ? 'Connecting to release server...'.localized(context)
              : 'Checking release channels...'.localized(context);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Apple HIG activity spinner with subtle halo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent.withValues(alpha: 0.10),
                ),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 12,
                    color: p.accent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Checking for updates...'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              // Clean Apple HIG progress line
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: p.surface3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (progressPercent / 100.0).clamp(0.06, 0.95),
                      child: Container(
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
