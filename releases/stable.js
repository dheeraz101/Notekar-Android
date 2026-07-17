globalThis.NOTEKAR_META = {
  version: '3.1.0',
  buildDate: '2026-05-25',
  channel: 'stable',
  changelog: [
    {
      version: '3.1.0',
      date: 'May 25, 2026',
      isNew: true,
      items: [
        'Added a first-run quick tip for tap, long press, Single mode, and Two-Way mode.',
        'Added an Offline ready status in Settings.',
        'Improved the empty history screen with clearer guidance.',
        'Improved accessibility labels for beta updates and default mode controls.'
      ]
    },
    {
      version: '3.0.6',
      date: 'May 25, 2026',
      items: [
        'Added a dedicated What’s New view in Settings.',
        'Exports now include app version, update channel, and export time.',
        'History deletes now ask for confirmation before removing a moment.',
        'Diagnostics can now reset the app cache for easier troubleshooting.',
        'Added a default mode setting for Single or Two-Way startup.'
      ]
    },
    {
      version: '3.0.5',
      date: 'May 25, 2026',
      items: [
        'Update prompts now show which version you have and which version you are installing.',
        'The install confirmation is clearer before you move to a newer NoteKar build.'
      ]
    },
    {
      version: '3.0.4',
      date: 'May 25, 2026',
      items: [
        'Update installs now show progress immediately, so switching channels feels clear and intentional.',
        'The reload button appears only after NoteKar is ready to open the selected version.'
      ]
    },
    {
      version: '3.0.3',
      date: 'May 25, 2026',
      items: [
        'Added current version and last-checked details to Updates.',
        'Added a Beta Updates option for early access to upcoming improvements.',
        'Added a friendly update-available prompt before installing.',
        "Added a What's New view after updating.",
        'Added offline and back-online notices.',
        'Improved export filenames with the current date.',
        'Added a hidden diagnostics view from the version number.'
      ]
    },
    {
      version: '3.0.2',
      date: 'May 25, 2026',
      items: [
        'Install updates now show the same smooth animated progress as update checks.',
        'After an update installs, NoteKar now shows a clear reload message before opening the latest version.',
        'Reloading after an update now fetches the freshest app files instead of showing older cached screens.',
        'Changelog notes are easier to maintain and stay in sync with app releases.',
        'Release notes now focus on visible improvements and helpful new app behavior.'
      ]
    },
    {
      version: '3.0.1',
      date: 'May 25, 2026',
      items: [
        'Added a polished animated update checker with a cleaner refresh icon.',
        'Update checks now pause briefly so the result feels clear instead of instant.',
        'Improved changelog readability on mobile and desktop screens.',
        'Added a New badge to highlight the latest release.'
      ]
    },
    {
      version: '3.00',
      date: 'May 25, 2026',
      items: [
        'Added a two-way time calculator for IN/OUT history entries.',
        'Added manual update checks with a separate install step.',
        'Added a changelog popup for release notes and feature history.',
        'Improved swipe-down closing for popups on mobile.'
      ]
    },
    {
      version: '2.00',
      date: 'May 24, 2026',
      items: [
        'Refined the app install experience and home screen icons.',
        'Added settings for themes, exports, stats, reset, and tap delay.',
        'Added note capture with long press and app shortcuts.'
      ]
    },
    {
      version: '1.00',
      date: 'Initial build',
      items: [
        'Launched instant timestamp logging.',
        'Added single mode and two-way IN/OUT mode.',
        'Added private offline history storage.'
      ]
    }
  ]
};

globalThis.NOTEKAR_VERSION = globalThis.NOTEKAR_META.version;
globalThis.NOTEKAR_CHANGELOG = globalThis.NOTEKAR_META.changelog;
globalThis.NOTEKAR_NOTIFICATION_FEED = 'https://raw.githubusercontent.com/dheeraz101/NotekarN/refs/heads/main/notification.json';
