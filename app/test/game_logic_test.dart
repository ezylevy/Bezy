import 'package:flutter_test/flutter_test.dart';
import 'package:bezy/domain/campaign/campaign_levels.dart';
import 'package:bezy/domain/campaign/level_generator.dart';
import 'package:bezy/domain/models/tile_model.dart';
import 'package:bezy/domain/solver/path_solver.dart';

void main() {
  group('TileModel Modular Mechanics', () {
    test('Standard Number tile adds its value to sum', () {
      const tile = TileModel(
        index: 0,
        row: 0,
        col: 0,
        type: TileType.number,
        value: 5,
      );
      expect(tile.isWalkable, true);
      expect(tile.canEnter(10), true);
      expect(tile.applyValue(10), 15);
    });

    test('Wall tile is impassable', () {
      const wall = TileModel(
        index: 1,
        row: 0,
        col: 1,
        type: TileType.wall,
        value: 0,
      );
      expect(wall.isWalkable, false);
      expect(wall.canEnter(10), false);
    });

    test('Trampoline tile adds value plus bonus', () {
      const trampoline = TileModel(
        index: 2,
        row: 0,
        col: 2,
        type: TileType.trampoline,
        value: 4,
        metadata: {'bonus': 3},
      );
      expect(trampoline.canEnter(10), true);
      expect(trampoline.applyValue(10), 17);
    });

    test('SmartGate tile enforces conditions', () {
      const gate = TileModel(
        index: 3,
        row: 0,
        col: 3,
        type: TileType.smartGate,
        value: 2,
        metadata: {'rule': 'even'},
      );
      expect(gate.canEnter(10), true);
      expect(gate.canEnter(11), false);
    });
  });

  group('All Campaign Levels Solvability', () {
    test('All 20 levels in campaign are verified solvable', () {
      final allLevels = CampaignLevels.getAllLevels();
      expect(allLevels.length, 20);

      for (final lvl in allLevels) {
        final solution = PathSolver.findSolution(lvl);
        expect(solution, isNotNull,
            reason: 'Level ${lvl.id} (${lvl.worldTitle} - ${lvl.title}) must be solvable');
        expect(solution!.first, isIn(lvl.startIndices));
        expect(solution.last, lvl.centerIndex);

        // Verify wall avoidance
        final walls = lvl.tiles.where((t) => t.isWall).map((t) => t.index).toSet();
        for (final idx in solution) {
          expect(walls.contains(idx), false,
              reason: 'Solution must not touch walls');
        }
      }
    });

    test('Smart hint provides the next step on an active route', () {
      final lvl = CampaignLevels.getLevelsForWorld(1).first;
      final solution = PathSolver.findSolution(lvl)!;

      final partialPath = [solution[0]];
      final initialSum = lvl.tiles[solution[0]].applyValue(0);

      final nextStep = PathSolver.getNextStepHint(
        level: lvl,
        currentPath: partialPath,
        currentSum: initialSum,
      );

      expect(nextStep, isNotNull);
      expect(nextStep, solution[1]);
    });

    test('LevelGenerator produces solvable levels', () {
      final generated = LevelGenerator.generate(
        gridSize: 3,
        minTarget: 10,
        maxTarget: 20,
      );
      final solution = PathSolver.findSolution(generated);
      expect(solution, isNotNull);
      expect(solution!.isNotEmpty, true);
    });
  });
}
