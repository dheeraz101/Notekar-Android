import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/update_permission_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/markdown_text.dart';
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
  bool _fetchingApkSize = false;
  String? _downloadedApkPath;
  String _verificationStatus = 'idle'; // idle, verifying, verified, failed

  // Cache state
  double _cacheSizeMb = 0.0;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  @override
  void didUpdateWidget(covariant UpdateCenterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.updateInfo != oldWidget.updateInfo ||
        widget.checkingUpdates != oldWidget.checkingUpdates ||
        widget.updateStatus != oldWidget.updateStatus) {
      _checkCache();
    }
  }

  Future<void> _checkCache() async {
    if (widget.updateInfo == null) return;
    try {
      final path = await _updateService.getCachedApkPath(
        widget.updateInfo!.version,
      );
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final len = await file.length();
          if (mounted) {
            setState(() {
              _downloadedApkPath = path;
              _cacheSizeMb = len / (1024 * 1024);
              _verificationStatus = 'verified';
            });
          }
          return;
        }
      }
      final channel = const MethodChannel('notekar/files');
      final cacheDir = await channel.invokeMethod<String>('appCacheDir');
      if (cacheDir != null) {
        final dir = Directory(cacheDir);
        double size = 0.0;
        if (await dir.exists()) {
          final files = dir.listSync();
          for (final entity in files) {
            if (entity is File && entity.path.endsWith('.apk')) {
              size += await entity.length();
            }
          }
        }
        if (mounted) {
          setState(() {
            _downloadedApkPath = null;
            _cacheSizeMb = size / (1024 * 1024);
            _verificationStatus = 'idle';
          });
        }
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

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final p = widget.p;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: p.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: p.border.withValues(alpha: 0.2)),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: p.orange, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Network Warning'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warning!: The current update will be downloaded via your mobile data, if you wish to switch to Wifi please do so and continue to download the update over Wifi.'
                        .localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Download Size: '.localized(context),
                        style: TextStyle(
                          color: p.text3,
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
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setDialogState(() {
                        dontShowCheckbox = !dontShowCheckbox;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dontShowCheckbox
                                  ? p.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: dontShowCheckbox
                                    ? p.accent
                                    : p.text3.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: dontShowCheckbox
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Don't show this warning again".localized(
                                context,
                              ),
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 11.5,
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
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel'.localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
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
                  child: Text(
                    'Download'.localized(context),
                    style: TextStyle(
                      color: p.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startDownload() async {
    if (widget.updateInfo == null) return;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed'.localized(context))),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Integrity check failed: checksum mismatch'.localized(context),
              ),
            ),
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
    if (_downloadedApkPath == null) return;
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
      if (!canInstallNow) return;
    }

    final success = await channel.invokeMethod<bool>('installApk', {
      'filePath': _downloadedApkPath,
    });
    if (success == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Installation failed to start'.localized(context)),
        ),
      );
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
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(
                      radius: 12,
                      color: widget.p.accent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deleting cache...'.localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Build cache cleared'.localized(context))),
      );
      setState(() {
        _downloadedApkPath = null;
        _verificationStatus = 'idle';
        _cacheSizeMb = 0.0;
      });
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
        const SizedBox(height: spacing24),

        SettingsPageDescription(
          p: p,
          text:
              'NoteKar is open source. You can always find the latest builds and source code on GitHub.',
          bottomPadding: spacing16,
        ),
        const SizedBox(height: spacing8),
        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: widget.onLearnMoreBeta,
        ),
        const SizedBox(height: spacing48),
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
    bool isInstalledBeta = widget.appVersion.toLowerCase().contains('beta');
    bool isInstalledSecurity = false;
    if (!isInstalledBeta && versionParts.length >= 3) {
      final minor = versionParts[1];
      final patch = versionParts[2];
      if (minor > 0 && patch == 0) {
        isInstalledSecurity = true;
      } else if (patch > 0) {
        isInstalledBeta = true;
      }
    }
    final currentBuildChannel = isInstalledSecurity
        ? 'security'
        : (isInstalledBeta ? 'beta' : 'stable');

    if (widget.checkingUpdates) {
      return Glass(
        p: p,
        radius: 24,
        blur: blurEnabled,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 154,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 16, color: p.accent),
              const SizedBox(height: 16),
              Text(
                'Checking for updates...'.localized(context),
                style: TextStyle(color: p.text2, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.updateInfo == null) {
      return Glass(
        p: p,
        radius: 24,
        blur: blurEnabled,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: p.green, size: 48),
            const SizedBox(height: 16),
            Text(
              'You are up to date'.localized(context),
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
                  color: currentBuildChannel == 'security'
                      ? p.red.withValues(alpha: 0.12)
                      : (currentBuildChannel == 'beta'
                            ? p.green.withValues(alpha: 0.12)
                            : p.accent.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  (currentBuildChannel == 'security'
                          ? 'Security Build'
                          : (currentBuildChannel == 'beta'
                                ? 'Beta Build'
                                : 'Stable Build'))
                      .localized(context),
                  style: TextStyle(
                    color: currentBuildChannel == 'security'
                        ? p.red
                        : (currentBuildChannel == 'beta' ? p.green : p.accent),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'v$appVersion ($appBuildNumber) • ${formatInstalledDate(appBuildDate)}'
                  .localized(context),
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
              onPressed: widget.onCheckUpdates,
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
              Icon(Icons.download_rounded, color: p.accent, size: 22),
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
              color: widget.updateInfo!.type == 'Security Update'
                  ? p.red.withValues(alpha: 0.12)
                  : (widget.updateInfo!.type == 'Feature Update'
                        ? p.accent.withValues(alpha: 0.12)
                        : p.green.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.updateInfo!.type.localized(context),
              style: TextStyle(
                color: widget.updateInfo!.type == 'Security Update'
                    ? p.red
                    : (widget.updateInfo!.type == 'Feature Update'
                          ? p.accent
                          : p.green),
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
          ] else if (_downloadedApkPath != null &&
              _verificationStatus == 'verified') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: p.green, size: 16),
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
                  onPressed: widget.onCheckUpdates,
                  child: Text('Check for updates'.localized(context)),
                ),
              ],
            ),
          ] else if (_verificationStatus == 'verifying') ...[
            Row(
              children: [
                CupertinoActivityIndicator(radius: 7, color: p.accent),
                const SizedBox(width: 8),
                Text(
                  'Verifying integrity checksum...'.localized(context),
                  style: TextStyle(color: p.text2, fontSize: 13),
                ),
              ],
            ),
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
              onPressed: widget.onCheckUpdates,
              child: Text('Check for updates'.localized(context)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCacheCard(Palette p) {
    if (_cacheSizeMb <= 0.0) return const SizedBox.shrink();
    final blurEnabled =
        !widget.reduceMotion &&
        widget.enableTranslucency &&
        AdaptiveEngine().supportsBlur;

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
              Icon(Icons.cleaning_services_rounded, color: p.orange, size: 20),
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
                      '${_cacheSizeMb.toStringAsFixed(2)} MB of temporary installers'
                          .localized(context),
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
              backgroundColor: p.red.withValues(alpha: 0.15),
              foregroundColor: p.red,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: _clearCache,
            child: Text(
              'Delete Cache'.localized(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildTrackSelectPage extends StatelessWidget {
  const BuildTrackSelectPage({
    super.key,
    required this.p,
    required this.betaTrack,
    required this.onSaveTrackPreference,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final bool betaTrack;
  final ValueChanged<bool> onSaveTrackPreference;
  final VoidCallback onLearnMoreBeta;

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
              icon: Icons.check_circle_outline_rounded,
              title: 'Stable Build',
              subtitle: 'Recommended for standard users.'.localized(context),
              trailing: !betaTrack
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => onSaveTrackPreference(false),
            ),
            SettingsRow(
              p: p,
              icon: Icons.track_changes_rounded,
              title: 'Beta Build',
              subtitle: 'Early access to active development features.'
                  .localized(context),
              trailing: betaTrack
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => onSaveTrackPreference(true),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stable track offers thoroughly tested releases. Beta track offers active pre-release compilation builds.'
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
                'Switching to the Stable Build track will fetch the last released stable build and show the update.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '2.',
                'Switching to the Beta Build track will fetch the last compiled beta build and show the update.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '3.',
                'If in a Beta build and switched to Stable now, you will only receive Stable releases when a higher version is published.',
              ),
              const SizedBox(height: 8),
              _buildNumberingRow(
                context,
                '4.',
                'If in a Stable build and switched to Beta now, you will receive upcoming Beta releases immediately as they are published.',
              ),
            ],
          ),
        ),
        SettingsBetaNote(
          p: p,
          text: 'The features on this track are under active beta testing.'
              .localized(context),
          onLearnMore: onLearnMoreBeta,
        ),
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
  });

  final Palette p;
  final bool checkingUpdates;
  final AppUpdateInfo? updateInfo;
  final bool betaTrack;
  final bool remoteNotices;
  final ValueChanged<bool> onRemoteNoticesChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback onLearnMoreBeta;

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
              icon: Icons.system_update_outlined,
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
                  Icon(Icons.chevron_right_rounded, color: p.text3, size: 20),
                ],
              ),
              onTap: () =>
                  onOpenCategory('Update Center', parent: 'Updates & Notices'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.track_changes_rounded,
              title: 'Build Channel',
              color: p.accent,
              status: betaTrack
                  ? 'Beta'.localized(context)
                  : 'Stable'.localized(context),
              onTap: () =>
                  onOpenCategory('Build Choose', parent: 'Updates & Notices'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Keep NoteKar up to date with the latest features and security patches.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'App Notices',
              color: p.accent,
              value: remoteNotices,
              onChanged: onRemoteNoticesChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Checks for official announcement notices and bug fix announcements.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          title: 'Release Notes & History',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.auto_awesome_rounded,
              title: "What's New",
              color: p.orange,
              status: 'Recent'.localized(context),
              onTap: () =>
                  onOpenCategory("What's New", parent: 'Updates & Notices'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.history_edu_rounded,
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
        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: onLearnMoreBeta,
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
