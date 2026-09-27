part of '../settings_dialog.dart';

extension _SettingsDialogSearchExtension on _SettingsDialogState {
  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
  >
  _allSettingsOptions() {
    final String deletedSubtitle =
        (widget.lastDeletedPreview != null &&
            widget.lastDeletedPreview!.isNotEmpty)
        ? widget.lastDeletedPreview!
        : 'Restore or permanently remove deleted moments';

    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );

    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
    item({
      required String title,
      required String subtitle,
      required String category,
      required IconData icon,
      required List<String> keywords,
      required String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    }) => (
      title: title,
      subtitle: subtitle,
      category: category,
      icon: icon,
      keywords: keywords,
      kind: kind,
      boolValue: boolValue,
      onBoolChanged: onBoolChanged,
      status: status,
    );

    return [
      item(
        title: 'Personal Profile',
        subtitle: 'Configure your name, photo, birth date, and avatar',
        category: 'Personalization',
        icon: CupertinoIcons.person_crop_circle,
        keywords: [
          'profile',
          'personal profile',
          'identity',
          'name',
          'avatar',
          'photo',
          'dob',
          'birth date',
          'picture',
          'personalization',
        ],
        kind: 'action',
        boolValue: null,
        onBoolChanged: null,
      ),
      item(
        title: 'Memento Mori Life Horizon',
        subtitle:
            'Visualize weeks lived vs remaining horizon, capped at 100 years',
        category: 'Dashboard',
        icon: CupertinoIcons.hourglass,
        keywords: [
          'memento mori',
          'life horizon',
          'age',
          'weeks lived',
          'remaining time',
          'stoic',
          'mortality',
          '100 years',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
      ),
      item(
        title: 'Targets & Goals',
        subtitle:
            'Allocate and track intentional hour targets across weeks, months, or tags',
        category: 'Targets & Goals',
        icon: Icons.track_changes_rounded,
        keywords: [
          'goals',
          'targets',
          'hours',
          'progress',
          'deficit',
          'intentionality',
          'timeframe',
          'quota',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
      ),
      item(
        title: 'Mode Glyph Icons',
        subtitle: 'Select minimal glyph icons for active and custom modes',
        category: 'Modes & Categories',
        icon: CupertinoIcons.sparkles,
        keywords: [
          'mode icons',
          'glyph',
          'icon',
          'category icon',
          'minimal glyph',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
      ),
      item(
        title: 'App Version',
        subtitle: 'The current software version installed',
        category: 'Advanced',
        icon: Icons.info_outline_rounded,
        keywords: [
          'version',
          'app version',
          'what is the version',
          'whats is the version',
          'build version',
          'software version',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'v$appVersion',
      ),
      item(
        title: 'Build Number',
        subtitle: 'The compiled internal build identifier',
        category: 'Advanced',
        icon: Icons.tag_rounded,
        keywords: [
          'build number',
          'build id',
          'build identifier',
          'compilation',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: kAppBuildNumber,
      ),
      item(
        title: 'Release Date',
        subtitle: 'When the current version was compiled',
        category: 'Advanced',
        icon: Icons.calendar_today_rounded,
        keywords: [
          'build date',
          'release date',
          'when was the current version released',
          'released date',
          'compiled date',
          'updated date',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: appBuildDate,
      ),
      item(
        title: 'Developer & Creator',
        subtitle: 'Designed & developed by Dheeraj',
        category: 'Advanced',
        icon: Icons.code_rounded,
        keywords: [
          'developer',
          'author',
          'who is the developer',
          'who is the author',
          'creator',
          'who made this app',
          'dheeraj',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Dheeraj',
      ),
      item(
        title: 'Open Source Codebase',
        subtitle: 'Licensed under MIT. Code available on GitHub',
        category: 'Advanced',
        icon: Icons.folder_open_rounded,
        keywords: [
          'is the app opensource',
          'opensource',
          'open source',
          'github code',
          'source code',
          'free software',
          'repository',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'MIT License',
      ),
      item(
        title: 'Security & Integrity',
        subtitle: 'Cryptographically verified with 0/60+ VirusTotal detections',
        category: 'Privacy & Security',
        icon: Icons.gpp_good_rounded,
        keywords: [
          'is the app secure',
          'is the app safe to use',
          'safe',
          'secure',
          'virus',
          'malware',
          'safety',
          'audited',
          'virustotal',
          'clean',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Verified Safe',
      ),
      item(
        title: 'Privacy & Local Storage',
        subtitle: '100% Offline-first. Zero trackers. Zero data collection',
        category: 'Privacy & Security',
        icon: Icons.shield_rounded,
        keywords: [
          'is the app private',
          'privacy policy',
          'trackers',
          'data collection',
          'spyware',
          'offline privacy',
          'private',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '100% Offline',
      ),
      item(
        title: 'Network Monitor',
        subtitle: 'Audit application network traffic logs',
        category: 'Advanced',
        icon: Icons.network_check_rounded,
        keywords: [
          'network monitor',
          'traffic',
          'internet',
          'data usage',
          'does the app use internet',
          'is the app sending data',
          'where does the app send data',
          'network traffic',
          'network logs',
          'wifi',
          'mobile data',
          'api logs',
          'requests',
          'privacy log',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Theme',
        subtitle: 'Dark, light, or amoled mode',
        category: 'Display',
        icon: Icons.brightness_6_rounded,
        keywords: ['theme', 'dark', 'light', 'amoled', 'appearance', 'mode'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: theme[0].toUpperCase() + theme.substring(1),
      ),
      item(
        title: 'Language',
        subtitle: 'Select application language',
        category: 'Language',
        icon: Icons.language_rounded,
        keywords: [
          'language',
          'locale',
          'translate',
          'multilingual',
          'internationalization',
          'translations',
          'i18n',
          'l10n',
          'english',
          'french',
          'francais',
          'hindi',
          'spanish',
          'espanol',
          'german',
          'deutsch',
          'japanese',
          'nihongo',
          'russian',
          'russkiy',
          'arabic',
          'portuguese',
          'italian',
          'chinese',
          'korean',
          'turkish',
          'dutch',
          'polish',
          'swedish',
          'indonesian',
          'vietnamese',
          'thai',
          'ukrainian',
          'greek',
          'czech',
          'romanian',
          'hungarian',
          'danish',
          'finnish',
          'norwegian',
          'hebrew',
          'bengali',
          'marathi',
          'telugu',
          'tamil',
          'gujarati',
          'urdu',
          'kannada',
          'malayalam',
          'punjabi',
          'swahili',
          'persian',
          'malay',
          'tagalog',
          'filipino',
          'slovak',
          'bulgarian',
          'croatian',
          'serbian',
          'lithuanian',
          'slovenian',
          'latvian',
          'estonian',
          'basque',
          'catalan',
          'welsh',
          'irish',
          'icelandic',
          'albanian',
          'macedonian',
          'armenian',
          'georgian',
          'numerals',
          'devanagari',
          'currency',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: switch (currentLocale) {
          'en' => 'English',
          'fr' => 'Français',
          'hi' => 'हिन्दी',
          'es' => 'Español',
          'de' => 'Deutsch',
          'ja' => '日本語',
          'ru' => 'Русский',
          _ => 'System Default',
        },
      ),
      item(
        title: 'Show Seconds',
        subtitle: 'Display seconds on the home clock',
        category: 'Display',
        icon: Icons.timer_rounded,
        keywords: ['seconds', 'clock', 'time', 'display'],
        kind: 'switch',
        boolValue: showSeconds,
        onBoolChanged: (bool value) {
          update(() => showSeconds = value);
          widget.onShowSeconds(value);
        },
        status: null,
      ),
      item(
        title: 'Highlight Seconds',
        subtitle: 'Colored seconds in two-way mode',
        category: 'Display',
        icon: Icons.auto_awesome_rounded,
        keywords: ['seconds', 'highlight', 'color', 'clock'],
        kind: 'switch',
        boolValue: highlightSeconds,
        onBoolChanged: (bool value) {
          update(() => highlightSeconds = value);
          widget.onHighlightSeconds(value);
        },
        status: null,
      ),
      item(
        title: 'Time Format',
        subtitle:
            'Choose between 12-hour AM/PM or international 24-hour time across the app',
        category: 'Display',
        icon: Icons.schedule_rounded,
        keywords: [
          '24-hour',
          '12-hour',
          'am pm',
          'clock',
          'time format',
          'hours',
          'military time',
        ],
        kind: 'navigation',
        status: use24Hour ? '24-Hour' : '12-Hour',
      ),
      item(
        title: 'Clock Typography',
        subtitle:
            'Choose between Condensed Digital or Geometric Modern typography for the home clock',
        category: 'Display',
        icon: Icons.font_download_rounded,
        keywords: [
          'font',
          'clock typography',
          'condensed digital',
          'geometric modern',
          'bebas',
          'inter',
        ],
        kind: 'navigation',
        status: clockFont == 'Inter' ? 'Geometric Modern' : 'Condensed Digital',
      ),
      item(
        title: 'Button Labels',
        subtitle: 'Show text labels under toolbar icons',
        category: 'Display',
        icon: Icons.label_rounded,
        keywords: ['labels', 'text', 'icons', 'toolbar', 'names'],
        kind: 'switch',
        boolValue: buttonLabels,
        onBoolChanged: (bool value) {
          update(() => buttonLabels = value);
          widget.onButtonLabels(value);
        },
        status: null,
      ),
      item(
        title: 'Large Controls',
        subtitle: 'Increase touch targets for primary actions',
        category: 'Display',
        icon: Icons.ads_click_rounded,
        keywords: ['large', 'size', 'buttons', 'controls', 'touch'],
        kind: 'switch',
        boolValue: largeControls,
        onBoolChanged: (bool value) {
          update(() => largeControls = value);
          widget.onLargeControls(value);
        },
        status: null,
      ),
      item(
        title: 'Toolbar Backplate',
        subtitle: 'Show a subtle background pill for the toolbar',
        category: 'Display',
        icon: Icons.shape_line_rounded,
        keywords: ['toolbar', 'backplate', 'pill', 'background', 'style'],
        kind: 'switch',
        boolValue: homeMenuPill,
        onBoolChanged: (bool value) {
          update(() => homeMenuPill = value);
          widget.onHomeMenuPill(value);
        },
        status: null,
      ),
      item(
        title: 'Live Icon Motion',
        subtitle: 'Physics-based icon animations on the home screen',
        category: 'Display',
        icon: Icons.motion_photos_auto_rounded,
        keywords: ['motion', 'animation', 'icon', 'physics', 'live', 'effects'],
        kind: 'switch',
        boolValue: homeMenuAnimations,
        onBoolChanged: (bool value) {
          widget.onHomeMenuAnimations(value).then((applied) {
            if (!mounted) return;
            update(() {
              homeMenuAnimations = applied ? value : false;
            });
          });
        },
        status: null,
      ),
      item(
        title: 'Enable Translucency',
        subtitle: 'Glass-like blur effects on system surfaces',
        category: 'Display',
        icon: Icons.opacity_rounded,
        keywords: ['blur', 'glass', 'transparency', 'translucent', 'effects'],
        kind: 'switch',
        boolValue: enableTranslucency,
        onBoolChanged: (bool value) {
          update(() => enableTranslucency = value);
          widget.onTranslucency(value);
        },
        status: null,
      ),
      item(
        title: 'History Text',
        subtitle: 'Show "HISTORY" label on the home button',
        category: 'Display',
        icon: Icons.format_list_bulleted_rounded,
        keywords: ['history', 'text', 'label', 'home'],
        kind: 'switch',
        boolValue: showHistoryText,
        onBoolChanged: (bool value) {
          update(() => showHistoryText = value);
          widget.onShowHistoryText(value);
        },
        status: null,
      ),
      item(
        title: 'Last Saved Hint',
        subtitle: 'Show time since the last moment was saved',
        category: 'Display',
        icon: Icons.tips_and_updates_rounded,
        keywords: ['hint', 'last saved', 'time', 'feedback'],
        kind: 'switch',
        boolValue: showLastSavedHint,
        onBoolChanged: (bool value) {
          update(() => showLastSavedHint = value);
          widget.onShowLastSavedHint(value);
        },
        status: null,
      ),
      item(
        title: 'Accent Color',
        subtitle: 'Choose a primary color for the interface',
        category: 'Accent Color',
        icon: Icons.palette_rounded,
        keywords: ['accent', 'color', 'theme', 'tint', 'highlights'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: accentColor[0].toUpperCase() + accentColor.substring(1),
      ),
      item(
        title: 'App Icons',
        subtitle: 'Personalize with 8 handcrafted luxury editions',
        category: 'App Icons',
        icon: Icons.apps_rounded,
        keywords: [
          'icon',
          'launcher',
          'home screen',
          'app icon',
          'aurora',
          'midnight',
          'sapphire',
          'imperial',
          'emerald',
          'sunset',
          'crimson',
          'amethyst',
          'logo',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: switch (appIconStyle) {
          'default' => 'Aurora',
          'black' => 'Midnight',
          'blue' => 'Sapphire',
          'gold' => 'Imperial',
          'green' => 'Emerald',
          'orange' => 'Sunset',
          'red' => 'Crimson',
          'purple' => 'Amethyst',
          _ => 'Aurora',
        },
      ),
      item(
        title: 'Developer Options',
        subtitle: 'Diagnostics, device health, network monitor, and commits',
        category: 'Developer Options',
        icon: Icons.developer_mode_rounded,
        keywords: [
          'developer',
          'options',
          'debug',
          'commits',
          'diagnostics',
          'device health',
          'network monitor',
          'logs',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Sobriety Tracker',
        subtitle: 'Track recovery streak, milestone badges, and export cards',
        category: 'Sobriety',
        icon: Icons.spa_rounded,
        keywords: [
          'sobriety',
          'tracker',
          'days sober',
          'milestones',
          'streak',
          'badges',
          'celebration',
          'pledge',
          'clean',
          'recovery',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: enableSobrietyMode ? 'Active' : 'Off',
      ),
      item(
        title: 'Life Ledger Timeline',
        subtitle:
            'Chronological timeline with session pairing, live end & calendar',
        category: 'Help & Guides',
        icon: Icons.auto_stories_rounded,
        keywords: [
          'history',
          'timeline',
          'life ledger',
          'sessions',
          'session pairing',
          'live session',
          'end session',
          'stop session',
          'in out',
          'single moments',
          'calendar',
          'calendar picker',
          'date filter',
          'event dots',
          'review moments',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Tour',
      ),
      item(
        title: 'Executive Intelligence Hub',
        subtitle:
            'Grounded daily rhythm, 90-day activity grid & circadian trends',
        category: 'Dashboard',
        icon: Icons.dashboard_customize_outlined,
        keywords: [
          'dashboard',
          'analytics',
          'executive intelligence hub',
          'intelligence hub',
          'heatmap',
          'trends',
          'insights',
          'graphs',
          'correlation',
          'habits',
          'charts',
          'summary',
          'history grid',
          'daily rhythm',
          'rhythm',
          'bar chart',
          'activity grid',
          '90 days',
          'last 90 days',
          'circadian',
          'today',
          'week',
          'month',
          'time scope',
          'streak',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Life Audit & Time Wastage',
        subtitle:
            'Confront the cost of unaccounted time across daily, weekly, and yearly horizons',
        category: 'Life Audit',
        icon: CupertinoIcons.circle_grid_hex,
        keywords: [
          'life audit',
          'audit',
          'time wastage',
          'wasted',
          'void',
          'unaccounted',
          'sleep',
          'food',
          'travel',
          'commute',
          'conscious',
          'mortality',
          'crucible',
          'half quarter',
          'half year',
          '6 weeks',
          '6 months',
          'year',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Audit',
      ),
      item(
        title: 'App Philosophy',
        subtitle: 'Timeless craft and radical privacy',
        category: 'About',
        icon: Icons.auto_awesome_rounded,
        keywords: [
          'philosophy',
          'manifesto',
          'craftsmanship',
          'timeless',
          'privacy',
          'offline',
          'craft',
          'design',
          'principles',
          'about',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Manifesto',
      ),
      item(
        title: 'Upcoming Features',
        subtitle: 'Roadmap, voice notes, AI insights, and P2P sync',
        category: 'About',
        icon: CupertinoIcons.sparkles,
        keywords: [
          'upcoming',
          'features',
          'roadmap',
          'voice notes',
          'speech to text',
          'ai',
          'whisper',
          'sync',
          'future',
          'about',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Roadmap',
      ),
      item(
        title: 'Life Audit',
        subtitle:
            'Track unaccounted time, sleep, logistics, and productive hours across horizons',
        category: 'Life Audit',
        icon: Icons.timelapse_rounded,
        keywords: [
          'life audit',
          'audit',
          'time waste',
          'wastage',
          'sleep',
          'logistics',
          'unaccounted',
          'wasted time',
          'horizons',
          'reality check',
          '24 hours',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Audit',
      ),
      item(
        title: 'Dashboard',
        subtitle: 'Interactive summaries, grids, trends, and correlations',
        category: 'Dashboard',
        icon: Icons.dashboard_customize_outlined,
        keywords: [
          'dashboard',
          'analytics',
          'heatmap',
          'trends',
          'insights',
          'graphs',
          'correlation',
          'habits',
          'charts',
          'summary',
          'history grid',
          'daily rhythm',
          'rhythm',
          'bar chart',
          'activity grid',
          '90 days',
          'circadian',
          'time scope',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Logging',
        subtitle: 'Configure default mode, tap cooldowns, and reminders',
        category: 'Logging',
        icon: Icons.bolt_rounded,
        keywords: [
          'logging',
          'captures',
          'moments',
          'default mode',
          'cooldown',
          'intervals',
          'startup',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: defaultModeLabel(defaultMode),
      ),
      item(
        title: 'Modes',
        subtitle:
            'Focus categories, custom modes, and category history breakdown',
        category: 'Modes',
        icon: Icons.category_rounded,
        keywords: [
          'modes',
          'mode',
          'category',
          'categories',
          'work',
          'deep focus',
          'custom mode',
          'focus',
          'tagging',
          'badges',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Manage',
      ),
      item(
        title: 'Ergonomic Tap Zone',
        subtitle:
            'Clock-centered hit box with edge-to-edge width to prevent ghost touches',
        category: 'Logging',
        icon: Icons.touch_app_rounded,
        keywords: [
          'ergonomic',
          'tap zone',
          'safety zone',
          'tap area',
          'ghost touch',
          'accidental tap',
          'dead zone',
          'clock',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Active',
      ),
      item(
        title: 'Android Home Screen Widgets',
        subtitle:
            'Quick Log, Sobriety Companion, and Life Audit widgets for home screen',
        category: 'Logging',
        icon: Icons.widgets_rounded,
        keywords: [
          'widget',
          'widgets',
          'launcher',
          'home screen',
          'quick log widget',
          'sobriety widget',
          'life audit widget',
          'lock screen',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '3 Widgets',
      ),
      item(
        title: 'Startup Mode',
        subtitle: 'Default mode when opening the app',
        category: 'Capture',
        icon: Icons.bolt_rounded,
        keywords: [
          'startup',
          'mode',
          'default',
          'capture',
          'two-way',
          'single',
          'last-used',
          'last used',
          'remember',
          'recent',
          'resume',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: defaultModeLabel(defaultMode),
      ),
      item(
        title: 'Remember Last Mode',
        subtitle:
            'Resume whichever mode was active when you last closed the app',
        category: 'Capture',
        icon: Icons.history_toggle_off_rounded,
        keywords: [
          'last used',
          'remember',
          'resume',
          'startup',
          'mode',
          'capture',
          'recent',
          'restore',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: defaultMode == 'last-used' ? 'Active' : 'Off',
      ),
      item(
        title: 'Tap Delay',
        subtitle: 'Minimum time between accidental taps',
        category: 'Capture',
        icon: Icons.slow_motion_video_rounded,
        keywords: ['delay', 'tap', 'cooldown', 'accident', 'speed'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: delayLabel(tapDelay),
      ),
      item(
        title: 'Note on Click',
        subtitle:
            'Tap to compose a note before logging. When disabled, tapping logs instantly and holding prompts for a note.',
        category: 'Capture',
        icon: Icons.edit_note_rounded,
        keywords: [
          'note',
          'click',
          'tap',
          'compose',
          'capture',
          'prompt',
          'single',
          'two-way',
          'write note',
        ],
        kind: 'switch',
        boolValue: enableNoteOnClick,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('enable_note_on_click', value);
          }
          update(() => enableNoteOnClick = value);
        },
        status: null,
      ),
      item(
        title: 'Plus Notes',
        subtitle: 'Unrestricted long-form journaling and meeting logs',
        category: 'Moments',
        icon: CupertinoIcons.plus_app,
        keywords: [
          'plus',
          'plus note',
          'big note',
          'journal',
          'journaling',
          'writing',
          'long note',
          'notes',
          'character limit',
          'unrestricted',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Unrestricted',
      ),
      item(
        title: 'Customizable Hashtags',
        subtitle: 'Tailor quick tag chips in note editor with long press',
        category: 'Moments',
        icon: Icons.tag_rounded,
        keywords: [
          'tag',
          'tags',
          'hashtag',
          'hashtags',
          'custom tags',
          'quick tags',
          'chips',
          'notes',
          'edit tags',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Custom',
      ),
      item(
        title: 'Compact History',
        subtitle: 'Denser rows for scanning many moments',
        category: 'Moments',
        icon: Icons.view_agenda_rounded,
        keywords: [
          'compact',
          'history',
          'density',
          'list',
          'rows',
          'pinch-to-density',
          'pinch zoom',
          'comfortable',
          'two fingers',
        ],
        kind: 'switch',
        boolValue: compactHistory,
        onBoolChanged: (bool value) async {
          if (value && useNumbersInSingle) {
            final confirmed = await showFeatureConflictDialog(
              context,
              p: p,
              title: 'Turn Off Single Numbers?',
              message:
                  'Compact History cannot be enabled while Single Moment Numbering is active. Disable Single Numbers to use compact rows.',
              confirmLabel: 'Turn Off & Enable',
              icon: Icons.compress_rounded,
              iconColor: p.accent,
            );
            if (!confirmed) return;
            update(() => useNumbersInSingle = false);
            widget.onUseNumbersInSingle?.call(false);
          }
          update(() {
            compactHistory = value;
            historyDensity = value ? 'compact' : 'comfortable';
          });
          widget.onCompactHistory(value);
          widget.onHistoryDensity(historyDensity);
        },
        status: null,
      ),
      item(
        title: 'Confirm Delete',
        subtitle: 'Show a prompt before deleting moments',
        category: 'Moments',
        icon: Icons.delete_sweep_rounded,
        keywords: [
          'delete',
          'confirm',
          'safety',
          'prompt',
          'remove',
          'swipe to delete',
          'bed of red',
          'undo',
          'dynamic island',
        ],
        kind: 'switch',
        boolValue: confirmDelete,
        onBoolChanged: (bool value) {
          update(() => confirmDelete = value);
          widget.onConfirmDelete(value);
        },
        status: null,
      ),
      item(
        title: 'Extended Duration',
        subtitle: 'Show days, months, and years in time between moments',
        category: 'Moments',
        icon: Icons.timer_rounded,
        keywords: [
          'time',
          'duration',
          'years',
          'months',
          'days',
          'long intervals',
          'history',
        ],
        kind: 'switch',
        boolValue: extendedDuration,
        onBoolChanged: (bool value) {
          update(() => extendedDuration = value);
          widget.onExtendedDuration(value);
        },
        status: null,
      ),
      item(
        title: 'Time Difference Comparison',
        subtitle:
            'Compare time elapsed between any two moments in history calendar or search',
        category: 'Moments',
        icon: Icons.compare_arrows_rounded,
        keywords: [
          'time difference',
          'compare',
          'delta',
          'elapsed',
          'between moments',
          'difference',
          'duration',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
      ),
      item(
        title: 'Minimal Moment Options',
        subtitle: 'Use a compact horizontal row of icons for actions',
        category: 'Moments',
        icon: Icons.auto_awesome_motion_rounded,
        keywords: ['minimal', 'icons', 'actions', 'compact', 'row', 'history'],
        kind: 'switch',
        boolValue: minimalMomentOptions,
        onBoolChanged: (bool value) {
          update(() => minimalMomentOptions = value);
          widget.onMinimalMomentOptions(value);
        },
        status: null,
      ),
      item(
        title: 'Use Numbers in Single',
        subtitle:
            'Display sequential 2-digit numbers (00–99) instead of icons in single history moments',
        category: 'Moments',
        icon: Icons.pin_outlined,
        keywords: [
          'single',
          'numbers',
          'counter',
          'digits',
          'history',
          'moments',
          '00',
        ],
        kind: 'switch',
        boolValue: useNumbersInSingle,
        onBoolChanged: (bool value) async {
          if (value && compactHistory) {
            final confirmed = await showFeatureConflictDialog(
              context,
              p: p,
              title: 'Disable Compact History?',
              message:
                  'Sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. Turn off Compact History to enable numbers in single mode.',
              confirmLabel: 'Turn Off & Enable',
              icon: Icons.pin_outlined,
              iconColor: p.accent,
            );
            if (!confirmed) return;
            update(() {
              compactHistory = false;
              historyDensity = 'comfortable';
            });
            widget.onCompactHistory(false);
            widget.onHistoryDensity('comfortable');
          }
          update(() => useNumbersInSingle = value);
          widget.onUseNumbersInSingle?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Reset Daily',
        subtitle:
            'Restart single count from 00 every calendar day while preserving past history',
        category: 'Moments',
        icon: Icons.restart_alt_rounded,
        keywords: [
          'reset',
          'daily',
          'midnight',
          'single',
          'counter',
          'day',
          'history',
        ],
        kind: 'switch',
        boolValue: resetSingleDaily,
        onBoolChanged: (bool value) {
          update(() => resetSingleDaily = value);
          widget.onResetSingleDaily?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Enable Count on Save',
        subtitle:
            'Show the 2-digit count on the tap pulse animation instead of "SINGLE saved"',
        category: 'Moments',
        icon: Icons.touch_app_outlined,
        keywords: [
          'save',
          'count',
          'timer',
          'pulse',
          'single',
          'feedback',
          'tap',
        ],
        kind: 'switch',
        boolValue: countOnSave,
        onBoolChanged: (bool value) {
          update(() => countOnSave = value);
          widget.onCountOnSave?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Trash Bin',
        subtitle: deletedSubtitle,
        category: 'Logging',
        icon: Icons.delete_outline_rounded,
        keywords: ['trash', 'deleted', 'restore', 'remove', 'history', 'bin'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '${_trash.length} items',
      ),
      item(
        title: 'Rainbow Cards',
        subtitle:
            'Subtle category chromatic tinting across timeline, calendar, and search cards',
        category: 'Logging',
        icon: Icons.palette_outlined,
        keywords: [
          'rainbow',
          'rainbow cards',
          'chromatic',
          'tint',
          'category color',
          'cards',
          'palette',
        ],
        kind: 'switch',
        boolValue: _rainbowCards,
        onBoolChanged: (bool value) async {
          update(() => _rainbowCards = value);
          if (_prefs != null) {
            await _prefs!.setBool('m-rainbow-cards', value);
          }
        },
        status: null,
      ),
      item(
        title: 'Updates & Notices',
        subtitle: 'Software update, app notices, changelog',
        category: 'Updates & Notices',
        icon: Icons.update_rounded,
        keywords: [
          'update',
          'github',
          'release',
          'notification',
          'notice',
          'version',
          'check',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _betaTrack ? 'Beta' : 'Stable',
      ),
      item(
        title: 'Rm -rf Cache',
        subtitle: 'Automatically delete update packages as they are installed',
        category: 'Updates & Notices',
        icon: Icons.auto_delete_outlined,
        keywords: [
          'rm -rf cache',
          'rm -rf',
          'rm',
          'auto delete update cache',
          'auto delete',
          'cache',
          'update cache',
          'delete cache',
          'clear cache',
          'storage',
          'installers',
          'apk',
          'clean',
          'purge',
          'free space',
        ],
        kind: 'switch',
        boolValue: _autoDeleteUpdateCache,
        onBoolChanged: (val) => _handleAutoDeleteUpdateCache(val, p),
        status: _autoDeleteUpdateCache ? 'On' : 'Off',
      ),
      item(
        title: 'Official Bulletins',
        subtitle: 'Critical advisories, release highlights & bulletins',
        category: 'Updates & Notices',
        icon: Icons.campaign_rounded,
        keywords: [
          'official bulletins',
          'bulletins',
          'advisories',
          'official',
          'alerts',
          'security advisories',
          'notices',
          'announcements',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: "What's New",
        subtitle: 'Keynote release innovations & highlights',
        category: "What's New",
        icon: Icons.auto_awesome_rounded,
        keywords: [
          'new',
          'latest',
          'release',
          'features',
          'changelog',
          'keynote',
          'innovations',
          'pinch-to-density',
          'bed of red',
          'cupertino alerts',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Changelog',
        subtitle: 'Release history and fixes',
        category: 'Changelog',
        icon: Icons.article_rounded,
        keywords: ['changes', 'release notes', 'version', 'history', 'log'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Update Track',
        subtitle: 'Choose between Stable and Beta releases',
        category: 'Updates & Notices',
        icon: Icons.track_changes_rounded,
        keywords: ['update', 'track', 'beta', 'stable', 'release', 'notices'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: _betaTrack ? 'Beta' : 'Stable',
      ),
      item(
        title: 'VirusTotal Scan',
        subtitle: 'Dynamic scan report, security ratio, and signature status',
        category: 'Updates & Notices',
        icon: Icons.security_rounded,
        keywords: [
          'security',
          'virustotal',
          'scan',
          'malicious',
          'clean',
          'undetected',
          'ratio',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _vtRatio,
      ),
      item(
        title: 'Offline Commits Cache',
        subtitle: 'View downloaded update commits feed offline',
        category: 'Developer Options',
        icon: Icons.history_rounded,
        keywords: [
          'commits',
          'cache',
          'github',
          'history',
          'feed',
          'offline',
          'developer',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _prefs != null && _prefs!.containsKey('notekar.commits_cache')
            ? 'Cached'
            : 'Empty',
      ),
      item(
        title: 'Backup & Export',
        subtitle:
            'CSV, JSON, download, restore, import, file, reminder, health',
        category: 'Logging',
        icon: Icons.import_export_rounded,
        keywords: [
          'csv',
          'json',
          'download',
          'restore',
          'import',
          'file',
          'reminder',
          'health',
          'data',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '${entries.length} Logs',
      ),
      item(
        title: 'Migrate from Other Apps',
        subtitle: 'Import Loop Habit Tracker CSV or HabitKit JSON',
        category: 'Backup & Export',
        icon: Icons.swap_horiz_rounded,
        keywords: [
          'migrate',
          'migration',
          'loop',
          'loop habit tracker',
          'habitkit',
          'csv',
          'json',
          'import',
          'transfer',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Import',
      ),
      item(
        title: 'Backup Status',
        subtitle: 'Android backup, health, encryption, and Drive plans',
        category: 'Logging',
        icon: Icons.cloud_done_rounded,
        keywords: [
          'android backup',
          'backup health',
          'data health',
          'encrypted backup',
          'google drive',
          'drive backup',
          'cloud',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _dataHealthStatus,
      ),
      item(
        title: 'Privacy & Security',
        subtitle: 'Local storage, network use, and data safety',
        category: 'Privacy & Security',
        icon: Icons.verified_user_rounded,
        keywords: [
          'private',
          'security',
          'safe',
          'secure',
          'encryption',
          'tracking',
          'analytics',
          'data',
          'policy',
          'drive',
          'google',
          'lock',
          'biometric',
          'password',
          'pin',
          'local',
          'virustotal',
          'vt',
          'sha-256',
          'checksum',
          'safety verification',
          'malware scan',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: privacyLock ? 'On' : 'Off',
      ),
      item(
        title: 'App Lock',
        subtitle: 'Screen lock and lock timing',
        category: 'App Lock',
        icon: Icons.lock_rounded,
        keywords: [
          'privacy lock',
          'app lock',
          'screen lock',
          'biometric',
          'pin',
          'password',
          'lock timing',
          'fingerprint',
          'face id',
        ],
        kind: 'switch',
        boolValue: privacyLock,
        onBoolChanged: (bool value) {
          if (!value) {
            widget.onPrivacyLock(false).then((_) {
              if (mounted) update(() => privacyLock = false);
            });
            return;
          }
          widget.onPrivacyLock(true).then((changed) {
            if (changed && mounted) {
              update(() => privacyLock = true);
            }
          });
        },
        status: null,
      ),
      item(
        title: 'Hide App Content',
        subtitle:
            'Obfuscate screens and block screenshots in the system switcher',
        category: 'Privacy & Security',
        icon: Icons.screenshot_rounded,
        keywords: [
          'hide content',
          'recents',
          'app switcher',
          'obfuscate',
          'screenshot',
          'prevent screenshots',
          'privacy screen',
        ],
        kind: 'switch',
        boolValue: obfuscateInRecents,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('obfuscate_in_recents', value);
          }
          update(() => obfuscateInRecents = value);
          try {
            await const MethodChannel(
              'notekar/files',
            ).invokeMethod<void>('setObfuscateInRecents', {'enabled': value});
          } catch (_) {}
        },
        status: null,
      ),
      item(
        title: 'Persistent Control',
        subtitle:
            'Show a sticky notification in the drawer to log check-in/out from lock screen',
        category: 'Logging',
        icon: Icons.notification_important_rounded,
        keywords: [
          'control panel',
          'persistent',
          'notification',
          'lock screen',
          'lockscreen log',
          'sticky notification',
          'quick log notification',
        ],
        kind: 'switch',
        boolValue: showPersistentNotification,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('show_persistent_notification', value);
          }
          update(() => showPersistentNotification = value);
          try {
            await const MethodChannel('notekar/files').invokeMethod<void>(
              'setPersistentControlPanel',
              {'enabled': value},
            );
          } catch (_) {}
        },
        status: null,
      ),
      if (privacyLock && widget.isSystemLockAvailable)
        item(
          title: 'Configure Lock',
          subtitle: 'Choose between System Lock or In-App PIN',
          category: 'Configure Lock',
          icon: Icons.security_rounded,
          keywords: [
            'configure lock',
            'system lock',
            'in-app pin',
            'custom lock',
            'change passcode',
            'biometric selector',
            'pin type',
          ],
          kind: 'nav',
          boolValue: null,
          onBoolChanged: null,
          status: privacyLockType == 'system' ? 'System Lock' : 'In-App PIN',
        ),
      if (privacyLock)
        item(
          title: 'When to Lock',
          subtitle: 'Change screen lock timing delay',
          category: 'App Lock',
          icon: Icons.timer_rounded,
          keywords: [
            'delay',
            'lock timing',
            'lock delay',
            'immediately',
            'after 1 minute',
            'when to lock',
          ],
          kind: 'nav',
          boolValue: null,
          onBoolChanged: null,
          status: privacyLockDelayMinutes == 0
              ? 'Immediately'
              : 'After $privacyLockDelayMinutes Min',
        ),
      item(
        title: 'Accessibility',
        subtitle: 'Haptic style, motion, larger text, high contrast',
        category: 'Accessibility',
        icon: Icons.accessibility_new_rounded,
        keywords: [
          'haptic',
          'vibration',
          'motion',
          'text',
          'contrast',
          'large',
          'quick action',
          'shortcut',
          'a11y',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: hapticStyle[0].toUpperCase() + hapticStyle.substring(1),
      ),
      item(
        title: 'Sound Effects',
        subtitle: 'Subtle acoustic click feedback on logging and interactions',
        category: 'Accessibility',
        icon: Icons.volume_up_rounded,
        keywords: [
          'sound',
          'sound effects',
          'acoustic',
          'audio',
          'click',
          'feedback',
          'audio feedback',
          'click sound',
        ],
        kind: 'switch',
        boolValue: soundEffects,
        onBoolChanged: (bool value) async {
          update(() => soundEffects = value);
          widget.onSoundEffects?.call(value);
          AppSound.setEnabled(value);
          if (value) AppSound.click();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('m-acoustic-feedback', value);
        },
        status: null,
      ),
      item(
        title: 'Diagnostics',
        subtitle: 'Version, storage, backup, update status',
        category: 'Diagnostics',
        icon: Icons.monitor_heart_rounded,
        keywords: ['debug', 'support', 'info', 'bug', 'copy', 'logs'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Device Health',
        subtitle:
            'Adaptive engine, hardware diagnostics, and performance status',
        category: 'Device Health',
        icon: Icons.health_and_safety_rounded,
        keywords: [
          'adaptive engine',
          'performance',
          'hardware',
          'specs',
          'optimization',
          'tier',
          'ram',
          'cpu',
          'cores',
          'low end',
          'lag',
          'device health',
          'diagnostics',
          'status',
          'frame rate',
          'fps',
          'system blur',
          'live animations',
          'tuning',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: AdaptiveEngine().healthStatus,
      ),
      item(
        title: 'Performance Tiers & Capabilities',
        subtitle: 'Hardware tier, 120 FPS live physics, and visual tuning',
        category: 'Device Health',
        icon: Icons.speed_rounded,
        keywords: [
          'performance tier',
          'tier',
          'fps',
          '120 fps',
          '60 fps',
          'frame rate',
          'hardware tuning',
          'capabilities',
          'power saver',
          'balanced',
          'optimal',
          'speed',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: AdaptiveEngine().tierLabel,
      ),
      item(
        title: 'System Blur & Visual Effects',
        subtitle: 'Glassmorphism blur support and live animations status',
        category: 'Device Health',
        icon: Icons.blur_on_rounded,
        keywords: [
          'system blur',
          'blur',
          'glass',
          'glassmorphism',
          'translucency',
          'live animations',
          'visual effects',
          'particles',
          'hardware limited',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: AdaptiveEngine().blurStatusLabel,
      ),
      item(
        title: 'Network Monitor',
        subtitle: 'Audit application network traffic logs',
        category: 'Network Monitor',
        icon: Icons.network_check_rounded,
        keywords: [
          'network monitor',
          'traffic',
          'internet',
          'data usage',
          'audit',
          'privacy log',
          'api requests',
          'wifi',
          'bytes',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      if (_isGodModeUnlocked)
        item(
          title: 'God Mode',
          subtitle: 'Secret themes and VIP pioneer badge',
          category: 'God Mode',
          icon: Icons.auto_awesome_rounded,
          keywords: [
            'god mode',
            'godmode',
            'matrix',
            'terminal',
            'eink',
            'e-ink',
            'pioneer',
            'vip',
            'badge',
            'developer',
            'easter egg',
          ],
          kind: 'nav',
          boolValue: null,
          onBoolChanged: null,
          status: 'Unlocked',
        ),
      item(
        title: 'Integrations & Automation',
        subtitle:
            'URL schemes, text selection, share target, Markdown sync, and Tasker broadcast API',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.link,
        keywords: [
          'integration',
          'integrations',
          'automation',
          'url scheme',
          'deep link',
          'obsidian',
          'logseq',
          'markdown',
          'calendar',
          'ics',
          'tasker',
          'macrodroid',
          'broadcast',
          'share',
          'selection',
          'nfc',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Bridges',
      ),
      item(
        title: 'Deep Linking & URL Schemes',
        subtitle:
            'Log moments, trigger IN/OUT, or navigate with notekar:// links',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.link,
        keywords: [
          'notekar://',
          'url scheme',
          'deep link',
          'nfc',
          'browser shortcut',
          'notekar://log',
          'notekar://in',
          'notekar://out',
          'notekar://note',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Active',
      ),
      item(
        title: 'Text Selection Context Menu',
        subtitle: 'Highlight text anywhere in Android and tap "Log in NoteKar"',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.selection_pin_in_out,
        keywords: [
          'process text',
          'text selection',
          'highlight',
          'context menu',
          'log in notekar',
          'quote capture',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Active',
      ),
      item(
        title: 'Android Share Target',
        subtitle: 'Share text and URLs from external apps directly to NoteKar',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.share,
        keywords: [
          'share sheet',
          'action send',
          'share to notekar',
          'text share',
          'url share',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Active',
      ),
      item(
        title: 'Obsidian & Markdown Journal Sync',
        subtitle:
            'Export date-grouped Markdown tables compatible with Obsidian & Logseq',
        category: 'Integrations & Automation',
        icon: Icons.article_rounded,
        keywords: [
          'obsidian',
          'logseq',
          'notion',
          'markdown',
          'md export',
          'second brain',
          'vault sync',
          'journal',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Export',
      ),
      item(
        title: 'Calendar Sessions (.ics) Export',
        subtitle: 'Export Two-Way IN/OUT intervals as RFC 5545 calendar events',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.calendar,
        keywords: [
          'calendar',
          'ics',
          'ical',
          'google calendar',
          'outlook',
          'samsung calendar',
          'proton calendar',
          'session export',
          'two way calendar',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Export',
      ),
      item(
        title: 'Tasker & MacroDroid Broadcast API',
        subtitle:
            'Send app.notekar.notekar.ACTION_LOG_MOMENT broadcasts offline',
        category: 'Integrations & Automation',
        icon: CupertinoIcons.radiowaves_right,
        keywords: [
          'tasker',
          'macrodroid',
          'termux',
          'automate',
          'broadcast',
          'intent',
          'action_log_moment',
          'cli',
          'am broadcast',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'API',
      ),
      item(
        title: 'Reset All Data',
        subtitle: 'Erase every moment and note',
        category: 'Reset',
        icon: Icons.delete_outline_rounded,
        keywords: [
          'clear',
          'erase',
          'delete everything',
          'factory reset',
          'wipe',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Factory Reset',
        subtitle: 'Erase data and settings, then show welcome',
        category: 'Reset',
        icon: Icons.restart_alt_rounded,
        keywords: ['fresh start', 'welcome', 'reset app', 'new app', 'wipe'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Reset Settings Only',
        subtitle: 'Restore preferences and keep moments',
        category: 'Reset',
        icon: Icons.settings_backup_restore_rounded,
        keywords: ['preferences', 'defaults', 'settings reset', 'undo'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Privacy Policy',
        subtitle: 'Data safety and local storage commitment',
        category: 'Privacy Policy',
        icon: Icons.privacy_tip_rounded,
        keywords: [
          'privacy',
          'policy',
          'data',
          'safety',
          'local',
          'offline',
          'legal',
          'google',
          'play',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Terms of Use',
        subtitle: 'App usage rules and open source terms',
        category: 'Terms of Use',
        icon: Icons.gavel_rounded,
        keywords: [
          'terms',
          'usage',
          'rules',
          'conditions',
          'legal',
          'google',
          'play',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Licenses',
        subtitle: 'Software credits and open source legal notices',
        category: 'Licenses',
        icon: Icons.description_rounded,
        keywords: [
          'license',
          'legal',
          'credits',
          'open source',
          'libraries',
          'packages',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Guides',
        subtitle: 'Learn taps, notes, history, and backups',
        category: 'Help & Guides',
        icon: Icons.map_rounded,
        keywords: [
          'guide',
          'help',
          'how to',
          'tap',
          'hold',
          'long press',
          'note',
          'history',
          'duration',
          'time between',
          'backup',
          'adaptive engine',
          'minimal options',
          'tutorial',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Help',
        subtitle: 'Fix updates, backups, notices, motion, and common issues',
        category: 'Help',
        icon: Icons.help_outline_rounded,
        keywords: [
          'help',
          'problem',
          'issue',
          'offline',
          'internet',
          'github',
          'update failed',
          'backup',
          'import',
          'notification',
          'notice',
          'sensor',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
        title: 'Reminders',
        subtitle:
            'Daily, inactivity, weekly, and monthly notification reminders',
        category: 'Reminders',
        icon: Icons.notifications_active_outlined,
        keywords: [
          'reminders',
          'notifications',
          'daily',
          'weekly',
          'monthly',
          'inactivity',
          'alerts',
          'log',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _getRemindersStatus(),
      ),
      item(
        title: 'Daily Reminder',
        subtitle: 'Toggle daily logging reminder alerts',
        category: 'Reminders',
        icon: Icons.alarm_rounded,
        keywords: ['daily', 'reminder', 'alarm', 'notification', 'schedule'],
        kind: 'switch',
        boolValue: _dailyReminderEnabled,
        onBoolChanged: (bool value) async {
          update(() => _dailyReminderEnabled = value);
          await _prefs?.setBool('reminder_daily_enabled', value);
          await _syncReminder('daily');
        },
        status: null,
      ),
      item(
        title: 'Inactivity Reminder',
        subtitle: 'Toggle inactivity-based timestamp reminders',
        category: 'Reminders',
        icon: Icons.timer_off_outlined,
        keywords: ['inactivity', 'inactive', 'timer', 'alert', 'reminders'],
        kind: 'switch',
        boolValue: _inactivityReminderEnabled,
        onBoolChanged: (bool value) async {
          update(() => _inactivityReminderEnabled = value);
          await _prefs?.setBool('reminder_inactivity_enabled', value);
          await _syncReminder('inactivity');
        },
        status: null,
      ),
      item(
        title: 'Weekly Reminder',
        subtitle: 'Toggle weekly notification alerts',
        category: 'Reminders',
        icon: Icons.calendar_view_week_rounded,
        keywords: ['weekly', 'days', 'sunday', 'monday', 'reminders'],
        kind: 'switch',
        boolValue: _weeklyReminderEnabled,
        onBoolChanged: (bool value) async {
          update(() => _weeklyReminderEnabled = value);
          await _prefs?.setBool('reminder_weekly_enabled', value);
          await _syncReminder('weekly');
        },
        status: null,
      ),
      item(
        title: 'Time Reflection & Mindfulness',
        subtitle:
            'Full-screen hourly mindfulness prompts and time awareness alerts',
        category: 'Time Reflection',
        icon: Icons.self_improvement_rounded,
        keywords: [
          'reflection',
          'mindfulness',
          'hourly',
          'time',
          'breath',
          'chime',
          'alarm',
          'alert',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _reflectionReminderEnabled
            ? 'Active · Every ${_reflectionReminderIntervalMins == 60 ? '1 Hour' : '$_reflectionReminderIntervalMins Mins'}'
            : 'Disabled',
      ),
      item(
        title: 'Monthly Reminder',
        subtitle: 'Toggle monthly notification alerts',
        category: 'Reminders',
        icon: Icons.calendar_month_rounded,
        keywords: ['monthly', 'month', 'days', 'reminders'],
        kind: 'switch',
        boolValue: _monthlyReminderEnabled,
        onBoolChanged: (bool value) async {
          update(() => _monthlyReminderEnabled = value);
          await _prefs?.setBool('reminder_monthly_enabled', value);
          await _syncReminder('monthly');
        },
        status: null,
      ),
      item(
        title: 'Language',
        subtitle: 'Choose from 7 built-in offline languages',
        category: 'Advanced',
        icon: Icons.language_rounded,
        keywords: [
          'language',
          'languages',
          'translate',
          'localization',
          'french',
          'spanish',
          'hindi',
          'german',
          'japanese',
          'russian',
        ],
        kind: 'nav',
        status: '7 Languages',
      ),
      item(
        title: 'Sleep Protection & Active Hours',
        subtitle: 'Mute mindful reminders overnight to protect sleep',
        category: 'Time Reflection',
        icon: Icons.bedtime_rounded,
        keywords: ['sleep', 'active', 'quiet', 'hours', 'night', 'schedule'],
        kind: 'nav',
        status:
            '${_prefs?.getInt('reminder_reflection_start_hour') ?? 9}:00 – ${_prefs?.getInt('reminder_reflection_end_hour') ?? 22}:00',
      ),
    ];
  }

  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
  >
  get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final all = _allSettingsOptions();

    return all.where((item) {
      final title = item.title.toLowerCase();
      final titleLoc = item.title.localized(context).toLowerCase();
      final subtitle = item.subtitle.toLowerCase();
      final subtitleLoc = item.subtitle.localized(context).toLowerCase();

      if (title.contains(query) || titleLoc.contains(query)) return true;
      if (subtitle.contains(query) || subtitleLoc.contains(query)) return true;
      return item.keywords.any((k) => k.contains(query));
    }).toList();
  }

  List<HelpGuideItem> get _helpGuideSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    return allHelpAndGuideCatalog.where((item) {
      final title = item.title.toLowerCase();
      final titleLoc = item.title.localized(context).toLowerCase();
      final content = item.content.toLowerCase();
      final contentLoc = item.content.localized(context).toLowerCase();

      if (title.contains(query) || titleLoc.contains(query)) return true;
      if (content.contains(query) || contentLoc.contains(query)) return true;
      return item.keywords.any((k) => k.contains(query));
    }).toList();
  }

  List<Widget> _buildSearchSlivers(Palette p) {
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: SliverStickyHeaderDelegate(
          height: 64,
          child: Container(
            color: p.surface.withValues(
              alpha:
                  !reduceMotion &&
                      enableTranslucency &&
                      AdaptiveEngine().supportsBlur
                  ? 0.65
                  : 1.0,
            ),
            padding: const EdgeInsets.only(bottom: spacing8),
            child: SettingsSearchBox(
              p: p,
              controller: _settingsSearchController,
              focusNode: _settingsSearchFocusNode,
              onChanged: (value) {
                update(() => _settingsQuery = value);
                if (_activeController.hasClients) {
                  _activeController.jumpTo(0.0);
                }
              },
              onClear: () {
                update(() {
                  _settingsQuery = '';
                  _settingsSearchController.clear();
                });
                if (_activeController.hasClients) {
                  _activeController.jumpTo(0.0);
                }
              },
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: spacing8),
          if (_settingsQuery.trim().isEmpty) ...[
            if (_recentSearches.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: HIGEmptyState(
                  p: p,
                  icon: Icons.search_rounded,
                  title: 'Search Settings'.localized(context),
                  message:
                      'Type to find themes, notifications, security, diagnostic logs, and capture mode configurations.'
                          .localized(context),
                  compact: true,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT SEARCHES',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('recent_settings_searches');
                        update(() => _recentSearches = []);
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SettingsGroup(
                p: p,
                insetDividers: true,
                children: [
                  for (final term in _recentSearches)
                    ...() {
                      final matched = _allSettingsOptions()
                          .where(
                            (item) =>
                                item.title == term ||
                                item.title.localized(context) == term,
                          )
                          .toList();
                      if (matched.isNotEmpty) {
                        final result = matched.first;
                        if (result.kind == 'switch') {
                          return [
                            SettingsSwitchRow(
                              p: p,
                              icon: result.icon,
                              title: result.title,
                              subtitle: result.subtitle,
                              value: result.boolValue!,
                              onChanged: (val) {
                                _saveRecentSearch(result.title);
                                result.onBoolChanged!(val);
                              },
                              color: result.title == 'Confirm Delete'
                                  ? p.red
                                  : (result.title == 'Rm -rf Cache'
                                        ? p.orange
                                        : p.accent),
                            ),
                          ];
                        } else {
                          return [
                            SettingsRow(
                              p: p,
                              icon: result.icon,
                              title: result.title,
                              subtitle: result.subtitle,
                              status: result.status,
                              color:
                                  (result.title == 'Reset All Data' ||
                                      result.title == 'Factory Reset')
                                  ? p.red
                                  : p.accent,
                              onTap: () {
                                _saveRecentSearch(result.title);
                                if (result.title == 'Personal Profile') {
                                  PersonalizationSetupDialog.show(
                                    context,
                                    p: p,
                                    onSaved: () => update(() {}),
                                  );
                                  return;
                                }
                                if (result.title == 'App Version') {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel: 'Changelog',
                                    pageBuilder: (context, _, _) =>
                                        ChangelogDialog(p: widget.p),
                                  );
                                  return;
                                }
                                if (result.title == 'Release Date') {
                                  _openCategory('Update Center');
                                  return;
                                }
                                if (result.title == 'Developer & Creator') {
                                  openExternalLinkSafely(
                                    context,
                                    p: p,
                                    url: 'https://github.com/dheeraz101',
                                  );
                                  return;
                                }
                                if (result.title == 'Open Source Codebase') {
                                  openExternalLinkSafely(
                                    context,
                                    p: p,
                                    url:
                                        'https://github.com/dheeraz101/Notekar-Android',
                                  );
                                  return;
                                }
                                if (result.title == 'Security & Integrity') {
                                  showSecurityDetailsSheet(
                                    context: context,
                                    p: p,
                                    reduceMotion: reduceMotion,
                                    enableTranslucency: enableTranslucency,
                                  );
                                  return;
                                }
                                if (result.title == 'Privacy & Local Storage') {
                                  showPrivacyDetailsSheet(
                                    context: context,
                                    p: p,
                                    reduceMotion: reduceMotion,
                                    enableTranslucency: enableTranslucency,
                                  );
                                  return;
                                }
                                if (result.title == 'App Philosophy') {
                                  _openCategory(
                                    'App Philosophy',
                                    parent: 'About',
                                  );
                                  return;
                                }
                                if (result.title == 'Upcoming Features') {
                                  _openCategory(
                                    'Upcoming Features',
                                    parent: 'About',
                                  );
                                  return;
                                }
                                if (result.title == 'Network Monitor') {
                                  _openCategory('Network Monitor');
                                  return;
                                }
                                if (result.title == 'Reset All Data') {
                                  unawaited(_confirmResetAll(p));
                                  return;
                                }
                                if (result.title == 'Factory Reset') {
                                  unawaited(_confirmFactoryReset(p));
                                  return;
                                }
                                if (result.title == 'Reset Settings Only') {
                                  unawaited(_confirmResetSettings());
                                  return;
                                }
                                if (result.title == 'Recently Deleted') {
                                  if (widget.onOpenTrash != null) {
                                    widget.onOpenTrash!();
                                  }
                                  return;
                                }
                                if (result.title == 'Official Bulletins') {
                                  _openCategory(
                                    'Official Bulletins',
                                    parent: 'Updates & Notices',
                                  );
                                  return;
                                }
                                if (result.title == 'Targets & Goals') {
                                  _openCategory('Targets & Goals');
                                  return;
                                }
                                _openCategory(result.category);
                              },
                            ),
                          ];
                        }
                      }
                      // Fallback to text query history item
                      return [
                        SettingsRow(
                          p: p,
                          icon: Icons.history_rounded,
                          title: term,
                          color: p.text3,
                          onTap: () {
                            _settingsSearchController.text = term;
                            update(() => _settingsQuery = term);
                            _saveRecentSearch(term);
                          },
                        ),
                      ];
                    }(),
                ],
              ),
            ],
          ] else if (_settingsQuery.trim().isNotEmpty) ...[
            if (_settingsSearchResults.isNotEmpty)
              SettingsGroup(
                p: p,
                title: _helpGuideSearchResults.isNotEmpty ? 'Settings' : null,
                insetDividers: true,
                children: [
                  for (final result in _settingsSearchResults)
                    if (result.kind == 'switch')
                      SettingsSwitchRow(
                        p: p,
                        icon: result.icon,
                        title: result.title,
                        subtitle: result.subtitle,
                        value: result.boolValue!,
                        onChanged: (val) {
                          _saveRecentSearch(result.title);
                          result.onBoolChanged!(val);
                        },
                        color: result.title == 'Confirm Delete'
                            ? p.red
                            : (result.title == 'Rm -rf Cache'
                                  ? p.orange
                                  : p.accent),
                      )
                    else
                      SettingsRow(
                        p: p,
                        icon: result.icon,
                        title: result.title,
                        subtitle: result.subtitle,
                        status: result.status,
                        highlight: _settingsQuery,
                        color:
                            result.title == 'Reset All Data' ||
                                result.title == 'Factory Reset'
                            ? p.red
                            : p.accent,
                        onTap: () {
                          _saveRecentSearch(result.title);
                          if (result.title == 'Personal Profile') {
                            PersonalizationSetupDialog.show(
                              context,
                              p: p,
                              onSaved: () => update(() {}),
                            );
                            return;
                          }
                          if (result.title == 'App Version') {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Changelog',
                              pageBuilder: (context, _, _) =>
                                  ChangelogDialog(p: widget.p),
                            );
                            return;
                          }
                          if (result.title == 'Release Date') {
                            _openCategory('Update Center');
                            return;
                          }
                          if (result.title == 'Developer & Creator') {
                            openExternalLinkSafely(
                              context,
                              p: p,
                              url: 'https://github.com/dheeraz101',
                            );
                            return;
                          }
                          if (result.title == 'Open Source Codebase') {
                            openExternalLinkSafely(
                              context,
                              p: p,
                              url:
                                  'https://github.com/dheeraz101/Notekar-Android',
                            );
                            return;
                          }
                          if (result.title == 'Security & Integrity') {
                            showSecurityDetailsSheet(
                              context: context,
                              p: p,
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                            );
                            return;
                          }
                          if (result.title == 'Privacy & Local Storage') {
                            showPrivacyDetailsSheet(
                              context: context,
                              p: p,
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                            );
                            return;
                          }
                          if (result.title == 'Network Monitor') {
                            _openCategory('Network Monitor');
                            return;
                          }
                          if (result.title == 'Reset All Data') {
                            unawaited(_confirmResetAll(p));
                            return;
                          }
                          if (result.title == 'Factory Reset') {
                            unawaited(_confirmFactoryReset(p));
                            return;
                          }
                          if (result.title == 'Reset Settings Only') {
                            unawaited(_confirmResetSettings());
                            return;
                          }
                          if (result.title == 'Recently Deleted') {
                            if (widget.onOpenTrash != null) {
                              widget.onOpenTrash!();
                            }
                            return;
                          }
                          if (result.title == 'Executive Intelligence Hub') {
                            _openCategory('Dashboard');
                            return;
                          }
                          _openCategory(result.category);
                        },
                      ),
                ],
              ),
            if (_helpGuideSearchResults.isNotEmpty) ...[
              if (_settingsSearchResults.isNotEmpty) const SizedBox(height: 16),
              SettingsGroup(
                p: p,
                title: 'Help & Knowledge Base',
                showDividers: true,
                children: [
                  for (final item in _helpGuideSearchResults)
                    if (item.isFaq)
                      HelpRow(p: p, question: item.title, answer: item.content)
                    else
                      GuideRow(
                        p: p,
                        icon: item.icon ?? Icons.help_outline_rounded,
                        title: item.title,
                        text: item.content,
                      ),
                ],
              ),
            ],
            if (_settingsSearchResults.isEmpty &&
                _helpGuideSearchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: HIGEmptyState(
                  p: p,
                  icon: Icons.search_off_rounded,
                  title: 'No Results',
                  message:
                      'No settings, guides, or help articles match "${_settingsQuery.trim()}". Try different keywords or check your spelling.',
                  compact: true,
                ),
              ),
          ],
          const SizedBox(height: spacing48),
        ]),
      ),
    ];
  }
}
