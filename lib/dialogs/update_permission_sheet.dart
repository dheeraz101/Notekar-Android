import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class UpdatePermissionSheet extends StatefulWidget {
  const UpdatePermissionSheet({
    super.key,
    required this.p,
    this.blur = false,
  });

  final Palette p;
  final bool blur;

  @override
  State<UpdatePermissionSheet> createState() => _UpdatePermissionSheetState();
}

class _UpdatePermissionSheetState extends State<UpdatePermissionSheet>
    with WidgetsBindingObserver {
  static const _fileChannel = MethodChannel('notekar/files');

  bool _notificationGranted = false;
  bool _installGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final notif = await _fileChannel.invokeMethod<bool>('canPostNotifications') ?? false;
      final install = await _fileChannel.invokeMethod<bool>('canInstallPackages') ?? false;
      if (mounted) {
        setState(() {
          _notificationGranted = notif;
          _installGranted = install;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'In-App Update Setup'.localized(context),
      blur: widget.blur,
      showLargeTitle: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'To download and install software updates directly within NoteKar, please configure the following security settings:'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text2,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // Card 1: Notification Permission
            _buildSetupCard(
              icon: Icons.notifications_active_rounded,
              title: 'Push Alerts & Notices'.localized(context),
              subtitle: 'Notifies you immediately when new releases are compiled.'.localized(context),
              isConfigured: _notificationGranted,
              buttonText: 'Grant Permission'.localized(context),
              onAction: () async {
                HapticFeedback.selectionClick();
                final granted = await _fileChannel.invokeMethod<bool>('requestNotificationPermission') ?? false;
                if (granted) _checkPermissions();
              },
            ),
            const SizedBox(height: 16),

            // Card 2: Install Unknown Apps Permission
            _buildSetupCard(
              icon: Icons.install_mobile_rounded,
              title: 'Allow App Installation'.localized(context),
              subtitle: 'Required by Android to launch the system package archive installer for downloaded APKs.'.localized(context),
              isConfigured: _installGranted,
              buttonText: 'Configure Settings'.localized(context),
              onAction: () async {
                HapticFeedback.selectionClick();
                await _fileChannel.invokeMethod('openInstallPermissionSettings');
              },
            ),
            const SizedBox(height: 28),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
              child: Text(
                'Done'.localized(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConfigured,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    final p = widget.p;

    return Glass(
      p: p,
      radius: 20,
      blur: widget.blur,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (isConfigured ? p.green : p.accent).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isConfigured ? Icons.check_rounded : icon,
                  color: isConfigured ? p.green : p.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isConfigured) ...[
            const SizedBox(height: 16),
            PressableScale(
              onTap: onAction,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
