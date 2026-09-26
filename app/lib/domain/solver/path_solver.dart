import '../models/level_model.dart';

/// Intelligent pathfinding solver and hint engine.
class PathSolver {
  /// Finds the first valid route from any start point to the center target.
  ///
  /// Campaign levels may contain a previously discovered solution. It is used
  /// as a fast, validated cache for hints. Set [useKnownSolutions] to false to
  /// force a fresh DFS discovery, for example when authoring a level.
  static List<int>? findSolution(
    LevelModel level, {
    bool useKnownSolutions = true,
    int maxDepth = 40,
    int maxVisitedStates = 500000,
  }) {
    if (useKnownSolutions) {
      for (final route in level.solutionRoutes) {
        if (_isValidConfiguredRoute(level, route)) {
          return List<int>.from(route);
        }
      }
    }

    for (final startPoint in level.startIndices) {
      final route = findRouteFromStart(
        level,
        startPoint,
        maxDepth: maxDepth,
        maxVisitedStates: maxVisitedStates,
      );
      if (route != null) {
        return route;
      }
    }
    return null;
  }

  static bool _isValidConfiguredRoute(LevelModel level, List<int> route) {
    if (route.isEmpty ||
        !level.startIndices.contains(route.first) ||
        route.last != level.centerIndex ||
        route.toSet().length != route.length) {
      return false;
    }

    var sum = 0;
    final visited = <int>{};
    for (var position = 0; position < route.length; position++) {
      final index = route[position];
      if (index < 0 || index >= level.tiles.length) return false;
      final tile = level.tiles[index];
      if (!tile.isWalkable || !level.canEnterTile(index, sum, visited)) {
        return false;
      }
      if (position > 0) {
        final previous = route[position - 1];
        final rowDistance =
            (index ~/ level.gridSize - previous ~/ level.gridSize).abs();
        final columnDistance =
            (index % level.gridSize - previous % level.gridSize).abs();
        final teleported =
            level.tiles[previous].isTrampoline &&
            level.pairedTeleportIndex(previous) == index;
        if (rowDistance + columnDistance != 1 && !teleported) return false;
      }
      if (!tile.isTarget) sum = tile.applyValue(sum);
      visited.add(index);
    }
    return sum == level.targetNumber;
  }

  /// Finds a valid route starting from a specific [startIndex].
  static List<int>? findRouteFromStart(
    LevelModel level,
    int startIndex, {
    int maxDepth = 40,
    int maxVisitedStates = 500000,
  }) {
    final startTile = level.tiles[startIndex];
    if (!startTile.canEnter(0)) return null;

    final initialSum = startTile.applyValue(0);
    return findRouteFromCurrent(
      level: level,
      currentPath: [startIndex],
      currentSum: initialSum,
      maxDepth: maxDepth,
      maxVisitedStates: maxVisitedStates,
    );
  }

  /// Solves for a valid continuation from the current in-game path and sum.
  /// Used both for generating full solutions and for context-aware hints.
  static List<int>? findRouteFromCurrent({
    required LevelModel level,
    required List<int> currentPath,
    required int currentSum,
    Set<int>? visitedIndices,
    int maxDepth = 40,
    int maxVisitedStates = 500000,
  }) {
    if (currentPath.isEmpty) return findSolution(level);

    final n = level.gridSize;
    final target = level.targetNumber;
    final centerIndex = level.centerIndex;
    final pathIndices = currentPath.toSet();
    final visitHistory = {...?visitedIndices, ...currentPath};
    final canReduceTotal = level.tiles.any(
      (tile) => tile.isMirror || tile.isZero,
    );
    final deadStates = <(int, int, BigInt)>{};
    var visitedStateCount = 0;

    List<int>? bestRoute;

    bool isValid(int r, int c) {
      return r >= 0 && r < n && c >= 0 && c < n;
    }

    void dfs(int currentIndex, int pathSum, List<int> path) {
      if (bestRoute != null) return;
      if (pathSum > target && !canReduceTotal) return;
      if (path.length > maxDepth) return;
      if (visitedStateCount >= maxVisitedStates) return;

      final visitedSignature = visitHistory.fold(
        BigInt.zero,
        (signature, index) => signature | (BigInt.one << index),
      );
      final state = (currentIndex, pathSum, visitedSignature);
      if (!deadStates.add(state)) return;
      visitedStateCount++;

      if (currentIndex == centerIndex) {
        if (pathSum == target) {
          bestRoute = List<int>.from(path);
        }
        return;
      }

      final r = currentIndex ~/ n;
      final c = currentIndex % n;

      // Generate all legal moves, then try the most promising ones first.
      // This preserves depth-first search semantics while avoiding the huge
      // right/down/left/up branching penalty on open campaign boards.
      const directions = [
        [0, 1],
        [1, 0],
        [0, -1],
        [-1, 0],
      ];

      final candidates =
          <({int index, int newSum, int? teleportDestination, int score})>[];
      for (final dir in directions) {
        final nr = r + dir[0];
        final nc = c + dir[1];
        if (!isValid(nr, nc)) continue;

        final nextIndex = nr * n + nc;
        if (pathIndices.contains(nextIndex)) continue;

        final nextTile = level.tiles[nextIndex];
        if (!nextTile.isWalkable) continue;
        if (!level.canEnterTile(nextIndex, pathSum, visitHistory)) continue;

        final newSum = nextTile.applyValue(pathSum);
        if (newSum > target && !canReduceTotal) continue;
        final teleportDestination = nextTile.isTrampoline
            ? level.pairedTeleportIndex(nextIndex)
            : null;
        if (teleportDestination != null &&
            pathIndices.contains(teleportDestination)) {
          continue;
        }
        if (teleportDestination != null &&
            !level.canEnterTile(teleportDestination, newSum, {
              ...visitHistory,
              nextIndex,
            })) {
          continue;
        }
        final landingIndex = teleportDestination ?? nextIndex;
        if (landingIndex == centerIndex && newSum != target) continue;

        final landingRow = landingIndex ~/ n;
        final landingColumn = landingIndex % n;
        final centerRow = centerIndex ~/ n;
        final centerColumn = centerIndex % n;
        final distance =
            (landingRow - centerRow).abs() +
            (landingColumn - centerColumn).abs();
        final sumGap = (target - newSum).abs();
        final score = landingIndex == centerIndex
            ? -1
            : distance * 100 + sumGap;
        candidates.add((
          index: nextIndex,
          newSum: newSum,
          teleportDestination: teleportDestination,
          score: score,
        ));
      }

      candidates.sort((a, b) => a.score.compareTo(b.score));
      for (final candidate in candidates) {
        final nextIndex = candidate.index;
        final newSum = candidate.newSum;
        final teleportDestination = candidate.teleportDestination;
        final nextWasNew = visitHistory.add(nextIndex);
        pathIndices.add(nextIndex);
        var destinationWasNew = false;
        if (teleportDestination != null) {
          destinationWasNew = visitHistory.add(teleportDestination);
          pathIndices.add(teleportDestination);
        }
        dfs(teleportDestination ?? nextIndex, newSum, [
          ...path,
          nextIndex,
          ?teleportDestination,
        ]);
        if (teleportDestination != null) {
          pathIndices.remove(teleportDestination);
          if (destinationWasNew) visitHistory.remove(teleportDestination);
        }
        pathIndices.remove(nextIndex);
        if (nextWasNew) visitHistory.remove(nextIndex);
      }
    }

    final currentIndex = currentPath.last;
    if (currentIndex == centerIndex) {
      return currentSum == target ? currentPath : null;
    }

    dfs(currentIndex, currentSum, currentPath);
    return bestRoute;
  }

  /// Suggests the immediate next step for the player.
  /// If the player's current path is dead-end, returns null so the game can suggest backtracking.
  static int? getNextStepHint({
    required LevelModel level,
    required List<int> currentPath,
    required int currentSum,
    Set<int>? visitedIndices,
  }) {
    if (currentPath.isEmpty) {
      final sol = findSolution(level);
      return sol?.isNotEmpty == true ? sol!.first : null;
    }

    final solution = findRouteFromCurrent(
      level: level,
      currentPath: currentPath,
      currentSum: currentSum,
      visitedIndices: visitedIndices,
    );

    if (solution != null && solution.length > currentPath.length) {
      return solution[currentPath.length];
    }
    return null;
  }
}
