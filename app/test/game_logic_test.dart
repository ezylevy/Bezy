import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:bezy/domain/campaign/campaign_levels.dart';
import 'package:bezy/domain/campaign/level_generator.dart';
import 'package:bezy/domain/models/level_model.dart';
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

    test('Teleporting door preserves the current total', () {
      const trampoline = TileModel(
        index: 2,
        row: 0,
        col: 2,
        type: TileType.trampoline,
        value: 4,
        metadata: {'bonus': 3},
      );
      expect(trampoline.canEnter(10), true);
      expect(trampoline.applyValue(10), 10);
    });

    test('Legacy SmartGate cells remain enterable from every direction', () {
      const gate = TileModel(
        index: 3,
        row: 0,
        col: 3,
        type: TileType.smartGate,
        value: 2,
        metadata: {'rule': 'even'},
      );
      expect(gate.canEnter(10), true);
      expect(gate.canEnter(11), true);
    });

    test('Mirror reverses digits', () {
      const tile = TileModel(index: 0, row: 0, col: 0, type: TileType.mirror);
      expect(tile.applyValue(23), 32);
      expect(tile.applyValue(140), 41);
      expect(tile.applyValue(2), 20);
    });

    test('Clone doubles and Zero resets the total', () {
      const clone = TileModel(index: 0, row: 0, col: 0, type: TileType.clone);
      const zero = TileModel(index: 1, row: 0, col: 1, type: TileType.zero);
      expect(clone.applyValue(12), 24);
      expect(zero.applyValue(57), 0);
    });

    test('Black Hole and Bomb preserve the current total', () {
      const blackHole = TileModel(
        index: 0,
        row: 0,
        col: 0,
        type: TileType.blackHole,
      );
      const bomb = TileModel(index: 1, row: 0, col: 1, type: TileType.bomb);
      expect(blackHole.applyValue(31), 31);
      expect(bomb.applyValue(31), 31);
    });
  });

  group('All Campaign Levels Solvability', () {
    test('Lonely Cell unlocks only after all four neighbors were visited', () {
      final tiles = List.generate(
        25,
        (index) => TileModel(
          index: index,
          row: index ~/ 5,
          col: index % 5,
          type: index == 8
              ? TileType.lonely
              : index == 12
              ? TileType.target
              : TileType.number,
          value: 0,
        ),
      );
      final level = LevelModel(
        id: 'lonely-rule-test',
        worldId: 1,
        levelNumber: 1,
        worldTitle: 'Test',
        title: 'Lonely',
        gridSize: 5,
        targetNumber: 0,
        tiles: tiles,
        parMoves: 1,
      );

      expect(level.orthogonalNeighborIndices(8), [3, 13, 7, 9]);
      expect(level.isLonelyUnlocked(8, {3, 7, 9}), isFalse);
      expect(level.isLonelyUnlocked(8, {3, 7, 9, 13}), isTrue);
    });

    test('Solver uses visit history when continuing through a Lonely Cell', () {
      const walkable = {3, 7, 8, 9, 12, 13};
      final tiles = List.generate(25, (index) {
        final type = index == 8
            ? TileType.lonely
            : index == 12
            ? TileType.target
            : walkable.contains(index)
            ? TileType.number
            : TileType.wall;
        return TileModel(
          index: index,
          row: index ~/ 5,
          col: index % 5,
          type: type,
          value: 0,
        );
      });
      final level = LevelModel(
        id: 'lonely-solver-test',
        worldId: 1,
        levelNumber: 1,
        worldTitle: 'Test',
        title: 'Lonely solver',
        gridSize: 5,
        targetNumber: 0,
        tiles: tiles,
        parMoves: 3,
      );

      expect(
        PathSolver.findRouteFromCurrent(
          level: level,
          currentPath: const [3],
          currentSum: 0,
        ),
        isNull,
      );
      expect(
        PathSolver.findRouteFromCurrent(
          level: level,
          currentPath: const [3],
          currentSum: 0,
          visitedIndices: const {3, 7, 9, 13},
        ),
        [3, 8, 13, 12],
      );
    });

    test('World 4 introduces special cells progressively', () {
      final levels = CampaignLevels.getLevelsForWorld(4);

      expect(levels[0].tiles.any((tile) => tile.isMirror), true);
      expect(levels[1].tiles.any((tile) => tile.isClone), true);
      expect(levels[2].tiles.any((tile) => tile.isZero), true);
      expect(levels[3].tiles.any((tile) => tile.isBlackHole), true);

      final finalTypes = levels[4].tiles.map((tile) => tile.type).toSet();
      expect(
        finalTypes,
        containsAll({
          TileType.mirror,
          TileType.clone,
          TileType.blackHole,
          TileType.bomb,
          TileType.zero,
        }),
      );

      final specialIndices = levels[4].tiles
          .where(
            (tile) => {
              TileType.mirror,
              TileType.clone,
              TileType.blackHole,
              TileType.bomb,
              TileType.zero,
            }.contains(tile.type),
          )
          .map((tile) => tile.index)
          .toList();
      for (var i = 0; i < specialIndices.length; i++) {
        for (var j = i + 1; j < specialIndices.length; j++) {
          final rowDistance = (specialIndices[i] ~/ 9 - specialIndices[j] ~/ 9)
              .abs();
          final colDistance = (specialIndices[i] % 9 - specialIndices[j] % 9)
              .abs();
          expect(
            rowDistance + colDistance,
            greaterThanOrEqualTo(2),
            reason: 'Special cells should be spread around the final board',
          );
        }
      }
    });

    test('All 50 levels in campaign are verified solvable', () {
      final allLevels = CampaignLevels.getAllLevels();
      expect(allLevels.length, 50);

      for (final lvl in allLevels) {
        final solution = PathSolver.findSolution(lvl);
        expect(
          solution,
          isNotNull,
          reason:
              'Level ${lvl.id} (${lvl.worldTitle} - ${lvl.title}) must be solvable',
        );
        expect(solution!.first, isIn(lvl.startIndices));
        expect(solution.last, lvl.centerIndex);

        // Verify wall avoidance
        final walls = lvl.tiles
            .where((t) => t.isWall)
            .map((t) => t.index)
            .toSet();
        for (final idx in solution) {
          expect(
            walls.contains(idx),
            false,
            reason: 'Solution must not touch walls',
          );
        }
      }
    });

    test(
      'DFS can rediscover solutions without the campaign solution cache',
      () {
        final allLevels = CampaignLevels.getAllLevels();
        for (final index in List.generate(26, (offset) => offset + 24)) {
          final level = allLevels[index];
          final knownLength = level.solutionRoutes.first.length;
          final discovered = PathSolver.findSolution(
            level,
            useKnownSolutions: false,
            maxDepth: knownLength,
          );

          expect(
            discovered,
            isNotNull,
            reason: 'DFS must independently solve campaign stage ${index + 1}',
          );
          expect(discovered!.last, level.centerIndex);
        }
      },
    );

    test('The campaign includes the Lonely Cell', () {
      expect(
        CampaignLevels.getAllLevels().any(
          (level) => level.tiles.any((tile) => tile.isLonely),
        ),
        isTrue,
      );
    });

    test('No campaign level puts more than one wall beside the target', () {
      for (final level in CampaignLevels.getAllLevels()) {
        final adjacentWalls = level
            .orthogonalNeighborIndices(level.centerIndex)
            .where((index) => level.tiles[index].isWall)
            .length;
        expect(
          adjacentWalls,
          lessThanOrEqualTo(1),
          reason: '${level.id} has $adjacentWalls walls beside its target',
        );
      }
    });

    test('Extra 30 levels use the approved challenge tiers', () {
      final extra = CampaignLevels.getAllLevels().skip(20).toList();
      expect(extra, hasLength(30));
      expect(
        extra.take(10).every((level) => level.challengeTimeSeconds == 60),
        isTrue,
      );
      expect(
        extra
            .skip(10)
            .take(10)
            .every((level) => level.challengeTimeSeconds == 45),
        isTrue,
      );
      expect(
        extra.skip(20).every((level) => level.challengeTimeSeconds == 30),
        isTrue,
      );
      expect(extra.every((level) => level.optimalMoves != null), isTrue);
      expect(extra.every((level) => level.targetNumber >= 8), isTrue);
      expect(
        extra.every((level) => level.targetNumber <= 88),
        isTrue,
        reason: extra
            .where((level) => level.targetNumber > 88)
            .map((level) => '${level.id}:${level.targetNumber}')
            .join(', '),
      );

      final postTutorial = extra.skip(2);
      expect(
        postTutorial.every((level) => level.startIndices.length >= 2),
        isTrue,
        reason: 'Stages after the Joker tutorials should be open boards',
      );
      expect(
        extra
            .skip(2)
            .take(8)
            .every(
              (level) => level.tiles.where((tile) => tile.isJoker).length >= 2,
            ),
        isTrue,
        reason: 'Later Joker stages should offer a Joker on both routes',
      );
      expect(
        extra
            .skip(4)
            .every((level) => level.tiles.every((tile) => !tile.isWall)),
        isTrue,
        reason: 'Stages 25-50 should be open boards, not wall corridors',
      );
    });

    test('Joker exposes two choices and applies the selected value', () {
      const joker = TileModel(
        index: 1,
        row: 0,
        col: 1,
        type: TileType.joker,
        metadata: {
          'options': [3, 8],
        },
      );
      expect(joker.jokerOptions, [3, 8]);
      expect(joker.applyJokerChoice(12, 8), 20);
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

    test('Generated boards keep at most one wall beside the target', () {
      final random = Random(20260926);
      for (var attempt = 0; attempt < 20; attempt++) {
        final generated = LevelGenerator.generate(
          gridSize: 7,
          includeWalls: true,
          wallCount: 12,
          minTarget: 20,
          maxTarget: 40,
          random: random,
        );
        final adjacentWalls = generated
            .orthogonalNeighborIndices(generated.centerIndex)
            .where((index) => generated.tiles[index].isWall)
            .length;
        expect(adjacentWalls, lessThanOrEqualTo(1));
      }
    });

    test('LevelGenerator gives zero the same digit pool as 1 through 9', () {
      final random = Random(20260920);
      final seenDigits = <int>{};
      final seenStartDigits = <int>{};

      for (var i = 0; i < 30; i++) {
        final generated = LevelGenerator.generate(
          gridSize: 3,
          minTarget: 10,
          maxTarget: 20,
          random: random,
        );
        seenDigits.addAll(
          generated.tiles
              .where((tile) => tile.isStart || tile.type == TileType.number)
              .map((tile) => tile.value),
        );
        seenStartDigits.addAll(
          generated.tiles
              .where((tile) => tile.isStart)
              .map((tile) => tile.value),
        );
      }

      expect(seenDigits, containsAll(List.generate(10, (digit) => digit)));
      expect(seenStartDigits, contains(0));
    });
  });
}
