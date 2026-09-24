import '../models/level_model.dart';

/// Intelligent pathfinding solver and hint engine.
class PathSolver {
  /// Finds the first valid route from any of the start points to the center target.
  static List<int>? findSolution(LevelModel level) {
    for (final startPoint in level.startIndices) {
      final route = findRouteFromStart(level, startPoint);
      if (route != null) {
        return route;
      }
    }
    return null;
  }

  /// Finds a valid route starting from a specific [startIndex].
  static List<int>? findRouteFromStart(LevelModel level, int startIndex) {
    final startTile = level.tiles[startIndex];
    if (!startTile.canEnter(0)) return null;

    final initialSum = startTile.applyValue(0);
    return findRouteFromCurrent(
      level: level,
      currentPath: [startIndex],
      currentSum: initialSum,
    );
  }

  /// Solves for a valid continuation from the current in-game path and sum.
  /// Used both for generating full solutions and for context-aware hints.
  static List<int>? findRouteFromCurrent({
    required LevelModel level,
    required List<int> currentPath,
    required int currentSum,
    int maxDepth = 40,
  }) {
    if (currentPath.isEmpty) return findSolution(level);

    final n = level.gridSize;
    final target = level.targetNumber;
    final centerIndex = level.centerIndex;
    final visited = currentPath.toSet();
    final canReduceTotal = level.tiles.any(
      (tile) => tile.isMirror || tile.isZero,
    );

    List<int>? bestRoute;

    bool isValid(int r, int c) {
      return r >= 0 && r < n && c >= 0 && c < n;
    }

    void dfs(int currentIndex, int pathSum, List<int> path) {
      if (bestRoute != null) return;
      if (pathSum > target && !canReduceTotal) return;
      if (path.length > maxDepth) return;

      if (currentIndex == centerIndex) {
        if (pathSum == target) {
          bestRoute = List<int>.from(path);
        }
        return;
      }

      final r = currentIndex ~/ n;
      final c = currentIndex % n;

      // 4 orthogonal directions: right, down, left, up
      const directions = [
        [0, 1],
        [1, 0],
        [0, -1],
        [-1, 0],
      ];

      for (final dir in directions) {
        final nr = r + dir[0];
        final nc = c + dir[1];
        if (!isValid(nr, nc)) continue;

        final nextIndex = nr * n + nc;
        if (visited.contains(nextIndex)) continue;

        final nextTile = level.tiles[nextIndex];
        if (!nextTile.isWalkable) continue;
        if (!nextTile.canEnter(pathSum)) continue;

        final newSum = nextTile.applyValue(pathSum);
        final teleportDestination = nextTile.isTrampoline
            ? level.pairedTeleportIndex(nextIndex)
            : null;
        if (teleportDestination != null &&
            visited.contains(teleportDestination)) {
          continue;
        }
        visited.add(nextIndex);
        if (teleportDestination != null) visited.add(teleportDestination);
        dfs(teleportDestination ?? nextIndex, newSum, [
          ...path,
          nextIndex,
          ?teleportDestination,
        ]);
        if (teleportDestination != null) visited.remove(teleportDestination);
        visited.remove(nextIndex);
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
  }) {
    if (currentPath.isEmpty) {
      final sol = findSolution(level);
      return sol?.isNotEmpty == true ? sol!.first : null;
    }

    final solution = findRouteFromCurrent(
      level: level,
      currentPath: currentPath,
      currentSum: currentSum,
    );

    if (solution != null && solution.length > currentPath.length) {
      return solution[currentPath.length];
    }
    return null;
  }
}
