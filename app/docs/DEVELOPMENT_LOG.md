# BEZY Development Log

## 2026-09-16 — Baseline and V1 scope

- Imported the existing Flutter prototype into the managed workspace.
- Verified 20 campaign levels across four worlds.
- Recorded a clean analyzer baseline and eight passing tests.
- Defined the reduced V1 scope: Hebrew and English, no Teacher or Parent area.
- Recorded Product Owner approval to proceed with the recommended visual
  direction.

## 2026-09-16 — Localization foundation

- Added an offline localization layer with Hebrew and English support.
- Added mandatory first-launch language selection.
- Persisted the selected locale in local device storage.
- Connected Flutter's Material, Widgets, and Cupertino localization delegates.
- Converted the home screen and instructions to locale-aware copy.
- Removed the forced RTL direction from the home screen; direction now follows
  the active locale.
- Added tests for first-run selection, persistence, English LTR, and Hebrew RTL.
- Verification: analyzer clean; all nine tests passing.

## 2026-09-16 — Learning and Challenge foundation

- Added an explicit domain-level `GameMode` model.
- Added a localized mode-selection screen between Journey and the world map.
- Propagated the selected mode through world, level, and gameplay navigation.
- Enforced Challenge restrictions at both the interface and method levels:
  hint and solution controls are absent, and their handlers reject access.
- Kept Free Play in Learning mode until its dedicated flow is designed.
- Added policy tests proving Learning allows help and Challenge blocks it.
- Verification: analyzer clean; all 11 tests passing.
