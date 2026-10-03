# BEZY handoff for Claude

Updated: 2026-10-03

## Start here

- Repository: `https://github.com/ezylevy/Bezy.git`
- Working branch: `codex/v1-localization`
- App root: `app/`
- Begin from the latest remote tip of that branch. The branch contains the
  earlier localization/campaign work and the final fixes described here.
- Do not add `app/assets/stages/map-old.png`. It is the product owner's local,
  untracked backup. The corrected `app/assets/stages/map.png` is intentional and
  is tracked.

## Verified state

The current source passes:

```powershell
cd app
flutter test
flutter analyze --no-pub
```

The complete suite currently contains 47 passing tests, and static analysis
reports no issues. Campaign-route generation is also covered by:

```powershell
flutter test tool/generate_campaign_routes_test.dart
```

That test regenerates the frozen route file and fails if route generation cannot
complete successfully.
A new release APK and a physical-device QA pass have not been performed after
the final route and sound changes.

## Campaign routes and move counts

The key product requirement is that DFS for the late campaign is an authoring
step, not work performed when a campaign level opens. The implementation is:

1. `tool/generate_campaign_routes.dart` runs bounded DFS for stages 25-50.
2. It selects three valid routes from three different entry gates for every
   stage. The primary routes are unique across the late campaign and consecutive
   stages do not reuse the same primary entry gate.
3. It independently finds a shortest solution and converts it to actual player
   gestures with `PathSolver.countUserMoves`. Automatic ice continuation and
   teleport arrival are not incorrectly counted as extra moves.
4. It writes both routes and optimal move counts to
   `lib/domain/campaign/generated_solution_routes.dart`.
5. `extra_campaign_levels.dart` reads that generated cache at runtime. Do not
   replace this with on-open DFS or hand-edit the generated file.

The primary search prefers a route that demonstrates the stage's special tile.
If that would duplicate an earlier primary route, generation falls back to a
different valid primary route. Alternate routes intentionally use other entry
gates. The source boards remain open puzzles rather than single wall corridors.

`PathSolver` still contains generic search APIs because they are also used by
tests, the smart-hint continuation logic, and the local-only random Free Play
generator. The late campaign's stored solutions and move targets are generated
ahead of time as described above.

## Free Play test access

Free Play is visible only in a local debug Web build:

```dart
static bool get freePlayEnabled => kIsWeb && kDebugMode;
```

It stays hidden in release builds and on mobile. Run `flutter run -d chrome` or
the repository's existing local Web workflow when it is needed for testing.

## Sound state

- `SoundService` owns sound playback and persisted mute state.
- Moving forward and back on the board has haptic feedback only; it no longer
  plays movement sounds.
- Illustrated message dialogs play `message_report.wav`, a short funny
  reporting flourish.
- Unlocking a stage plays the new energetic/surprising `stage_unlock.wav`.
- There are 36 original deterministic WAV effects under `assets/audio/sfx/`.
- Regenerate them with the SDK Dart executable and
  `tool/generate_original_sfx.dart`. On this Windows setup, direct `dart run`
  may hit a native-hook permission issue, so using `dart.exe` explicitly is the
  known-good route.
- See `docs/SOUND_DESIGN.md` for the cue inventory and replacement contract.

## Other included fixes

- Corrected world-map art and recalibrated all 50 level-marker centers.
- Improved landscape map/game layout and solution playback behavior.
- Added Android backup/data-extraction rules so normal updates preserve local
  progress and supported Android backup can restore preferences.
- Added persisted sound toggle behavior and related widget coverage.
- Preserved Challenge mode without hint or solution controls.
- Kept stage 20 and special-cell behavior covered by regression tests.

## Recommended next work

1. Build a fresh release APK: `flutter build apk --release`.
2. Copy it to the agreed test-distribution location and install with
   `adb install -r` so existing progress is not intentionally removed.
3. Physically check portrait and landscape, map marker alignment, stages 25-50
   route variety/move targets, message/unlock audio, and mute persistence.
4. Confirm the APK has the required phone ABI; a previous crash came from an
   x86_64-only artifact rather than the current Dart code.
5. Background music and guaranteed cross-device cloud saves are not implemented.

`app/dist/BEZY-Test.apk` is currently tracked and is about 89 MB. It predates
the final route/sound changes, so do not treat it as the verified current build.
GitHub accepts it but warns that it exceeds the recommended 50 MB limit; use a
release attachment or Git LFS for future binary distribution if appropriate.

## Guardrails

- Treat `generated_solution_routes.dart` as generated output.
- Regenerate and rerun all tests after changing any late-stage board, special
  tile, solver rule, or move-count semantics.
- Preserve the corrected tracked `map.png` and keep `map-old.png` local.
- Do not expose Free Play in release/mobile without an explicit product decision.
