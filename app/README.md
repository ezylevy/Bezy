# BEZY

BEZY is an offline-first educational path puzzle for Android and iOS, built
with Flutter. The first production release supports Hebrew and English,
Learning and Challenge modes, local progress, and responsive portrait and
landscape layouts.

## Current baseline

- 20 solvable campaign levels across four worlds.
- Procedural level generator and path solver.
- Local progress using `shared_preferences`.
- Home, world map, level selection, game, victory, solver, and custom-game UI.
- Eight passing automated tests and a clean Flutter analyzer baseline.

The approved V1 scope and baseline audit are maintained in `docs/`.

## Development commands

```powershell
flutter pub get
flutter analyze
flutter test
```

Visual design work is gated on Product Owner consultation and explicit
approval. Architecture and test preparation may proceed before that gate.
