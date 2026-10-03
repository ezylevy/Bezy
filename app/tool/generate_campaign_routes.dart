import 'dart:io';

import 'package:bezy/domain/campaign/campaign_levels.dart';
import 'package:bezy/domain/solver/path_solver.dart';

Future<void> main() async {
  final buffer = StringBuffer()
    ..writeln(
      '// GENERATED FILE. Run: flutter test tool/generate_campaign_routes_test.dart',
    )
    ..writeln(
      '// Routes were discovered by DFS and are cached for instant startup.',
    )
    ..writeln('const generatedOptimalMoves = <String, int>{');

  final levels = CampaignLevels.getAllLevels();
  final generatedRoutes = <String, List<List<int>>>{};
  final primarySignatures = <String>{};
  int? previousPrimaryStart;

  for (var stageIndex = 24; stageIndex < levels.length; stageIndex++) {
    final level = levels[stageIndex];
    final stageNumber = stageIndex + 1;
    final searchLevel = level.copyWith(solutionRoutes: const []);
    final gates = level.solutionRoutes
        .map((route) => route.first)
        .toSet()
        .toList(growable: false);
    final searchDepth = level.solutionRoutes
        .map((route) => route.length)
        .reduce((a, b) => a > b ? a : b);
    final preferredOffset = (stageNumber - 25) % gates.length;
    final orderedGates = <int>[
      ...gates.skip(preferredOffset),
      ...gates.take(preferredOffset),
    ];
    orderedGates.sort((a, b) {
      if (a == previousPrimaryStart) return 1;
      if (b == previousPrimaryStart) return -1;
      return 0;
    });

    stdout.writeln('DFS stage $stageNumber (${level.id}) by entry gate...');
    final routes = <List<int>>[];
    final requiredSpecialIndices = searchLevel.tiles
        .where(
          (tile) =>
              tile.isJoker ||
              tile.isIce ||
              tile.isMirror ||
              tile.isClone ||
              tile.isZero ||
              tile.isBlackHole ||
              tile.isBomb ||
              tile.isTrampoline,
        )
        .map((tile) => tile.index)
        .toSet();
    for (final gate in orderedGates) {
      final primaryRoute = PathSolver.findRouteFromStart(
        searchLevel,
        gate,
        maxDepth: searchDepth,
        maxVisitedStates: 1000000,
        excludedRouteSignatures: primarySignatures,
        requiredAnyIndices: requiredSpecialIndices,
      );
      if (primaryRoute == null) continue;
      routes.add(primaryRoute);
      break;
    }
    // Prefer showcasing the stage mechanic, but keep generation possible when
    // every mechanic-using route would duplicate an earlier primary route.
    if (routes.isEmpty) {
      for (final gate in orderedGates) {
        final primaryRoute = PathSolver.findRouteFromStart(
          searchLevel,
          gate,
          maxDepth: searchDepth,
          maxVisitedStates: 1000000,
          excludedRouteSignatures: primarySignatures,
        );
        if (primaryRoute == null) continue;
        routes.add(primaryRoute);
        break;
      }
    }
    if (routes.isEmpty) {
      throw StateError('Stage $stageNumber has no unique DFS route.');
    }

    final localSignatures = <String>{routes.first.join(',')};
    for (final gate in orderedGates) {
      if (gate == routes.first.first) continue;
      final alternateRoute = PathSolver.findRouteFromStart(
        searchLevel,
        gate,
        maxDepth: searchDepth,
        maxVisitedStates: 1000000,
        excludedRouteSignatures: localSignatures,
      );
      if (alternateRoute == null) continue;
      routes.add(alternateRoute);
      localSignatures.add(alternateRoute.join(','));
      if (routes.length == 3) break;
    }
    if (routes.length < 3 ||
        routes.map((route) => route.first).toSet().length < 3) {
      throw StateError(
        'Stage $stageNumber needs three DFS routes from different gates; '
        'found ${routes.length}.',
      );
    }
    if (routes.first.first == previousPrimaryStart) {
      throw StateError('Stage $stageNumber repeated the previous entry gate.');
    }
    previousPrimaryStart = routes.first.first;
    primarySignatures.add(routes.first.join(','));
    generatedRoutes[level.id] = routes;

    stdout.writeln('Shortest stage $stageNumber (${level.id})...');
    final shortest = PathSolver.findShortestSolution(
      searchLevel,
      maxDepth: level.solutionRoutes
          .map((route) => route.length)
          .reduce((a, b) => a < b ? a : b),
      maxVisitedStatesPerDepth: 2000000,
    );
    if (shortest == null) {
      throw StateError(
        'Stage $stageNumber has no independently discovered route.',
      );
    }
    final moves = PathSolver.countUserMoves(level, shortest);
    buffer.writeln("  '${level.id}': $moves,");
  }
  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('const generatedCampaignRoutes = <String, List<List<int>>>{');

  for (var stageIndex = 19; stageIndex < levels.length; stageIndex++) {
    final level = levels[stageIndex];
    final routes = stageIndex >= 24
        ? generatedRoutes[level.id]!
        : level.solutionRoutes.take(1).toList(growable: false);
    if (stageIndex >= 24 && routes.length < 3) {
      throw StateError('Stage ${stageIndex + 1} needs three routes.');
    }
    for (final route in routes) {
      if (!PathSolver.isValidSolution(level, route)) {
        throw StateError('Stage ${stageIndex + 1} has an invalid route.');
      }
    }
    buffer.writeln("  '${level.id}': <List<int>>[");
    for (final route in routes) {
      buffer.writeln('    <int>[${route.join(', ')}],');
    }
    buffer.writeln('  ],');
  }
  buffer.writeln('};');

  final output = File('lib/domain/campaign/generated_solution_routes.dart');
  await output.writeAsString(buffer.toString());
  stdout.writeln('Wrote ${output.path}');
}
