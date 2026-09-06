## Notekar v7.3.3

Signed release - built automatically from the branch.

### What's New

- **True Bed of Red Physical Swipe Geometry (`SwipeableCardBed`)**:
    - Re-engineered swipe-to-delete mechanics across `TimelineSessionCard` and `TimelineSingleTile`
      with a dedicated physical background bed.
    - The solid crimson ground conforms precisely to the card's 16pt (sessions) and 12pt (singles)
      corner radius, eliminating straight-line gap cutouts during drag gestures.
    - Paired with tactile haptic feedback and the floating Dynamic Island countdown capsule for
      instant 5-second undos.

- **Apple Keynote What's New Redesign**:
    - Standardized all What's New hero keynote cards and major innovation cards to flush settings
      group container widths.
    - Re-proportioned keynote pill badges, release edition labels, and metadata chips to eliminate
      horizontal text overflows across all display scales.
    - Integrated Steve Jobs design colophon celebrating craft, tactile feedback, and sensory
      restraint.

- **Sovereign Bulletins Notice Center & Offline Verification**:
    - Coupled Official Bulletins and Advisories visibility directly to the App Notices master toggle
      in Notification & Updates settings.
    - Introduced a deliberate 1-second Cupertino activity indicator on manual checks paired with
      socket-level DNS verification for immediate offline detection.

### Improvements & Polish

- **Elevated App Philosophy**: Refined the About page philosophy card with clean typographical
  hierarchy, removing redundant subtitles.
- **Minimal Reset Aesthetics**: Replaced verbose warning banners on the Reset Data page with a
  minimal, elegant icon and concise description.
- **Search & Guides Refresh**: Re-indexed settings search keywords and updated in-app help
  documentation to cover new sovereign features.
- Full automated test suite coverage across physical swipe geometry, bulletins sheet, and keynote
  views.

### Bug Fixes

- Resolved edge-case layout overflows on What's New hero pill badges on compact Android screens.
- Fixed background cutout clipping when dragging connected session interval cards.

### Security and Integrity

NoteKar binaries undergo automated compilation and scanning.

- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder

