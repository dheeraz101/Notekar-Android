import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpGuideItem {
  final String title;
  final String content;
  final IconData? icon;
  final bool isFaq;
  final List<String> keywords;

  const HelpGuideItem({
    required this.title,
    required this.content,
    this.icon,
    required this.isFaq,
    this.keywords = const [],
  });
}

const List<HelpGuideItem> allGuideItems = [
  HelpGuideItem(
    icon: Icons.touch_app_rounded,
    title: 'Save a Moment',
    content: 'Tap the home screen once to save the current time.',
    isFaq: false,
    keywords: ['tap', 'save', 'log', 'moment', 'time', 'home'],
  ),
  HelpGuideItem(
    icon: Icons.compare_arrows_rounded,
    title: 'Two-Way Mode',
    content:
        'First tap saves In. The next tap saves Out and completes the pair.',
    isFaq: false,
    keywords: ['two-way', 'in', 'out', 'session', 'interval', 'pair'],
  ),
  HelpGuideItem(
    icon: Icons.radio_button_checked_rounded,
    title: 'Single Mode',
    content: 'Every tap saves one standalone moment.',
    isFaq: false,
    keywords: ['single', 'moment', 'standalone', 'tap'],
  ),
  HelpGuideItem(
    icon: Icons.history_toggle_off_rounded,
    title: 'Startup Mode & Last Used',
    content:
        'Choose whether NoteKar launches in Single mode, Two-Way mode, or Last Used. When set to Last Used, the app automatically remembers and restores the exact capture mode you were using before closing.',
    isFaq: false,
    keywords: [
      'startup',
      'last used',
      'startup mode',
      'launch mode',
      'remember mode',
      'resume',
      'restore',
      'default mode',
      'single',
      'two-way',
      'capture',
    ],
  ),
  HelpGuideItem(
    icon: Icons.note_add_rounded,
    title: 'Add a Note',
    content: 'Touch and hold the home screen to write a note before saving.',
    isFaq: false,
    keywords: ['note', 'long press', 'touch and hold', 'write'],
  ),
  HelpGuideItem(
    icon: Icons.category_rounded,
    title: 'Modes & Categories',
    content:
        'Select an active mode like Work or Deep Focus from the home screen pills carousel to automatically tag all subsequent moments and sessions.',
    isFaq: false,
    keywords: [
      'modes',
      'categories',
      'pills',
      'carousel',
      'tag',
      'work',
      'focus',
    ],
  ),
  HelpGuideItem(
    icon: Icons.touch_app_rounded,
    title: 'Ergonomic Tap Zone',
    content:
        'The tap logging zone is vertically centered on the clock band with full-width reach, eliminating accidental taps on status bars and navigation gestures.',
    isFaq: false,
    keywords: ['tap zone', 'ergonomic', 'reach', 'safety', 'gesture'],
  ),
  HelpGuideItem(
    icon: Icons.widgets_rounded,
    title: 'Android Home Screen Widgets',
    content:
        'Place NoteKar Quick Log, Sobriety Companion, and Life Audit widgets on your launcher for instant logging and live statistics without opening the app.',
    isFaq: false,
    keywords: [
      'widgets',
      'home screen',
      'launcher',
      'quick log',
      'sobriety',
      'life audit',
    ],
  ),
  HelpGuideItem(
    icon: Icons.auto_stories_rounded,
    title: 'Life Ledger Timeline',
    content:
        'Open History to explore connected session cards pairing Two-Way IN and OUT intervals with duration badges. Filter seamlessly across All, Sessions, Singles, or With Notes.',
    isFaq: false,
    keywords: ['timeline', 'ledger', 'history', 'sessions', 'filter'],
  ),
  HelpGuideItem(
    icon: Icons.stop_circle_rounded,
    title: '1-Tap Live Session End',
    content:
        'Active ongoing sessions in History feature a red "End" button right on the card. Tap it anytime to seal the session at the current moment with zero friction.',
    isFaq: false,
    keywords: ['end', 'live', 'session', 'stop', 'close'],
  ),
  HelpGuideItem(
    icon: Icons.history_rounded,
    title: 'Review History',
    content:
        'Open History to review moments, use Select Date for a calendar day, or filter by Today and This Week.',
    isFaq: false,
    keywords: ['history', 'calendar', 'review', 'filter', 'today', 'week'],
  ),
  HelpGuideItem(
    icon: Icons.search_rounded,
    title: 'Search Notes',
    content:
        'Open Settings, then Logging, Moments, Search Notes to find note text by words, date, or time.',
    isFaq: false,
    keywords: ['search', 'notes', 'find', 'filter'],
  ),
  HelpGuideItem(
    icon: Icons.timer_rounded,
    title: 'Time Between Moments',
    content:
        'Select one moment, then another, to calculate the time between them.',
    isFaq: false,
    keywords: ['time between', 'calculate', 'duration', 'diff'],
  ),
  HelpGuideItem(
    icon: Icons.subject_rounded,
    title: 'Manage Moment Notes',
    content:
        'Touch and hold any history moment to add, read, edit, or delete its note.',
    isFaq: false,
    keywords: ['edit note', 'manage note', 'long press', 'moment'],
  ),
  HelpGuideItem(
    icon: Icons.lock_rounded,
    title: 'App Lock & Custom PIN',
    content:
        'Configure App Lock to use either native biometrics (System Lock) or a secure local passcode (In-App PIN). Features rate-limiting lockout protection.',
    isFaq: false,
    keywords: ['lock', 'pin', 'biometric', 'security', 'passcode'],
  ),
  HelpGuideItem(
    icon: Icons.auto_awesome_motion_rounded,
    title: 'Minimal Moment Options',
    content:
        'Enable in Settings > Logging > Moments to use a fast, icon-only row for editing and deleting.',
    isFaq: false,
    keywords: ['minimal', 'options', 'actions', 'fast'],
  ),
  HelpGuideItem(
    icon: Icons.auto_awesome_rounded,
    title: 'Adaptive Engine',
    content:
        'Notekar automatically tunes visual effects to your CPU, RAM, and SDK. Check stats in Advanced > Device Health.',
    isFaq: false,
    keywords: ['adaptive', 'engine', 'performance', 'cpu', 'ram', 'hardware'],
  ),
  HelpGuideItem(
    icon: Icons.delete_outline_rounded,
    title: 'Restore Deleted Moments',
    content:
        'Open Trash Bin in History or Settings > Moments to view, restore, or permanently remove deleted moments.',
    isFaq: false,
    keywords: ['restore', 'trash', 'delete', 'bin', 'recover'],
  ),
  HelpGuideItem(
    icon: Icons.backup_rounded,
    title: 'Back Up Data',
    content:
        'Export a JSON backup before resetting, changing phones, or testing a new build.',
    isFaq: false,
    keywords: ['backup', 'export', 'json', 'data', 'restore'],
  ),
  HelpGuideItem(
    icon: Icons.notifications_active_outlined,
    title: 'Logging Reminders',
    content:
        'Configure daily, weekly, monthly, or inactivity-based notifications under Settings > Logging > Reminders. Custom messages let you personalize alerts.',
    isFaq: false,
    keywords: ['reminders', 'notifications', 'alarm', 'alerts'],
  ),
  HelpGuideItem(
    icon: Icons.dashboard_customize_rounded,
    title: 'Executive Intelligence Hub',
    content:
        'Open Settings > Logging > Dashboard to explore your Daily Rhythm bar chart with bottom-aligned bars, 90-day activity intensity grid, circadian time-of-day breakdowns, and instant time-scope filters (Today, Week, Month, All).',
    isFaq: false,
    keywords: [
      'dashboard',
      'intelligence',
      'charts',
      'analytics',
      'circadian',
      'rhythm',
      'grid',
    ],
  ),
  HelpGuideItem(
    icon: Icons.pinch_rounded,
    title: 'Pinch-to-Density Sensory Zoom',
    content:
        'Pinch with two fingers anywhere on the History timeline or toggle under Settings > Personalization > History to fluidly scale between Compact (information dense) and Comfortable (spacious cards).',
    isFaq: false,
    keywords: ['pinch', 'density', 'zoom', 'compact', 'comfortable', 'gesture'],
  ),
  HelpGuideItem(
    icon: Icons.volume_up_rounded,
    title: 'Acoustic Glass Mechanics & Haptics',
    content:
        'Every interaction carries physical weight: single taps evoke crisp mechanical tocks, switching clock faces produces a precision sliding resistance, and saves chime like polished acoustic crystal.',
    isFaq: false,
    keywords: [
      'haptics',
      'sound',
      'audio',
      'acoustic',
      'tock',
      'chime',
      'vibration',
    ],
  ),
  HelpGuideItem(
    icon: Icons.swipe_rounded,
    title: 'Swipe-to-Undo Dynamic Island',
    content:
        'Accidentally delete a moment? Swiping to dismiss reveals a solid red bed beneath the card with exact corner geometry, followed by a floating Dynamic Island pill with a tactile Undo button and countdown ring.',
    isFaq: false,
    keywords: ['swipe', 'undo', 'dynamic island', 'delete', 'restore'],
  ),
  HelpGuideItem(
    icon: Icons.campaign_rounded,
    title: 'Official Bulletins (Zero Telemetry)',
    content:
        'Critical security alerts, version bulletins, and release insights delivered directly from static GitHub feeds without sending a single byte of user telemetry or tracking.',
    isFaq: false,
    keywords: [
      'bulletins',
      'notices',
      'announcements',
      'github',
      'zero telemetry',
    ],
  ),
  HelpGuideItem(
    icon: Icons.widgets_rounded,
    title: 'Home Screen Widget',
    content:
        'Add the NoteKar widget to your launcher. Tap IN, OUT, or TAP to log instantly in the background with real-time widget updates, or tap NOTE to open a native quick-log overlay.',
    isFaq: false,
    keywords: ['widget', 'launcher', 'quick log', 'home screen'],
  ),
  HelpGuideItem(
    icon: Icons.screenshot_rounded,
    title: 'Hide Content in Recents',
    content:
        'Turn on Hide App Content in Recents under Settings > Privacy & Security to cover app screens and block screenshots when minimizing the app.',
    isFaq: false,
    keywords: ['screenshot', 'recents', 'privacy', 'hide', 'app switcher'],
  ),
  HelpGuideItem(
    icon: Icons.notification_important_rounded,
    title: 'Persistent Control',
    content:
        'Enable in Settings > Logging to show a low-priority, sticky control notification in the system drawer for instant checking IN/OUT from the lock screen.',
    isFaq: false,
    keywords: ['persistent', 'notification', 'drawer', 'lock screen'],
  ),
  HelpGuideItem(
    icon: Icons.pin_outlined,
    title: 'Sequential Single Numbering (00–99)',
    content:
        'Enable "Use Numbers in Single" under Settings > Logging > Moments to show clean 2-digit sequential counters (00 to 99) on standalone moments. Enable "Reset Daily" to automatically restart from 00 every midnight.',
    isFaq: false,
    keywords: ['sequential', 'numbering', 'counter', '00-99', 'single'],
  ),
  HelpGuideItem(
    icon: Icons.touch_app_outlined,
    title: 'Count on Save Pulse',
    content:
        'Turn on "Enable Count on Save" in Settings > Logging > Moments to display your updated 2-digit sequential count directly inside the glowing ripple pulse on the home screen when tapping.',
    isFaq: false,
    keywords: ['count on save', 'pulse', 'ripple', 'animation'],
  ),
  HelpGuideItem(
    icon: Icons.apps_rounded,
    title: '8 Luxury App Icon Editions',
    content:
        'Personalize your home screen with 8 handcrafted launcher styles under Settings > Personalization > App Icons: Aurora (Default), Midnight (Onyx), Sapphire (Ocean), Imperial (Gold), Emerald (Forest), Sunset (Coral), Crimson (Velvet), and Amethyst (Nebula).',
    isFaq: false,
    keywords: ['app icon', 'launcher icon', 'editions', 'personalization'],
  ),
  HelpGuideItem(
    icon: Icons.spa_rounded,
    title: 'Sobriety Tracker & Milestone Cards',
    content:
        'Track your recovery journey with live streak counters, unlock 10 milestone badges with celebrations, and generate high-res shareable PNG cards under Settings > Personalization > Sobriety Tracker.',
    isFaq: false,
    keywords: [
      'sobriety',
      'tracker',
      'milestones',
      'streak',
      'clean',
      'recovery',
    ],
  ),
  HelpGuideItem(
    icon: Icons.calendar_month_rounded,
    title: 'Visual Calendar & Centered Date Baseline',
    content:
        'Tap the calendar chip in History to pick any past date. Dates with recorded moments feature subtle event dots anchored beneath numerals with zero vertical baseline shift.',
    isFaq: false,
    keywords: ['calendar', 'date picker', 'history', 'event dots'],
  ),
  HelpGuideItem(
    icon: Icons.developer_mode_rounded,
    title: 'Developer Options & Telemetry',
    content:
        'Inspect internal diagnostics, device hardware health metrics, real-time network request audits, and GitHub commits cache under Settings > Advanced > Developer Options.',
    isFaq: false,
    keywords: ['developer', 'diagnostics', 'telemetry', 'hardware', 'health'],
  ),
  HelpGuideItem(
    icon: Icons.self_improvement_rounded,
    title: 'Hourly Time Reflection & Mindfulness',
    content:
        'Enable hourly mindful breathing overlays with soothing chimes in Settings > Time Reflection. Set active daytime schedules to automatically mute alerts during sleep.',
    isFaq: false,
    keywords: [
      'mindfulness',
      'reflection',
      'breathing',
      'chime',
      'sleep schedule',
    ],
  ),
  HelpGuideItem(
    icon: Icons.language_rounded,
    title: '100% Offline Multilingual Localization',
    content:
        'Switch between English, French, Spanish, Hindi, German, Japanese, and Russian instantly in Settings > Advanced > Language with zero data usage or downloads.',
    isFaq: false,
    keywords: [
      'language',
      'offline',
      'translation',
      'locale',
      'hindi',
      'spanish',
      'french',
      'german',
      'japanese',
      'russian',
    ],
  ),
  HelpGuideItem(
    icon: Icons.battery_charging_full_rounded,
    title: 'Battery & Doze Optimization',
    content:
        'NoteKar uses non-waking alarms for routine reminders, staying 100% compliant with Android Doze mode while eliminating unnecessary battery drain.',
    isFaq: false,
    keywords: ['battery', 'doze', 'optimization', 'power', 'efficiency'],
  ),
  HelpGuideItem(
    icon: Icons.vpn_key_rounded,
    title: 'The Architect\'s Cipher (Enigma)',
    content:
        'Encrypted hex stream detected: "23 67 6f 64 6d 6f 64 65". Decipher the hex ASCII sequence into plain text, then inscribe and save it inside any moment\'s note to awaken dormant powers.',
    isFaq: false,
    keywords: ['cipher', 'easter egg', 'god mode', 'enigma', 'secret'],
  ),
  HelpGuideItem(
    icon: CupertinoIcons.link,
    title: 'Deep Linking & URL Schemes',
    content:
        'Trigger instant logs, Two-Way intervals, prefill notes, or jump to specific screens using custom URL schemes (e.g. notekar://log?type=single&note=Coffee, notekar://in, notekar://out, notekar://open?page=history). Perfect for NFC tags, browser bookmarks, and launchers.',
    isFaq: false,
    keywords: ['deep link', 'url scheme', 'automation', 'nfc', 'notekar://'],
  ),
  HelpGuideItem(
    icon: CupertinoIcons.selection_pin_in_out,
    title: 'Global Text Selection ("Log in NoteKar")',
    content:
        'Highlight text anywhere across Android in Chrome, WhatsApp, Kindle, Books, or Twitter and choose "Log in NoteKar" from the context menu to capture notes offline with an instant toast.',
    isFaq: false,
    keywords: [
      'text selection',
      'context menu',
      'log in notekar',
      'chrome',
      'whatsapp',
    ],
  ),
  HelpGuideItem(
    icon: Icons.article_rounded,
    title: 'Obsidian & Logseq Markdown Journal',
    content:
        'Export pristine, date-grouped Markdown tables formatted with timestamps, session durations, and telemetry statistics under Settings > Integrations & Automation > Export Markdown Journal.',
    isFaq: false,
    keywords: ['obsidian', 'logseq', 'markdown', 'journal', 'export'],
  ),
  HelpGuideItem(
    icon: CupertinoIcons.calendar,
    title: 'Calendar Sessions (.ics) Export',
    content:
        'Export your tracked Two-Way IN/OUT intervals as RFC 5545 calendar events into an .ics file for 1-tap import into Google Calendar, Samsung Calendar, Outlook, or Proton.',
    isFaq: false,
    keywords: [
      'calendar export',
      'ics',
      'google calendar',
      'outlook',
      'sessions',
    ],
  ),
  HelpGuideItem(
    icon: CupertinoIcons.radiowaves_right,
    title: 'Tasker & Automation Broadcasts',
    content:
        'Trigger offline background moment logging via the system broadcast intent app.notekar.notekar.ACTION_LOG_MOMENT with extras type (single, in, out, note) and note.',
    isFaq: false,
    keywords: ['tasker', 'macrodroid', 'broadcast intent', 'automation'],
  ),
  HelpGuideItem(
    icon: Icons.auto_delete_outlined,
    title: 'Rm -rf Cache (Update Clean)',
    content:
        'Enable "Rm -rf Cache" in Updates & Notices to automatically purge update APK installer files and cache upon installation, keeping app storage lightweight.',
    isFaq: false,
    keywords: ['cache', 'rm -rf', 'clean', 'storage', 'apk purge'],
  ),
  HelpGuideItem(
    icon: CupertinoIcons.plus_app,
    title: 'Plus Notes (Unrestricted Journaling)',
    content:
        'When a quick micro-note isn\'t enough, tap "Plus" in the note editor to write expansive journals, reflections, or meeting logs with an unrestricted character limit.',
    isFaq: false,
    keywords: [
      'plus note',
      'journal',
      'long form',
      'character limit',
      'editor',
    ],
  ),
  HelpGuideItem(
    icon: Icons.schedule_rounded,
    title: '12-Hour vs 24-Hour Time Format',
    content:
        'Choose 12-Hour (AM/PM) or 24-Hour (Standard) in Settings > Personalization > Display. In 12-hour mode, the home screen shows clean hours and minutes, while History and Search Notes display explicit AM/PM tags.',
    isFaq: false,
    keywords: ['12-hour', '24-hour', 'time format', 'am pm', 'display'],
  ),
  HelpGuideItem(
    icon: Icons.tag_rounded,
    title: 'Customizable Hashtags',
    content:
        'Long press any quick tag pill in the note editor to customize or replace it with your own personal tags, allowing tailored one-tap categorization for moments.',
    isFaq: false,
    keywords: ['hashtags', 'tags', 'chips', 'custom tags', 'categories'],
  ),
];

const List<HelpGuideItem> allHelpFaqItems = [
  HelpGuideItem(
    title: 'How do Modes & Focus Categories work?',
    content:
        'Tap any category pill on the home screen carousel (e.g. Work, Deep Focus) to tag upcoming moments and sessions. In Settings > Logging > Modes, you can create custom modes, view tracked hours, and explore dedicated category histories.',
    isFaq: true,
    keywords: ['modes', 'focus categories', 'work', 'tag', 'pills'],
  ),
  HelpGuideItem(
    title: 'Why does tapping the very top or bottom of the screen not log?',
    content:
        'NoteKar features an intentional Ergonomic Safety Zone centered around the clock face (+ buffer). This allows full-width one-handed thumb tapping while preventing accidental logs when pulling down notification shades or performing navigation gestures.',
    isFaq: true,
    keywords: [
      'top of screen',
      'bottom of screen',
      'ergonomic',
      'tap zone',
      'accidental tap',
    ],
  ),
  HelpGuideItem(
    title: 'How does Last Used startup mode work?',
    content:
        'When you select Last Used under Settings > Capture > Startup Mode, NoteKar preserves your active logging mode across app closures. If you switch between Single and Two-Way logging, reopening NoteKar will resume immediately in that mode without requiring manual adjustment.',
    isFaq: true,
    keywords: [
      'last used',
      'startup mode',
      'launch',
      'remember',
      'resume',
      'mode switch',
      'preserve mode',
    ],
  ),
  HelpGuideItem(
    title: 'What Android Home Screen Widgets are supported?',
    content:
        'NoteKar provides 3 dedicated widgets: Quick Log (1-tap IN/OUT/Moment capture & mode status), Sobriety Companion (clean streak & milestone progress), and Life Audit (daily waking focus ratio). Add them by long-pressing your home screen launcher and selecting Widgets > NoteKar.',
    isFaq: true,
    keywords: ['widgets', 'home screen', 'quick log', 'sobriety', 'life audit'],
  ),
  HelpGuideItem(
    title: 'How does Pinch-to-Density work in History?',
    content:
        'Simply pinch in or out with two fingers on the History timeline. The cards scale fluidly between compact information-dense tiles and comfortable expanded views with live tactile feedback.',
    isFaq: true,
    keywords: ['pinch', 'density', 'zoom', 'history', 'compact', 'comfortable'],
  ),
  HelpGuideItem(
    title: 'Where can I read Official Bulletins?',
    content:
        'Open Settings > Updates & Notices > Official Bulletins to view verified release announcements, curated tips, and security advisories fetched securely with zero tracking.',
    isFaq: true,
    keywords: ['bulletins', 'updates', 'notices', 'security advisories'],
  ),
  HelpGuideItem(
    title: 'What happens when I swipe to delete a moment?',
    content:
        'Swiping a moment card glides it smoothly off the screen revealing a solid red bed underneath. A floating Dynamic Island undo prompt instantly appears at the top, letting you restore the card with a single tap before it is sent to Trash.',
    isFaq: true,
    keywords: ['swipe', 'delete', 'undo', 'dynamic island', 'trash'],
  ),
  HelpGuideItem(
    title: 'How does the Life Ledger Timeline work in History?',
    content:
        'History automatically pairs chronological Two-Way IN and OUT moments into connected session cards with elapsed duration calculations and start/finish nodes. Single moments show clean rail nodes with optional 00–99 badges. You can filter by All, Sessions, Singles, or With Notes without any layout overlapping.',
    isFaq: true,
    keywords: ['life ledger', 'timeline', 'history', 'sessions', 'filter'],
  ),
  HelpGuideItem(
    title: 'How do I end an ongoing live session?',
    content:
        'Ongoing sessions in History display a pulsing green LIVE duration pill alongside a red "End" button. Tapping End instantly logs an OUT moment at the current time and closes the session card on the spot.',
    isFaq: true,
    keywords: ['end session', 'live session', 'stop session', 'out'],
  ),
  HelpGuideItem(
    title: 'How do I filter History by specific calendar dates?',
    content:
        'Tap the calendar icon [📅] in the History filter bar to open the visual calendar picker. Days with recorded moments show an event dot anchored beneath the number. Selecting any past date instantly filters your history to that day.',
    isFaq: true,
    keywords: ['calendar', 'filter', 'date picker', 'history date'],
  ),
  HelpGuideItem(
    title: 'How do I interpret the Dashboard Daily Rhythm and Activity Grid?',
    content:
        'The Daily Rhythm bar chart displays your activity volume for each day of the week, anchored cleanly to the bottom baseline. The 90-day Activity Grid uses color intensity gradations to visualize consistency, alongside habit streak counts and time-of-day circadian focus breakdowns.',
    isFaq: true,
    keywords: [
      'dashboard',
      'daily rhythm',
      'activity grid',
      'circadian',
      'streaks',
    ],
  ),
  HelpGuideItem(
    title: 'Can NoteKar communicate with other apps or automators?',
    content:
        'Yes! NoteKar features a complete suite of system bridges: custom URL schemes (notekar://), Android global text selection ("Log in NoteKar"), Android share target for plain text, local Tasker/MacroDroid broadcast intents, Obsidian Markdown journal sync, and Calendar .ics session exports under Settings > Integrations & Automation.',
    isFaq: true,
    keywords: [
      'automators',
      'tasker',
      'shortcuts',
      'url scheme',
      'broadcast',
      'obsidian',
      'calendar',
    ],
  ),
  HelpGuideItem(
    title: 'How do I export tracked sessions to Google Calendar or Outlook?',
    content:
        'Open Settings > Integrations & Automation and tap "Export Sessions to Calendar (.ics)". The exported file can be imported directly into Google Calendar, Samsung Calendar, Outlook, or Proton Calendar.',
    isFaq: true,
    keywords: ['google calendar', 'outlook', 'ics', 'export sessions'],
  ),
  HelpGuideItem(
    title: 'How do I sync NoteKar with Obsidian or Logseq?',
    content:
        'Open Settings > Integrations & Automation and tap "Export Markdown Journal (.md)". The generated file contains structured Markdown tables grouped by date, ready to drop into your second-brain vault.',
    isFaq: true,
    keywords: ['obsidian', 'logseq', 'markdown journal', 'vault', 'sync'],
  ),
  HelpGuideItem(
    title: 'How does Hourly Time Reflection work?',
    content:
        'Time Reflection prompts you with an hourly mindful breathing pause and chime. It only runs during your configured Active Hours and mutes automatically overnight to protect your sleep.',
    isFaq: true,
    keywords: [
      'hourly reflection',
      'mindfulness',
      'breathing',
      'chime',
      'active hours',
    ],
  ),
  HelpGuideItem(
    title: 'Is there a secret sovereign or god mode?',
    content:
        'Legend speaks of an ancient developer cipher: "#" + "g-o-d-m-o-d-e". Inscribe and save "#godmode" as any moment\'s note to awaken exclusive developer themes, the mindful gravity sandbox, and cryptographic pioneer credentials.',
    isFaq: true,
    keywords: ['godmode', 'secret', 'easter egg', 'sandbox', 'cipher'],
  ),
  HelpGuideItem(
    title: 'Does NoteKar support offline languages?',
    content:
        'Yes! NoteKar includes 7 built-in language localizations (English, French, Spanish, Hindi, German, Japanese, and Russian) that work 100% offline without requiring any internet connection or file downloads.',
    isFaq: true,
    keywords: [
      'languages',
      'offline',
      'hindi',
      'spanish',
      'french',
      'german',
      'japanese',
      'russian',
    ],
  ),
  HelpGuideItem(
    title: 'What features are upcoming in NoteKar?',
    content:
        'Upcoming capabilities on the roadmap include Hands-free Voice Notes with 100% offline multi-language speech transcription (English, Hindi, Spanish, French, German, Japanese, Russian), calendar-based day-swipe visual timeline, and adaptive mode-based color accents.',
    isFaq: true,
    keywords: ['roadmap', 'upcoming', 'voice notes', 'features'],
  ),
  HelpGuideItem(
    title: 'Can I restore deleted moments?',
    content:
        'Yes! Deleted moments are moved to Trash Bin. You can restore individual moments or all moments anytime from History or Settings > Moments.',
    isFaq: true,
    keywords: ['restore', 'trash', 'recover', 'deleted moments'],
  ),
  HelpGuideItem(
    title: 'Can I view updates while offline?',
    content:
        'Yes! NoteKar automatically caches the latest commits feed when you check for updates online. If you are offline, you will still see the cached feed, though checking for new updates will show a "No internet" notice.',
    isFaq: true,
    keywords: ['offline updates', 'cache', 'commit feed', 'internet'],
  ),
  HelpGuideItem(
    title: 'What is the Network Monitor?',
    content:
        'NoteKar includes an offline-first Network Monitor that displays a real-time audit log of every internet request made by the app (like update checks, changelogs, and notice checks), including status codes, request sizes, and purpose. No data ever leaves your device.',
    isFaq: true,
    keywords: ['network monitor', 'audit', 'telemetry', 'privacy', 'traffic'],
  ),
  HelpGuideItem(
    title: 'Switching track shows no update',
    content:
        'If you are on a Beta release (which has a higher version code) and switch to the Stable track, Android prevents installing an older version (downgrading). You will see the update option once a newer Stable build is officially released. Alternatively, you can uninstall the Beta version and download the Stable version manually.',
    isFaq: true,
    keywords: ['beta', 'stable', 'downgrade', 'update track'],
  ),
  HelpGuideItem(
    title: 'Update check failed',
    content:
        'First confirm that your phone is connected to the internet. If other websites work, GitHub may be unavailable or limiting requests. Wait a few minutes and try again.',
    isFaq: true,
    keywords: ['update failed', 'github rate limit', 'check for updates'],
  ),
  HelpGuideItem(
    title: 'App Notices are not appearing',
    content:
        'Confirm App Notices are enabled and Android notification permission is allowed. Battery restrictions or background limits may delay checks. Opening NoteKar while online also triggers a notice check.',
    isFaq: true,
    keywords: [
      'notices',
      'app notices',
      'push notifications',
      'background limits',
    ],
  ),
  HelpGuideItem(
    title: 'NoteKar is offline',
    content:
        'Logging, History, notes, settings, and local backups work without internet. Only update checks, external links, and App Notices require a connection.',
    isFaq: true,
    keywords: ['offline', 'internet', 'connection', 'local storage'],
  ),
  HelpGuideItem(
    title: 'Backup import found no new moments',
    content:
        'The backup was read correctly, but its moments already exist on this device. NoteKar skips duplicates instead of adding them again.',
    isFaq: true,
    keywords: ['backup duplicates', 'skip duplicates', 'import backup'],
  ),
  HelpGuideItem(
    title: 'Backup import failed',
    content:
        'Make sure you selected a NoteKar JSON backup that was not renamed, manually edited, or damaged. Try exporting a fresh backup.',
    isFaq: true,
    keywords: ['backup failed', 'corrupted backup', 'invalid json'],
  ),
  HelpGuideItem(
    title: 'Live Icon Motion will not turn on',
    content:
        'Turn off Reduced Motion first. If NoteKar reports that the motion sensor is unavailable, the phone does not provide a usable accelerometer stream or your hardware tier is set to Power Saver.',
    isFaq: true,
    keywords: [
      'live icon motion',
      'accelerometer',
      'gyroscope',
      'reduced motion',
    ],
  ),
  HelpGuideItem(
    title: 'Live Icon Motion looks slow or delayed',
    content:
        'The movement is intentionally smoothed to prevent jitter. Lower-end phones may also reduce animation performance automatically based on CPU and RAM stats.',
    isFaq: true,
    keywords: ['motion delay', 'smooth motion', 'jitter', 'low end phone'],
  ),
  HelpGuideItem(
    title: 'How does App Lock protect NoteKar?',
    content:
        'You can lock NoteKar using either your device\'s native credentials (System Lock) or a custom 4-digit passcode (In-App PIN). If you choose System Lock, removing your device lock screen security will automatically disable App Lock for safety. In-App PIN runs independently and includes rate-limiting lockout protection.',
    isFaq: true,
    keywords: ['app lock', 'system lock', 'pin', 'biometrics', 'fingerprint'],
  ),
  HelpGuideItem(
    title: 'App Lock appears after the notification panel',
    content:
        'If App Lock is set to Immediately, opening Recents or pulling down the notification panel counts as leaving NoteKar. This ensures your moments stay hidden.',
    isFaq: true,
    keywords: [
      'app lock timing',
      'notification shade',
      'recents',
      'immediately',
    ],
  ),
  HelpGuideItem(
    title: 'The app icon did not change immediately',
    content:
        'Some Android launchers cache icons. Return to the home screen, wait briefly, or restart the launcher or phone.',
    isFaq: true,
    keywords: ['icon change', 'launcher cache', 'app icon delayed'],
  ),
  HelpGuideItem(
    title: 'A moment was saved accidentally',
    content:
        'Use Undo immediately after saving, or remove it from History. You can enable Confirm Delete for extra protection.',
    isFaq: true,
    keywords: ['accidentally saved', 'undo', 'mistake', 'delete moment'],
  ),
  HelpGuideItem(
    title: 'My data disappeared after clearing app storage',
    content:
        'NoteKar stores data locally. Clearing Android app storage deletes that local data. Restore it using a backup file if one was exported earlier.',
    isFaq: true,
    keywords: ['cleared data', 'clear storage', 'data loss', 'restore backup'],
  ),
  HelpGuideItem(
    title: 'Will reminders work when the app is closed?',
    content:
        'Yes! NoteKar registers reminders directly with Android\'s system AlarmManager. The OS will launch our background notification receiver and show the alert even if the app is closed or force-killed.',
    isFaq: true,
    keywords: ['alarm manager', 'closed app', 'background reminders'],
  ),
  HelpGuideItem(
    title: 'Why am I not receiving reminders?',
    content:
        'Make sure Android notification permissions are allowed for NoteKar. On some devices, OEM power-saving modes or background execution restrictions may block or delay scheduled alarms. Consider disabling battery optimization for NoteKar.',
    isFaq: true,
    keywords: [
      'reminders not working',
      'battery optimization',
      'notifications missing',
    ],
  ),
  HelpGuideItem(
    title: 'Is NoteKar safe to use?',
    content:
        'Absolutely. NoteKar is open-source and offline-first. To guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via VirusTotal. You can inspect the live scan report under Updates & Notices.',
    isFaq: true,
    keywords: [
      'safe',
      'virustotal',
      'malware',
      'trust',
      'open source',
      'privacy',
    ],
  ),
  HelpGuideItem(
    title: 'How do I add and use the home screen widget?',
    content:
        'Touch and hold an empty space on your phone\'s home screen, select Widgets, and drag NoteKar to your screen. You can log immediately using the quick-action buttons. Tapping the top history stack opens the main app.',
    isFaq: true,
    keywords: ['add widget', 'home screen widget', 'quick log'],
  ),
  HelpGuideItem(
    title: 'Is my Dashboard data uploaded?',
    content:
        'No. All stats, activity heatmaps, anomalies, and correlation graphs are computed completely offline on your device. We do not track or upload your habits or logs.',
    isFaq: true,
    keywords: ['dashboard privacy', 'offline data', 'cloud upload', 'tracking'],
  ),
  HelpGuideItem(
    title: 'How do I block screenshots and screen previews?',
    content:
        'Enable "Hide App Content" under Settings > Privacy & Security. Once enabled, screenshots will be blocked inside NoteKar, and the system app switcher card will appear blank.',
    isFaq: true,
    keywords: [
      'block screenshots',
      'hide app content',
      'FLAG_SECURE',
      'privacy',
    ],
  ),
  HelpGuideItem(
    title: 'How do I log directly from the lock screen?',
    content:
        'Turn on "Persistent Control" in Settings > Logging. A sticky, low-priority control card will appear in your notification drawer with quick actions to log IN, OUT, or write a quick note instantly.',
    isFaq: true,
    keywords: [
      'lock screen logging',
      'persistent control',
      'notification action',
    ],
  ),
  HelpGuideItem(
    title: 'How does Sequential Single Numbering work?',
    content:
        'When "Use Numbers in Single" is enabled, single moments are tagged with 00 to 99 sequence badges. If "Reset Daily" is enabled, the count restarts at 00 every midnight while keeping past days intact.',
    isFaq: true,
    keywords: ['sequential single', 'numbering', '00-99', 'daily reset'],
  ),
  HelpGuideItem(
    title: 'Where are Diagnostics and Network Monitor?',
    content:
        'Advanced tools and telemetry are organized under Settings > Advanced > Developer Options, including real-time hardware health, diagnostics logs, network audits, and cached commit feeds.',
    isFaq: true,
    keywords: ['diagnostics', 'developer options', 'network monitor'],
  ),
  HelpGuideItem(
    title: 'How do I export my Sobriety Milestones?',
    content:
        'Open Settings > Personalization > Sobriety Tracker, tap on any unlocked milestone badge in the milestones gallery, and tap "Export Milestone Card" to share a high-res image directly.',
    isFaq: true,
    keywords: ['export milestone', 'share milestone', 'sobriety card'],
  ),
  HelpGuideItem(
    title: 'What is "Rm -rf Cache" and how does it work?',
    content:
        'Inspired by the Unix clean command, "Rm -rf Cache" automatically deletes downloaded update packages and temporary build artifacts upon installation or when turned on. It prevents installer files from accumulating in device storage without affecting your private notes or logs.',
    isFaq: true,
    keywords: ['rm -rf', 'cache', 'storage clean', 'apk delete'],
  ),
  HelpGuideItem(
    title: 'What is a Plus Note and how does it differ from a standard note?',
    content:
        'Standard notes are lightweight micro-captures (up to 500 characters) designed for rapid logging. Plus Notes let you write long-form journals, memos, and multi-paragraph entries without character restrictions. Tap "Plus" on the left side of any note dialog to open the full editor.',
    isFaq: true,
    keywords: ['plus note', 'micro note', 'character limit', 'journaling'],
  ),
  HelpGuideItem(
    title: 'How does the 12/24-hour time setting affect the app?',
    content:
        'Under Settings > Personalization > Display, you can switch between 12-hour and 24-hour time. In 12-hour mode, the home clock face remains distraction-free without an AM/PM label, while History, Search Notes, and detail dialogs clearly display AM or PM tags.',
    isFaq: true,
    keywords: ['12-hour', '24-hour', 'time format', 'am pm'],
  ),
  HelpGuideItem(
    title: 'Can I customize the hashtag suggestions in the note editor?',
    content:
        'Yes! In the note dialog, long-press any hashtag chip to edit it. You can define your own frequent tags to quickly categorize moments with a single tap.',
    isFaq: true,
    keywords: ['customize hashtags', 'edit hashtags', 'chips', 'quick tags'],
  ),
  HelpGuideItem(
    title: 'How do I set up my personal profile, photo, and birth date?',
    content:
        'Under Settings, tap the Apple ID-style profile card at the top to configure your name, birth date, and avatar (upload a custom photo or choose from minimal curated presets). Your identity is reflected on Sunday Dispatches, Milestone cards, and lifetime horizons while remaining 100% private on your device.',
    isFaq: true,
    keywords: [
      'personal profile',
      'avatar',
      'photo',
      'dob',
      'birth date',
      'identity',
      'profile card',
    ],
  ),
  HelpGuideItem(
    title: 'What is the Memento Mori card in the Executive Dashboard?',
    content:
        'The Memento Mori card visualizes your lived weeks versus remaining horizon, strictly capped at a 100-year ceiling (customizable up to 100). It breaks down your time into deliberate focus, claimed rest, and untracked drift, grounded in Stoic reflection.',
    isFaq: true,
    keywords: [
      'memento mori',
      'life horizon',
      'weeks lived',
      'remaining time',
      '100 years',
      'stoic',
      'executive dashboard',
    ],
  ),
  HelpGuideItem(
    title: 'How do I choose custom glyph icons for my modes and categories?',
    content:
        'Under Settings > Modes & Categories, tap any mode to edit its minimal glyph icon and palette dot. NoteKar provides 18 curated minimal glyphs (e.g. Code, Reading, Fitness, Heart, Meditate, Star) that update seamlessly across your top capsule, history cards, and dashboard.',
    isFaq: true,
    keywords: [
      'mode icons',
      'glyph icons',
      'custom icons',
      'categories',
      'minimal glyphs',
      'capsule icons',
    ],
  ),
];

/// Combined catalog for unified search
final List<HelpGuideItem> allHelpAndGuideCatalog = [
  ...allHelpFaqItems,
  ...allGuideItems,
];
