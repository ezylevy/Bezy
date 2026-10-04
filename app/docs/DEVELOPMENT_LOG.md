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

## 2026-09-29 — Session handoff: audio, corrected map, and campaign DFS

> Historical snapshot. Its DFS blocker was resolved on 2026-10-03. The current
> continuation guide is `docs/CLAUDE_HANDOFF.md`.

### Product decisions and current scope

- Free Play remains implemented but hidden from the V1 navigation through
  `AppFeatures.freePlayEnabled`.
- The product owner supplied a corrected `assets/stages/map.png`. Preserve this
  file. `assets/stages/map-old.png` is an untracked personal backup and must not
  be committed unless the product owner explicitly asks for it.
- Sounds should be original/invented for BEZY rather than downloaded from
  third-party libraries. Background music has not been added.
- The home screen needs one persistent sound on/off control. Muting must silence
  all effects immediately and survive app restarts.
- Stages 25-50 must be normal, open puzzles rather than wall corridors. Their
  challenge should come from route choice and special-cell combinations, with
  no more than one newly introduced special-cell type in each five-stage group.
- For stages 27-50, the intended generation rule is to find at least three DFS
  solutions, vary both route geometry and starting gate between stages, and
  freeze a selected valid solution in the generated route cache.

### Implemented in the working tree, not yet finalized

- Added `audioplayers` and a centralized `SoundService` with safe playback
  failure handling and separate low-latency players for overlapping effects.
- Added `tool/generate_original_sfx.dart`, which deterministically synthesizes
  35 original 48 kHz PCM WAV effects. Generated files live under
  `assets/audio/sfx/` and can be replaced individually while keeping their
  filenames. The sound inventory and replacement process are documented in
  `docs/SOUND_DESIGN.md`.
- Connected sound cues to home/navigation, board movement and rejection,
  walls/gates/Lonely Cell, teleport, ice, mirror, clone, zero, black hole,
  bomb, Joker, target, victory, reset, hints, solver playback, challenge timer,
  map opening, locked stages, and stage unlocking.
- Connected the existing home sound icon to real persisted mute state and added
  a widget test keyed by `sound-toggle`.
- Measured the corrected 941 x 1672 map image and updated all 50 overlay centers
  in `world_map_screen.dart` to the artwork's circle centers. The existing
  serpentine-to-chronological reorder remains responsible for labels 1-50.
- Added Android backup/data-extraction rules for shared preferences. Ordinary
  app updates retain progress. Reinstall restoration can work through Android
  Auto Backup when the device/account supports it, but guaranteed cross-device
  restoration will still require a signed-in cloud-save feature.
- Extended `PathSolver` with multi-solution and shortest-solution APIs,
  ice-aware search, excluded route signatures, state pruning, and stable
  level-specific candidate ordering.
- Added generated-route tooling and cache files:
  `tool/generate_campaign_routes.dart`,
  `tool/generate_campaign_routes_test.dart`, and
  `lib/domain/campaign/generated_solution_routes.dart`.
- Updated campaign data toward the requested special-cell pacing, removed the
  stage-20 Lonely Cell issue, added mid-route smart-hint fallback behavior, and
  raised misleadingly low-value shortcuts in later boards.
- Added regression tests for route diversity, alternating starting gates,
  stage 33-35 minimum-move values, and the sound preference.

### Current blocker / exact continuation point

- The latest command was:
  `flutter test tool\\generate_campaign_routes_test.dart --reporter expanded`.
- It searched stages 27 onward for three fresh DFS routes and stopped after
  approximately three minutes at stage 39 (`w6_l9`):
  `Bad state: Stage 39 has only 0 DFS routes.`
- Therefore the generated route cache, focused tests, full test suite, analyzer,
  release APK, phone installation, and Git commit are **not yet complete**.
- Continue by diagnosing stage 39's board/search-budget interaction. Prefer a
  bounded fix to its level data or DFS ordering/budget; do not reduce the
  requirement that stages 27-50 have varied, valid solutions. Regenerate the
  cache only after stage 39 succeeds.

### Verification and release steps still required

1. Regenerate the frozen campaign route cache successfully for all 50 stages.
2. Run `flutter test test\\game_logic_test.dart --reporter expanded`; confirm
   stages 27-50 expose at least three solutions, consecutive stages vary their
   starting gate, primary route signatures are not repeated, and stages 33-35
   show the true shortest move count.
3. Run the complete `flutter test` suite and `flutter analyze`.
4. Build a release APK with `flutter build apk --release`. If Windows blocks
   plugin symlinks, enable Developer Mode or use the already-configured build
   environment before retrying.
5. Copy the verified APK to `app/dist/BEZY-Test.apk`, install with `adb install
   -r` (do not uninstall, because that may discard local progress), launch it,
   and capture `adb logcat` if it crashes. Confirm the APK contains `arm64-v8a`
   `libflutter.so`; the previous phone crash was caused by an x86_64-only APK.
6. Physically verify portrait and landscape layouts, corrected map-circle
   alignment, map pan/zoom bounds, stage 20 solver playback, mid-route hints,
   sound mute persistence, and representative special-cell sounds.
7. Review `git status` and commit the requested work, including the corrected
   `assets/stages/map.png`, but excluding `assets/stages/map-old.png` and any
   unrelated user files.

### Repository state at handoff

- Branch: `codex/v1-localization`.
- The working tree is intentionally dirty with the audio, map, solver, campaign,
  Android-backup, tests, generated plugin-registration, and documentation
  changes described above.
- Do not discard or overwrite the product owner's new PNG map.
- No emulator was used during this work.

## 2026-10-03 — Final Git/Claude handoff

- Completed the bounded build-time DFS generation for stages 25-50. Every
  stage now has three frozen solutions from different entry gates; primary
  routes vary across stages and consecutive stages vary their primary gate.
- Generated and cached independently verified minimum player-move counts. Ice
  continuation and teleport arrival count as part of the initiating gesture.
- Campaign runtime now consumes `generated_solution_routes.dart`; it does not
  search for the late-stage route when opening a level.
- Kept Free Play available only for local debug Web testing.
- Removed forward/back movement sounds while retaining haptics, added the funny
  message-report cue, and replaced stage unlock with an energetic surprise cue.
- Verified `flutter test` (47 passing tests), the route-generator test, and
  `flutter analyze --no-pub` (no issues).
- Added `docs/CLAUDE_HANDOFF.md` as the authoritative continuation guide.

## 2026-10-03 — Release-prep pass (Claude)

- Moved the owner's untracked `assets/stages/map-old.png` to
  `_local_backup/`, because `pubspec.yaml` bundles the whole `assets/stages/`
  folder and the backup was being packaged into local builds.
- Downscaled oversized raster art (same file names and aspect ratios; every
  usage is constrained with `BoxFit`): special cells and map markers
  1254px → 512px, runner figures → max 768px, `msg.png` → 1024px wide,
  `panel.png` → 1600px wide. `map.png` and `panel_landscape.png` keep their
  dimensions (map marker centers stay valid). Raster art went from 39.4 MB to
  13.3 MB; total `assets/` from ~47 MB to ~19 MB. Full-resolution originals are
  kept locally in `_original_assets/` (git-ignored).
- Stopped tracking `dist/BEZY-Test.apk` (the file stays on disk); `/dist/`,
  `/_local_backup/` and `/_original_assets/` are now git-ignored.
- `android/app/build.gradle.kts`: `bundleRelease` now fails when
  `android/key.properties` is missing, so a debug-signed App Bundle cannot be
  uploaded by mistake. Local release APKs still fall back to the debug key.
- Docs updated to the Product Owner's decisions: no Learning/Challenge modes in
  V1 (linear stage map only), not designated for children, API 36 requirement,
  Play account status check, GitHub Pages 404.
- Not verified here: `flutter test` / `flutter analyze` could not be run in
  this environment. Run both, then visually check tiles, map markers, the
  runner figure and message dialogs on a phone after the image downscale.
- Product Owner approved hiding both world-map controls: the
  Learning/Challenge toggle is off for V1 (`AppFeatures.modeToggleEnabled =
  false`, campaign stays in the Learning mode Home already passed) and the
  "Admin testing pass" button is shown only when `!kReleaseMode`. No tests
  referenced either control.

## 2026-10-04 — Owner bug-fix pass (Claude)

- World map: focus/zoom transforms are clamped so the artwork always covers
  the viewport (late stages 46–50 no longer reveal empty background); the
  InteractiveViewer minimum scale is the smallest zoom that still fills the
  screen. New widget test covers late-stage focus.
- Portrait stats panel: moves/sum/target labels and values lifted 7 px.
- Entry gates: green border/tint removed; bold gold border + gold glow; gold
  start icon. Instructions renamed to "Entry gate / שער כניסה" with golden
  wording (EN/HE) and the stage 1 description updated.
- Branding: new `lib/ui/components/bezy_brand.dart` (BezyLogo,
  AnimatedBezyLogo one-shot launch intro, BezyBackground icon-style navy
  background with faint tile grid). Logo replaces the "BEZY" text on the
  language screen, home hero and under every board. Logo asset downscaled to
  900 px (original kept in `_original_assets/logos/`).
- Home screen restyled on the icon background with translucent accent cards.
- Version bumped to 1.0.0+2 for the next App Bundle.
- Sounds: redesign deferred to the end of the polish pass (owner request).
