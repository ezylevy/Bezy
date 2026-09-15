import 'dart:math';
import '../models/level_model.dart';
import '../models/tile_model.dart';
import '../solver/path_solver.dart';

/// Generates valid, solvable levels on the fly with customizable features.
class LevelGenerator {
  static final Random _rng = Random();

  /// Generates a valid puzzle level of size [gridSize].
  static LevelModel generate({
    int gridSize = 5,
    int? worldId,
    int? levelNumber,
    String? title,
    bool includeWalls = false,
    int wallCount = 0,
    bool includeTrampolines = false,
    bool includeSmartGates = false,
    int minTarget = 15,
    int maxTarget = 65,
  }) {
    assert(gridSize % 2 == 1, 'Grid size must be odd to have a center cell.');

    final totalCells = gridSize * gridSize;
    final centerIndex = totalCells ~/ 2;
    final defaultStarts = LevelModel.calculateDefaultStartPoints(gridSize);

    LevelModel? candidate;
    var attempts = 0;

    while (candidate == null && attempts < 200) {
      attempts++;
      final targetNumber = minTarget + _rng.nextInt(maxTarget - minTarget + 1);
      final tiles = <TileModel>[];

      // Prepare random wall placements if requested (avoid center and start positions)
      final wallIndices = <int>{};
      if (includeWalls && wallCount > 0) {
        var tries = 0;
        while (wallIndices.length < wallCount && tries < 50) {
          tries++;
          final rIndex = _rng.nextInt(totalCells);
          if (rIndex != centerIndex && !defaultStarts.contains(rIndex)) {
            wallIndices.add(rIndex);
          }
        }
      }

      int? trampolineIndex;
      if (includeTrampolines && _rng.nextBool()) {
        final cand = _rng.nextInt(totalCells);
        if (cand != centerIndex &&
            !defaultStarts.contains(cand) &&
            !wallIndices.contains(cand)) {
          trampolineIndex = cand;
        }
      }

      int? smartGateIndex;
      if (includeSmartGates && _rng.nextBool()) {
        final cand = _rng.nextInt(totalCells);
        if (cand != centerIndex &&
            !defaultStarts.contains(cand) &&
            !wallIndices.contains(cand) &&
            cand != trampolineIndex) {
          smartGateIndex = cand;
        }
      }

      for (var i = 0; i < totalCells; i++) {
        final row = i ~/ gridSize;
        final col = i % gridSize;

        if (i == centerIndex) {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.target,
              value: targetNumber,
            ),
          );
        } else if (defaultStarts.contains(i)) {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.start,
              value: _rng.nextInt(7) + 1, // 1 to 7
            ),
          );
        } else if (wallIndices.contains(i)) {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.wall,
              value: 0,
            ),
          );
        } else if (i == trampolineIndex) {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.trampoline,
              value: _rng.nextInt(5) + 1,
              metadata: {'bonus': 3},
            ),
          );
        } else if (i == smartGateIndex) {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.smartGate,
              value: _rng.nextInt(6) + 1,
              customLabel: 'זוגי',
              metadata: {'rule': 'even'},
            ),
          );
        } else {
          tiles.add(
            TileModel(
              index: i,
              row: row,
              col: col,
              type: TileType.number,
              value: _rng.nextInt(10), // 0 to 9
            ),
          );
        }
      }

      final testLevel = LevelModel(
        id: 'gen_${DateTime.now().millisecondsSinceEpoch}_$attempts',
        worldId: worldId ?? 0,
        levelNumber: levelNumber ?? 0,
        worldTitle: 'משחק חופשי',
        title: title ?? 'לוח אתגר $gridSize x $gridSize',
        gridSize: gridSize,
        targetNumber: targetNumber,
        tiles: tiles,
        parMoves: (gridSize * 1.5).round(),
        description: 'הגיעו לסכום $targetNumber במרכז',
      );

      final solution = PathSolver.findSolution(testLevel);
      if (solution != null && solution.isNotEmpty) {
        candidate = testLevel.copyWith(
          parMoves: max(solution.length, (gridSize * 1.5).round()),
        );
      }
    }

    // Fallback if random attempts timed out (construct a guaranteed simple path)
    if (candidate == null) {
      return _generateGuaranteedSimpleLevel(gridSize: gridSize);
    }

    return candidate;
  }

  static LevelModel _generateGuaranteedSimpleLevel({required int gridSize}) {
    final totalCells = gridSize * gridSize;
    final centerIndex = totalCells ~/ 2;
    final defaultStarts = LevelModel.calculateDefaultStartPoints(gridSize);
    final target = 18;
    final tiles = <TileModel>[];

    for (var i = 0; i < totalCells; i++) {
      final row = i ~/ gridSize;
      final col = i % gridSize;
      if (i == centerIndex) {
        tiles.add(
          TileModel(
            index: i,
            row: row,
            col: col,
            type: TileType.target,
            value: target,
          ),
        );
      } else if (defaultStarts.contains(i)) {
        tiles.add(
          TileModel(
            index: i,
            row: row,
            col: col,
            type: TileType.start,
            value: 3,
          ),
        );
      } else {
        tiles.add(
          TileModel(
            index: i,
            row: row,
            col: col,
            type: TileType.number,
            value: 3,
          ),
        );
      }
    }

    return LevelModel(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      worldId: 0,
      levelNumber: 0,
      worldTitle: 'משחק חופשי',
      title: 'לוח אתגר $gridSize x $gridSize',
      gridSize: gridSize,
      targetNumber: target,
      tiles: tiles,
      parMoves: gridSize,
      description: 'הגיעו למרכז עם סכום מדויק של $target',
    );
  }
}
