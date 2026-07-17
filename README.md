# NoteKar - Minimal Timestamp Logger

A tiny, elegant timestamp logger (PWA-ready). Tap to record a moment, long-press to add a note, view history, and adjust a configurable tap delay.

## Features

- Instant tap logging — one tap = one timestamp
- Two modes: Two-way (IN/OUT sessions) and Single (one-shot)
- Optional note on long-press
- Local storage via IndexedDB (Dexie)
- History view with filters (All, Today, This Week, IN, OUT, Single, Notes)
- Configurable tap delay (0s, 5s, 10s, 15s, 20s, 30s, 1m)
- Small, responsive UI inspired by macOS/iOS design
- Progressive Web App support (service worker)

## Files

- `index.html` — Single-file app (HTML, CSS, JS inline)
- `sw.js` — Optional service worker (PWA)

## About

Made with ❤ in India. An initiative of [YABP (Yet Another Boring Project)](https://yabp.netlify.app/).

## Quick start (local)

Open the app directly or serve it locally:

Windows / macOS / Linux (quick local server):

```bash
# Python 3
python -m http.server 8000
# then open http://localhost:8000 in your browser
```

## Usage

- Tap the screen to save a timestamp.
- Long-press to open the note input and save an optional note.
- Use the bottom toolbar to access History and Settings.
- In Settings → Delay, choose the minimum interval between taps (0s–1m).
- Toggle mode with the left-most toolbar icon (Two-way / Single).

## Publishing to GitHub Pages

1. Create a new repo on GitHub (or use an existing one).
2. Commit the project files, including `index.html` and `sw.js` (if present).
3. Push to the `main` branch.
4. In the repo settings, enable GitHub Pages and select the `main` branch (root).

The app will be served at `https://<your-username>.github.io/<repo>/`.

## Development notes

- Data persistence uses Dexie (IndexedDB wrapper). Entries are stored in the `entries` table.
- The tap delay setting is saved to `localStorage` as `m-delay`.
- UI tokens and colors are defined with CSS custom properties at the top of `index.html`.

## Contributing

PRs welcome. Please keep changes focused and preserve the single-file nature of the app where possible. Include screenshots and brief testing notes.

## License

Suggested: MIT — add `LICENSE` file if you choose to publish under MIT.

---

If you want, I can also:
- add a LICENSE file (MIT) and commit
- generate a minimal `package.json` and build script
- prepare a PR-ready branch and commit message

Tell me which next step you'd like.