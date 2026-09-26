# BEZY

BEZY is an offline-first educational path puzzle for Android and iOS, built
with Flutter. The first production release supports Hebrew and English, a
50-stage campaign, Learning and Challenge modes, local progress, and responsive
portrait and landscape layouts. Free Play remains in the codebase behind a
disabled release feature switch.

## Current baseline

- 50 verified-solvable campaign levels across ten worlds.
- Procedural level generator and path solver.
- Local progress using `shared_preferences`.
- Home, world map, level selection, game, victory, solver, and custom-game UI.
- A clean Flutter analyzer and automated logic/widget regression suite.

The approved V1 scope and baseline audit are maintained in `docs/`.

## Development commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Release signing, store metadata, privacy text, and the submission checklist are
documented in `docs/RELEASE_CHECKLIST.md`.

Visual design work is gated on Product Owner consultation and explicit
approval. Architecture and test preparation may proceed before that gate.
