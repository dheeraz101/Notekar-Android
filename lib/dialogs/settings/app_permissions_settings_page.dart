import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/digital_wellbeing_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppPermissionsSettingsPage extends StatefulWidget {
  const AppPermissionsSettingsPage({super.key, required this.p});

  final Palette p;

  @override
  State<AppPermissionsSettingsPage> createState() =>
      _AppPermissionsSettingsPageState();
}

class _AppPermissionsSettingsPageState extends State<AppPermissionsSettingsPage>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('notekar/files');

  bool _micGranted = false;
  bool _cameraGranted = false;
  bool _notificationsGranted = false;
  bool _overlayGranted = false;
  bool _exactAlarmsGranted = false;
  bool _batteryExemptGranted = false;
  bool _usageStatsGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    try {
      final mic =
          await _channel.invokeMethod<bool>('checkAudioPermission') ?? false;
      final cam =
          await _channel.invokeMethod<bool>('checkCameraPermission') ?? false;
      final notif =
          await _channel.invokeMethod<bool>('canPostNotifications') ?? false;
      final overlay =
          await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
      final alarms =
          await _channel.invokeMethod<bool>('canScheduleExactAlarms') ?? false;
      final battery =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          false;
      final usage =
          await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;

      if (mounted) {
        setState(() {
          _micGranted = mic;
          _cameraGranted = cam;
          _notificationsGranted = notif;
          _overlayGranted = overlay;
          _exactAlarmsGranted = alarms;
          _batteryExemptGranted = battery;
          _usageStatsGranted = usage;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _grantedCount {
    int c = 0;
    if (_micGranted) c++;
    if (_cameraGranted) c++;
    if (_notificationsGranted) c++;
    if (_overlayGranted) c++;
    if (_exactAlarmsGranted) c++;
    if (_batteryExemptGranted) c++;
    if (_usageStatsGranted) c++;
    return c;
  }

  Future<void> _requestPermission(String type) async {
    HapticFeedback.lightImpact();
    try {
      switch (type) {
        case 'mic':
          await _channel.invokeMethod<bool>('requestAudioPermission');
          break;
        case 'camera':
          await _channel.invokeMethod<bool>('requestCameraPermission');
          break;
        case 'notif':
          await _channel.invokeMethod<bool>('requestNotificationPermission');
          break;
        case 'overlay':
          await _channel.invokeMethod<void>('requestOverlayPermission');
          break;
        case 'alarms':
          await _channel.invokeMethod<void>('requestExactAlarmPermission');
          break;
        case 'battery':
          await _channel.invokeMethod<void>(
            'requestIgnoreBatteryOptimizations',
          );
          break;
        case 'usage':
          await DigitalWellbeingService.instance.openUsageSettings();
          break;
        case 'settings':
          await _channel.invokeMethod<void>('openAppSettings');
          break;
      }
    } catch (_) {
      // Fallback: Open system app settings if specialized intent failed
      try {
        await _channel.invokeMethod<void>('openAppSettings');
      } catch (_) {}
    }
    await _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Apple Hero Header
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      p.accent,
                      Color.lerp(p.accent, Colors.black, 0.3) ?? p.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.square_stack_3d_up_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DEVICE CAPABILITIES'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'App Permissions'.localized(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'NoteKar accesses device features strictly for offline personal productivity. No audio, camera frames, or telemetry ever leave your device.'
                      .localized(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Live Status Badge Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: p.surface2.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (_grantedCount == 7 ? p.green : p.accent).withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _grantedCount == 7
                          ? CupertinoIcons.checkmark_seal_fill
                          : CupertinoIcons.slider_horizontal_3,
                      color: _grantedCount == 7 ? p.green : p.accent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoading
                            ? 'Inspecting Permissions...'.localized(context)
                            : '$_grantedCount of 7 Permissions Granted'
                                  .localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _grantedCount == 7
                            ? 'All capabilities fully operational'.localized(
                                context,
                              )
                            : 'Tap any ungranted permission to enable'
                                  .localized(context),
                        style: TextStyle(color: p.text3, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.arrow_clockwise, size: 18),
                  color: p.text2,
                  tooltip: 'Refresh Status',
                  onPressed: _checkAllPermissions,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 3. Media & Input Permissions
        SettingsGroup(
          p: p,
          title: 'Input & Media'.localized(context),
          insetDividers: true,
          children: [
            _buildPermissionRow(
              icon: CupertinoIcons.mic_fill,
              title: 'Microphone'.localized(context),
              subtitle: 'Voice notes & audio memos in moments and timeline',
              permissionTag: 'RECORD_AUDIO',
              isGranted: _micGranted,
              color: p.orange,
              onTap: () => _requestPermission('mic'),
            ),
            _buildPermissionRow(
              icon: CupertinoIcons.camera_fill,
              title: 'Camera'.localized(context),
              subtitle:
                  'Instant photo moments and NoteKar QR identity scanning',
              permissionTag: 'CAMERA',
              isGranted: _cameraGranted,
              color: p.accent,
              onTap: () => _requestPermission('camera'),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 4. Background & Timers
        SettingsGroup(
          p: p,
          title: 'Timing & Background Reliability'.localized(context),
          insetDividers: true,
          children: [
            _buildPermissionRow(
              icon: CupertinoIcons.bell_fill,
              title: 'Notifications'.localized(context),
              subtitle:
                  'Active session countdown, habit reminders, streak alerts',
              permissionTag: 'POST_NOTIFICATIONS',
              isGranted: _notificationsGranted,
              color: p.red,
              onTap: () => _requestPermission('notif'),
            ),
            _buildPermissionRow(
              icon: CupertinoIcons.bubble_left_bubble_right_fill,
              title: 'Display Over Other Apps'.localized(context),
              subtitle: 'Floating bubble timer and quick note pill overlay',
              permissionTag: 'SYSTEM_ALERT_WINDOW',
              isGranted: _overlayGranted,
              color: p.accent,
              onTap: () => _requestPermission('overlay'),
            ),
            _buildPermissionRow(
              icon: CupertinoIcons.alarm_fill,
              title: 'Alarms & Reminders'.localized(context),
              subtitle: 'Precise reminder scheduling without OS battery jitter',
              permissionTag: 'SCHEDULE_EXACT_ALARM',
              isGranted: _exactAlarmsGranted,
              color: p.orange,
              onTap: () => _requestPermission('alarms'),
            ),
            _buildPermissionRow(
              icon: CupertinoIcons.battery_charging,
              title: 'Battery Optimization Exemption'.localized(context),
              subtitle: 'Prevents system deep sleep from killing active timers',
              permissionTag: 'REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
              isGranted: _batteryExemptGranted,
              color: p.green,
              onTap: () => _requestPermission('battery'),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 5. Wellbeing Insights
        SettingsGroup(
          p: p,
          title: 'Conscious Awareness'.localized(context),
          insetDividers: true,
          children: [
            _buildPermissionRow(
              icon: CupertinoIcons.chart_pie_fill,
              title: 'Usage Access'.localized(context),
              subtitle: 'On-device Digital Wellbeing conscious time reflection',
              permissionTag: 'PACKAGE_USAGE_STATS',
              isGranted: _usageStatsGranted,
              color: p.green,
              onTap: () => _requestPermission('usage'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 6. Action Button: Open Android System App Settings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _requestPermission('settings'),
            icon: const Icon(CupertinoIcons.gear_alt_fill, size: 16),
            label: Text(
              'Open System App Settings'.localized(context),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.text,
              side: BorderSide(color: p.border.withValues(alpha: 0.6)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        SettingsPageDescription(
          p: p,
          text:
              'You retain complete control. You can revoke any permission at any time directly in Android System Settings without breaking offline note taking.'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String permissionTag,
    required bool isGranted,
    required Color color,
    required VoidCallback onTap,
  }) {
    final p = widget.p;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.35),
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      permissionTag,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 9.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isGranted ? p.green : p.accent).withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (isGranted ? p.green : p.accent).withValues(
                      alpha: 0.4,
                    ),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGranted
                          ? CupertinoIcons.checkmark_alt
                          : CupertinoIcons.arrow_right,
                      size: 11,
                      color: isGranted ? p.green : p.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isGranted ? 'Granted' : 'Enable',
                      style: TextStyle(
                        color: isGranted ? p.green : p.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
