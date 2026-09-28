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

## 2026-09-26 — Campaign map and gameplay stabilization

- Replaced the chapter list with an illustrated, interactive 50-stage campaign
  map, including locked, unlocking, and revealed stage states.
- Added persistent stage reveal state and returned completed gameplay to the
  map so progression remains visible.
- Completed the Lonely Cell rules across gameplay, hints, the solver, and
  campaign validation.
- Added framed gameplay feedback and first-appearance guidance with an explicit
  localized "Don't show this again" preference.
- Softened the map's initial zoom so it glides to the top with stage 1 visible.
- Centered the remaining-target label within the yellow panel artwork.
- Verification: analyzer clean; all 40 automated tests passing, including
  solvability checks for all 50 campaign levels. No emulator was used.

## 2026-09-26 — Gameplay and campaign QA fixes

- Corrected the campaign-map sequence to follow the illustrated road in
  chronological order from 1 through 50.
- Limited campaign and generated boards to at most one wall beside the target.
- Made the Lonely Cell reveal its underlying number and behave as an ordinary
  number cell after the player successfully enters it.
- Made teleport movement place the runner immediately on the destination door.
- Made illustrated feedback dialogs grow with their message while retaining a
  safe scroll area on small screens.
- Kept stages 21-24 as progressive tutorials, with two route choices after the
  first two Joker explanations. Stages 25-50 are open, wall-free boards whose
  difficulty comes from choices, timers, targets, and combined special cells.
- Normalized the iOS bundle identifier to `com.ezylevy.bezy`. A signed iOS IPA
  still requires an Apple development team and a macOS/Xcode build.
- Hid Free Play from V1 navigation behind `AppFeatures.freePlayEnabled` while
  preserving its implementation for a later release.
- Upgraded the path solver with heuristic move ordering, repeated-state
  pruning, a search budget, and an explicit cache-free DFS verification mode.
- Normalized the Android production identity to `com.ezylevy.bezy`, added a
  release-keystore template, marked iOS as using no non-exempt encryption, and
  prepared store copy, privacy text, and release/submission checklists.
- Added ready-to-host privacy/support pages for `naraelapp@gmail.com`, exact
  Apple privacy answers, per-app children/age-rating guidance, a secure
  upload-key creation tool, and a physical-device crash-capture tool.
- Added an in-app privacy-policy button and a GitHub Pages deployment workflow;
  public deployment remains gated on an explicit push/Pages approval.
- Returned launcher-icon ownership to the product owner and removed the
  generated icon variants while preserving the supplied source image.
