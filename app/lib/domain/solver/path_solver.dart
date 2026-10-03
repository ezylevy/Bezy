import '../models/level_model.dart';

/// Intelligent pathfinding solver and hint engine.
class PathSolver {
  static int _stableHash(String value) {
    var hash = 2166136261;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash ^ codeUnit) * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  /// Finds valid routes from as many different start gates as possible.
  ///
  /// Campaign authoring uses this to avoid repeating one corridor or its
  /// mirror across many stages. Each returned route is independently found by
  /// DFS instead of being copied from a configured solution.
  static List<List<int>> findSolutions(
    LevelModel level, {
    int limit = 3,
    bool useKnownSolutions = true,
    int maxDepth = 40,
    int maxVisitedStates = 500000,
  }) {
    if (limit <= 0) return const [];
    final routes = <List<int>>[];
    final signatures = <String>{};

    void addRoute(List<int>? route) {
      if (route == null || !_isValidConfiguredRoute(level, route)) return;
      final signature = route.join(',');
      if (signatures.add(signature)) routes.add(List<int>.from(route));
    }

    if (useKnownSolutions) {
      for (final route in level.solutionRoutes) {
        addRoute(route);
        if (routes.length >= limit) return routes;
      }
    }

    final representedStarts = routes.map((route) => route.first).toSet();
    for (final startPoint in level.startIndices) {
      if (representedStarts.contains(startPoint)) continue;
      addRoute(
        findRouteFromStart(
          level,
          startPoint,
          maxDepth: maxDepth,
          maxVisitedStates: maxVisitedStates,
        ),
      );
      if (routes.length >= limit) break;
    }
    // Some boards intentionally make only one or two gates viable. Continue
    // DFS past already found routes so the solution player still has at least
    // three genuinely different options to rotate between.
    while (routes.length < limit) {
      final before = routes.length;
      for (final startPoint in level.startIndices) {
        addRoute(
          findRouteFromStart(
            level,
            startPoint,
            maxDepth: maxDepth,
            maxVisitedStates: maxVisitedStates,
            excludedRouteSignatures: signatures,
          ),
        );
        if (routes.length >= limit) break;
      }
      if (routes.length == before) break;
    }
    return routes;
  }

  /// Counts player gestures rather than raw cells. Teleport arrival and every
  /// automatic continuation after an ice cell belong to the preceding move.
  static int countUserMoves(LevelModel level, List<int> route) {
    if (route.isEmpty) return 0;
    var moves = 1;
    for (var position = 1; position < route.length; position++) {
      final previous = level.tiles[route[position - 1]];
      final isAutomaticTeleport =
          previous.isTrampoline &&
          level.pairedTeleportIndex(route[position - 1]) == route[position];
      final isAutomaticIceContinuation = previous.isIce;
      if (!isAutomaticTeleport && !isAutomaticIceContinuation) moves++;
    }
    return moves;
  }

  /// Uses iterative deepening so the first returned route has the fewest raw
  /// cells among all start gates. It is intended for campaign authoring and
  /// par validation, not for every frame of gameplay.
  static List<int>? findShortestSolution(
    LevelModel level, {
    int maxDepth = 40,
    int maxVisitedStatesPerDepth = 500000,
  }) {
    for (var depth = 2; depth <= maxDepth; depth++) {
      final route = findSolution(
        level,
        useKnownSolutions: false,
        maxDepth: depth,
        maxVisitedStates: maxVisitedStatesPerDepth,
      );
      if (route != null) return route;
    }
    return null;
  }

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

  /// Validates a complete cached/authored solution against the real rules.
  ///
  /// Kept public so campaign regression tests can prove every displayed
  /// solution is playable instead of merely trusting generated data.
  static bool isValidSolution(LevelModel level, List<int> route) =>
      _isValidConfiguredRoute(level, route);

  /// Finds a valid route starting from a specific [startIndex].
  static List<int>? findRouteFromStart(
    LevelModel level,
    int startIndex, {
    int maxDepth = 40,
    int maxVisitedStates = 500000,
    Set<String> excludedRouteSignatures = const {},
    Set<int> requiredAnyIndices = const {},
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
      excludedRouteSignatures: excludedRouteSignatures,
      requiredAnyIndices: requiredAnyIndices,
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
    Set<String> excludedRouteSignatures = const {},
    Set<int> requiredAnyIndices = const {},
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
        if (pathSum == target &&
            (requiredAnyIndices.isEmpty ||
                path.any(requiredAnyIndices.contains))) {
          final signature = path.join(',');
          if (!excludedRouteSignatures.contains(signature)) {
            bestRoute = List<int>.from(path);
          }
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
          <({List<int> additions, int landingIndex, int newSum, int score})>[];
      for (final dir in directions) {
        final nr = r + dir[0];
        final nc = c + dir[1];
        if (!isValid(nr, nc)) continue;

        final nextIndex = nr * n + nc;
        if (pathIndices.contains(nextIndex)) continue;

        final nextTile = level.tiles[nextIndex];
        if (!nextTile.isWalkable) continue;
        if (!level.canEnterTile(nextIndex, pathSum, visitHistory)) continue;

        final additions = <int>[nextIndex];
        var landingIndex = nextIndex;
        var candidateSum = pathSum;

        // Entering ice commits the player to a straight slide. Include every
        // automatically crossed cell so hints and authored solutions match
        // the exact path that GameScreen will place on the board.
        if (nextTile.isIce) {
          final delta = nextIndex - currentIndex;
          while (level.tiles[landingIndex].isIce) {
            final slideNext = landingIndex + delta;
            final remainsOnBoard =
                slideNext >= 0 &&
                slideNext < level.tiles.length &&
                (delta.abs() != 1 || slideNext ~/ n == landingIndex ~/ n);
            if (!remainsOnBoard ||
                pathIndices.contains(slideNext) ||
                additions.contains(slideNext) ||
                !level.tiles[slideNext].isWalkable ||
                !level.canEnterTile(slideNext, candidateSum, {
                  ...visitHistory,
                  ...additions,
                })) {
              break;
            }
            additions.add(slideNext);
            landingIndex = slideNext;
          }
        }

        for (final index in additions) {
          if (index != centerIndex) {
            candidateSum = level.tiles[index].applyValue(candidateSum);
          }
        }
        if (candidateSum > target && !canReduceTotal) continue;
        final teleportDestination = nextTile.isTrampoline
            ? level.pairedTeleportIndex(nextIndex)
            : null;
        if (teleportDestination != null &&
            (pathIndices.contains(teleportDestination) ||
                additions.contains(teleportDestination))) {
          continue;
        }
        if (teleportDestination != null &&
            !level.canEnterTile(teleportDestination, candidateSum, {
              ...visitHistory,
              ...additions,
            })) {
          continue;
        }
        if (teleportDestination != null) {
          additions.add(teleportDestination);
          landingIndex = teleportDestination;
        }
        if (landingIndex == centerIndex && candidateSum != target) continue;

        final landingRow = landingIndex ~/ n;
        final landingColumn = landingIndex % n;
        final centerRow = centerIndex ~/ n;
        final centerColumn = centerIndex % n;
        final distance =
            (landingRow - centerRow).abs() +
            (landingColumn - centerColumn).abs();
        final sumGap = (target - candidateSum).abs();
        final routeSalt =
            (_stableHash(level.id) + landingIndex * 31 + path.length * 17) % 97;
        final score = landingIndex == centerIndex
            ? -1
            : distance * 10000 + sumGap * 100 + routeSalt;
        candidates.add((
          additions: additions,
          landingIndex: landingIndex,
          newSum: candidateSum,
          score: score,
        ));
      }

      candidates.sort((a, b) => a.score.compareTo(b.score));
      for (final candidate in candidates) {
        final newlyVisited = <int>[];
        for (final index in candidate.additions) {
          if (visitHistory.add(index)) newlyVisited.add(index);
          pathIndices.add(index);
        }
        dfs(candidate.landingIndex, candidate.newSum, [
          ...path,
          ...candidate.additions,
        ]);
        for (final index in candidate.additions.reversed) {
          pathIndices.remove(index);
        }
        for (final index in newlyVisited) {
          visitHistory.remove(index);
        }
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
