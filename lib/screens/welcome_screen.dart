import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/utils/l10n_utils.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onTheme,
    required this.onDefaultMode,
    required this.pages,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;
  final List<String> pages;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentPage = 0;

  late String theme;
  late String defaultMode;
  late String currentLocale;

  bool _notificationGranted = false;
  bool _batteryExempt = false;
  bool _installGranted = false;

  static const _fileChannel = MethodChannel('notekar/files');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
    currentLocale = widget.currentLocale;

    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
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
      final bool notificationGranted =
          await _fileChannel.invokeMethod<bool>('canPostNotifications') ??
          false;
      final bool batteryExempt =
          await _fileChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
      final bool installGranted =
          await _fileChannel.invokeMethod<bool>('canInstallPackages') ??
          false;
      if (mounted) {
        setState(() {
          _notificationGranted = notificationGranted;
          _batteryExempt = batteryExempt;
          _installGranted = installGranted;
        });
      }
    } catch (_) {}
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildWelcomePage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // iOS 26 Hero App Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'icon-maskable-512.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to NoteKar'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A quiet, offline-first way to mark moments the second they happen.'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              for (final option in const ['dark', 'light']) ...[
                Expanded(
                  child: ThemeChoice(
                    p: p,
                    label: option == 'dark' ? 'Dark' : 'Light',
                    active: theme == option,
                    color: option == 'dark'
                        ? Colors.black
                        : const Color(0xFFF2F2F7),
                    onTap: () {
                      setState(() => theme = option);
                      widget.onTheme(option);
                    },
                  ),
                ),
                if (option == 'dark') const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SegmentedSetting(
            p: p,
            title: 'Startup Mode'.localized(context),
            subtitle: 'Choose how NoteKar starts when you open it'.localized(
              context,
            ),
            value: defaultMode,
            values: const {'single': 'Single', 'two-way': 'Two-Way'},
            onChanged: (value) {
              setState(() => defaultMode = value);
              widget.onDefaultMode(value);
            },
          ),
          const SizedBox(height: 24),
          SegmentedSetting(
            p: p,
            title: 'App Language'.localized(context),
            subtitle: 'Choose your preferred interface language'.localized(
              context,
            ),
            value: currentLocale,
            values: const {
              'system': 'System',
              'en': 'English',
              'hi': 'हिन्दी',
              'es': 'Español',
            },
            onChanged: (value) {
              setState(() => currentLocale = value);
              widget.onLocaleChanged(value);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Premium Features'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Everything is stored locally and private to your device.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              _buildFeatureRow(
                p: p,
                icon: Icons.touch_app_rounded,
                title: 'Tap to save'.localized(context),
                text: 'Log a moment instantly from the main screen.'.localized(
                  context,
                ),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.swap_vert_rounded,
                title: 'Track starts and stops'.localized(context),
                text: 'Use Single or Two-Way mode based on your flow.'
                    .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.edit_note_rounded,
                title: 'Hold for notes'.localized(context),
                text: 'Attach context without slowing the app down.'.localized(
                  context,
                ),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.history_rounded,
                title: 'Review and export'.localized(context),
                text: 'Filter history, compare moments, export, or backup.'
                    .localized(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required Palette p,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: p.accent, size: 20),
          ),
          const SizedBox(width: 16),
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
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoMovePage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Repository Migration Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: GithubIcon(size: 36, color: p.accent),
          ),
          const SizedBox(height: 24),
          Text(
            'Official Repository Moved'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We have officially migrated our codebase to a new home. All future releases, updates, and issues will be managed here:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 24),

          // New Repo Card
          Glass(
            p: p,
            radius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GithubIcon(size: 20, color: p.text3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'github.com/dheeraz101/Notekar-Android',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text('Open Link'.localized(context)),
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          try {
                            await _fileChannel.invokeMethod<void>('openUrl', {
                              'url':
                                  'https://github.com/dheeraz101/Notekar-Android',
                            });
                          } catch (_) {}
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: p.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text('Copy'.localized(context)),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'https://github.com/dheeraz101/Notekar-Android',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Repository link copied to clipboard'.localized(
                                  context,
                                ),
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: p.text2,
                          side: BorderSide(color: p.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Benefits List
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.system_update_alt_rounded,
            title: 'Smaller, Optimized APKs'.localized(context),
            text:
                'Access split-per-ABI optimized binaries and Google Play AppBundles directly from the release page.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.bug_report_rounded,
            title: 'Active Issue Tracking'.localized(context),
            text:
                'Submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.security_rounded,
            title: 'Automated Security Scans'.localized(context),
            text:
                'All builds now undergo automated CodeQL scans and VirusTotal checks to ensure verification and safety.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMigrationBenefitRow({
    required Palette p,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surface3,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: p.accent, size: 18),
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
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesPermissionPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.install_mobile_rounded,
              color: p.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'In-App OTA Updates'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To download and install software updates directly within NoteKar, please configure the following security settings:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 28),

          // Setup Card 1: Notification Permission
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.notifications_active_rounded,
            title: 'Push Alerts & Notices'.localized(context),
            subtitle: 'Notifies you immediately when new releases are compiled.'.localized(context),
            isConfigured: _notificationGranted,
            buttonText: 'Grant Permission'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              final granted =
                  await _fileChannel.invokeMethod<bool>(
                    'requestNotificationPermission',
                  ) ??
                  false;
              if (granted) _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 2: Install Unknown Apps
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.settings_system_daydream_rounded,
            title: 'Allow App Installation'.localized(context),
            subtitle:
                'Required by Android to launch the system package archive installer for downloaded APKs.'
                    .localized(context),
            isConfigured: _installGranted,
            buttonText: 'Configure Settings'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod('openInstallPermissionSettings');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRemindersPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Reminders Hero Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.orange.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.orange.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: p.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reminders & Notifications'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule offline reminders to log your days. Android requires the following permissions to deliver alerts on time when killed:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 28),

          // Setup Card 1: Notification Permission
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.notifications_rounded,
            title: 'Allow Notifications'.localized(context),
            subtitle: 'Required to show the logging alerts.'.localized(context),
            isConfigured: _notificationGranted,
            buttonText: 'Grant Permission'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              final granted =
                  await _fileChannel.invokeMethod<bool>(
                    'requestNotificationPermission',
                  ) ??
                  false;
              if (granted) _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 2: Battery Optimization
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.battery_saver_rounded,
            title: 'Disable Battery Optimization'.localized(context),
            subtitle:
                'Ensures Android doesn\'t freeze or skip scheduled reminders.'
                    .localized(context),
            isConfigured: _batteryExempt,
            buttonText: 'Set Unrestricted'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod(
                'requestIgnoreBatteryOptimizations',
              );
              _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 3: Auto-Start (Xiaomi/Oppo/Vivo/etc.)
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.autorenew_rounded,
            title: 'Allow Auto-Start Settings'.localized(context),
            subtitle:
                'On Xiaomi, Oppo, Vivo, Samsung, or Huawei, the OS terminates killed apps unless Auto-Start is granted.'
                    .localized(context),
            isConfigured: false, // Cannot detect programmatically
            buttonText: 'Configure Settings'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod('openAutoStartSettings');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPermissionSetupCard({
    required Palette p,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConfigured,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Glass(
      p: p,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isConfigured
                  ? p.green.withValues(alpha: 0.14)
                  : p.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConfigured ? Icons.check_rounded : icon,
              color: isConfigured ? p.green : p.text3,
              size: 20,
            ),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                if (!isConfigured) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteFor(theme);
    final bool isLastPage = _currentPage == widget.pages.length - 1;

    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: p.text2,
                        size: 20,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 48, height: 48),

                  // Skip option for first-time setup
                  if (!isLastPage && widget.pages.length > 1)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Skip'.localized(context),
                        style: TextStyle(
                          color: p.text3,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                ],
              ),
            ),

            // Sliding Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: widget.pages.length == 1
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                children: widget.pages.map((key) {
                  if (key == 'welcome') return _buildWelcomePage(p);
                  if (key == 'features') return _buildFeaturesPage(p);
                  if (key == 'repo-move') return _buildRepoMovePage(p);
                  if (key == 'updates-permission') return _buildUpdatesPermissionPage(p);
                  if (key == 'reminders') return _buildRemindersPage(p);
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),

            // Pinned Bottom Control Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Dot indicators
                  if (widget.pages.length > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.pages.length, (index) {
                        final bool active = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? p.accent
                                : p.text3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Continue / Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          Navigator.pop(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      child: Text(
                        isLastPage
                            ? (widget.pages.length == 1
                                  ? 'Done'.localized(context)
                                  : 'Start Logging'.localized(context))
                            : 'Continue'.localized(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
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
