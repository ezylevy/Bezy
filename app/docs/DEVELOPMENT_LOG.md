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

## 2026-09-16 — Complete visible localization and orientation support

- Enabled portrait and landscape orientations on mobile.
- Rebuilt the Home screen with adaptive portrait and landscape compositions.
- Added a landscape gameplay composition with the board and controls sharing
  the available width while keeping the statistics bar readable.
- Localized every currently visible UI string outside the bilingual language
  selector: world map, level list, gameplay feedback, statistics, Free Play,
  victory, tile labels, and the guided solver.
- Added English display names for all 20 existing campaign levels and all four
  existing worlds without changing stable level identifiers or puzzle data.
- Added widget coverage for English world content, landscape Home, landscape
  Challenge gameplay, and the absence of help controls in Challenge mode.
- Verification: analyzer clean; all 14 tests passing.

## 2026-09-16 — First gameplay feedback fixes

- Fixed the mirrored path rendering in RTL by giving board geometry a stable
  left-to-right coordinate system while leaving the surrounding interface RTL.
- Matched the conduit centers to the grid's real five-pixel cell spacing.
- After a start tile is selected, all alternative start tiles now return to
  the normal number-tile appearance; only the chosen start remains marked.
- Moved the live remaining amount out of the statistics card into a prominent,
  accessible live-region banner directly above the board.
- Reduced the statistics card to target, current total, and moves.
- Added stable tile keys to support precise interaction and future animated
  player placement.
- Added regression coverage for board direction, start-tile deactivation, and
  the live remaining label.
- Verification: analyzer clean; all 15 tests passing.
