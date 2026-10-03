# BEZY V1 Scope

Status: approved working scope. Updated 2026-10-03 by Product Owner decision.

## Product decision history

- 2026-09-16: Scope approved with Learning and Challenge modes and Free Play.
- 2026-10-03: **Modes removed from V1.** V1 is a single campaign: an
  illustrated stage map with linear progression (each stage unlocks the next).
  Free Play stays hidden in release builds. The app is not designated for
  children (general audience 13+).

## Included

- Android release build for Google Play (iOS follows after Android).
- Offline-only gameplay with no account, cloud database, advertising, or
  analytics.
- Local progress and settings stored on the device.
- Complete Hebrew and English copy with correct RTL and LTR behavior.
- One campaign of 50 stages on an illustrated world map, unlocked linearly.
- Special cells introduced gradually (Joker, teleport, ice, mirror, clone,
  zero, bomb, black hole and others), each verified solvable by automated tests.
- Original procedurally generated sound effects with a persisted mute switch;
  haptic feedback for movement.
- Phone and tablet support in portrait and landscape.
- Store-ready metadata, privacy declarations, icons, screenshots, and a signed
  App Bundle.

## Not in V1

- Learning/Challenge mode selection. The mode code remains compiled and
  tested, but the world-map toggle is hidden (`AppFeatures.modeToggleEnabled`
  is `false`); the campaign always runs in the mode Home passes (Learning).
- The "Admin testing pass" unlock-all button (`AppFeatures.adminPassEnabled`
  shows it only in debug/profile builds).
- Free Play (kept behind `AppFeatures.freePlayEnabled`, debug Web only).
- Spanish and Arabic translations.
- Teacher and parent areas.
- Accounts, cloud sync, remote analytics, advertising, online services.
- Background music.

## Design direction

Colorful, modern adventure with distinct worlds, a clear high-contrast board,
concise rewarding motion, visible progression, and a tone that is friendly
without feeling childish.

## Definition of done

V1 is done when all 50 stages are verified solvable, Hebrew and English are
complete, stages unlock strictly in order, no mode toggle or admin control is
visible in the release build, local progress survives restarts and updates,
portrait and landscape layouts pass on real devices, automated checks pass, and
a signed Android App Bundle is ready for Play submission.
