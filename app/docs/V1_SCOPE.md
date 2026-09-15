# BEZY V1 Scope

Status: approved working scope, pending visual-design consultation.

## Included

- Android and iOS release builds.
- Offline-only gameplay with no account, cloud database, advertising, or
  analytics.
- Local progress and settings stored on the device.
- Localization-ready architecture.
- Complete Hebrew and English copy for V1.
- Correct RTL and LTR behavior.
- Learning mode with staged hints and explanatory feedback.
- Challenge mode with no hints, solution playback, or solution shortcuts.
- A 50-level campaign. Existing levels may be retained after gameplay and
  quality review; missing levels must be authored, validated, and balanced.
- Free Play using the existing level generator.
- Phone and tablet support in portrait and landscape.
- Accessibility, offline, persistence, localization, gameplay, widget, and
  integration tests appropriate to each phase.
- Store-ready metadata, privacy declarations, icons, screenshots, and release
  builds.

## Deferred

- Spanish and Arabic translations. Their addition must not require an
  architectural rewrite.
- Teacher area.
- Parent area.
- Accounts, cloud synchronization, remote analytics, advertising, and online
  services.
- Downloadable worlds and other network-dependent features.

## Design gate

No production visual design, final component system, mascot, illustration set,
or redesigned gameplay screen begins before a consultation with the Product
Owner and explicit approval of the chosen direction.

## Definition of done

V1 is done only when all 50 levels are verified solvable, Hebrew and English
are complete, the two modes enforce their distinct rules, local progress
survives restarts, portrait and landscape layouts pass on the target device
matrix, automated checks pass, and signed Android and iOS candidates are ready
for store submission.
