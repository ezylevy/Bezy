import '../models/level_model.dart';
import '../models/tile_model.dart';
import '../solver/path_solver.dart';
import 'generated_solution_routes.dart';
import 'world_info.dart';

/// Campaign levels 21-50. They are kept data-driven so their routes, timers,
/// optimum move counts, and special cells can be validated independently.
class ExtraCampaignLevels {
  static const worlds = <WorldInfo>[
    WorldInfo(
      id: 5,
      title: 'קרקס הג׳וקר',
      subtitle: 'שלבים 21-30 - מראה, ג׳וקר ומינימום צעדים',
      colorHex: 0xFFEC4899,
      iconName: 'joker',
    ),
    WorldInfo(
      id: 6,
      title: 'מערות הקרח',
      subtitle: 'שלבים 31-40 - החלקה, בחירה ו-45 שניות',
      colorHex: 0xFF22D3EE,
      iconName: 'ice',
    ),
    WorldInfo(
      id: 7,
      title: 'מסיבת המאסטרים',
      subtitle: 'שלבים 41-50 - שילוב כל המכניקות ב-30 שניות',
      colorHex: 0xFFF97316,
      iconName: 'party',
    ),
  ];

  static final levels = <LevelModel>[
    for (var i = 0; i < 10; i++) _jokerLevel(i),
    for (var i = 0; i < 10; i++) _iceLevel(i),
    for (var i = 0; i < 10; i++) _masterLevel(i),
  ];

  static const _route7Left = <int>[3, 2, 9, 8, 15, 14, 21, 28, 29, 30, 23, 24];
  static const _route7Right = <int>[
    3,
    4,
    11,
    12,
    19,
    20,
    27,
    34,
    33,
    32,
    25,
    24,
  ];
  static final _variedRouteBank7 = _buildVariedRouteBank(7);
  static final _variedRouteBank9 = _buildVariedRouteBank(9);
  static final _orientedRouteBank7 = _buildOrientedRouteBank(
    _variedRouteBank7,
    7,
  );
  static final _orientedRouteBank9 = _buildOrientedRouteBank(
    _variedRouteBank9,
    9,
  );

  static LevelModel _jokerLevel(int offset) {
    final stageNumber = 21 + offset;
    final variedRoutes = stageNumber >= 25
        ? _variedRoutesForStage(7, stageNumber)
        : null;
    final route =
        variedRoutes?.$1 ?? (offset.isEven ? _route7Left : _route7Right);
    final alternateRoute =
        variedRoutes?.$2 ?? (offset.isEven ? _route7Right : _route7Left);
    final jokerIndex = route[5];
    final specials = <int, TileType>{jokerIndex: TileType.joker};
    // Stages 21-25 teach Joker only. Stages 26-30 add one established
    // mechanic at a time instead of opening with several tutorial dialogs.
    if (offset >= 5) specials[route[4]] = TileType.mirror;
    if (offset == 5) {
      specials[_unusedInteriorIndex(route, alternateRoute, 7)] =
          TileType.lonely;
    }
    return _buildCorridorLevel(
      id: 'w5_l${offset + 1}',
      worldId: 5,
      levelNumber: offset + 1,
      worldTitle: 'קרקס הג׳וקר',
      title: const [
        'הג׳וקר הראשון',
        'שתי אפשרויות',
        'מראה וג׳וקר',
        'בחירה זריזה',
        'מסלול ההפתעה',
        'הפוך ובחר',
        'ג׳וקר כפול',
        'שכפול מצחיק',
        'הדרך החסכונית',
        'אלוף הקרקס',
      ][offset],
      description:
          'בחרו את פעולת הג׳וקר הנכונה והגיעו ליעד במספר הצעדים הקטן ביותר.',
      route: route,
      alternateRoute: offset >= 2 ? alternateRoute : null,
      openBoard: offset >= 4,
      specials: specials,
      jokerOptions: [2 + offset % 3, 5 + offset % 4],
      timerSeconds: 60,
      seed: stageNumber,
    );
  }

  static LevelModel _iceLevel(int offset) {
    final useNine = offset >= 5;
    final stageNumber = 31 + offset;
    final variedRoutes = _variedRoutesForStage(useNine ? 9 : 7, stageNumber);
    final route = variedRoutes.$1;
    final alternateRoute = variedRoutes.$2;
    final iceStart = _straightRunEntry(route);
    final specials = <int, TileType>{iceStart: TileType.ice};
    // Stages 31-35 introduce only Ice. The second group may combine it with
    // mechanics the player already learned.
    if (offset >= 5) specials[route[3]] = TileType.joker;
    if (offset >= 7) specials[route[5]] = TileType.mirror;
    return _buildCorridorLevel(
      id: 'w6_l${offset + 1}',
      worldId: 6,
      levelNumber: offset + 1,
      worldTitle: 'מערות הקרח',
      title: const [
        'החלקה ראשונה',
        'קרח מימין',
        'ג׳וקר על הקרח',
        'עצירה מדויקת',
        'מסלול קפוא',
        'מערת תשע על תשע',
        'המסלול החלקלק',
        'מראה קפואה',
        'מרוץ ארבעים וחמש',
        'מלך הקרח',
      ][offset],
      description: 'כניסה לקרח מחליקה את השחקן אוטומטית עד לתא העצירה המואר.',
      route: route,
      alternateRoute: alternateRoute,
      openBoard: true,
      specials: specials,
      jokerOptions: [3, 6 + offset % 3],
      timerSeconds: 45,
      seed: stageNumber,
    );
  }

  static LevelModel _masterLevel(int offset) {
    final stageNumber = 41 + offset;
    final variedRoutes = _variedRoutesForStage(9, stageNumber);
    final route = variedRoutes.$1;
    final alternateRoute = variedRoutes.$2;
    final iceStart = _straightRunEntry(route);
    final specials = <int, TileType>{
      route[3]: TileType.joker,
      route[5]: offset % 3 == 0 ? TileType.zero : TileType.mirror,
      iceStart: TileType.ice,
    };
    if (offset >= 4) {
      final clonePosition = route.length > 12 ? 11 : route.length - 2;
      specials[route[clonePosition]] = TileType.clone;
    }
    return _buildCorridorLevel(
      id: 'w7_l${offset + 1}',
      worldId: 7,
      levelNumber: offset + 1,
      worldTitle: 'מסיבת המאסטרים',
      title: const [
        'שלושים שניות',
        'מסיבת המראה',
        'אפס על הקרח',
        'בחירת האלופים',
        'שכפול במהירות',
        'המסלול הגדול',
        'חגיגת הג׳וקר',
        'סערת מספרים',
        'כמעט אלוף',
        'מסיבת הסיום',
      ][offset],
      description:
          'שלבו ג׳וקר, קרח ומכניקות מאסטר והגיעו ליעד לפני שהזמן נגמר.',
      route: route,
      alternateRoute: alternateRoute,
      openBoard: true,
      specials: specials,
      jokerOptions: [2 + offset % 3, 7 + offset % 3],
      timerSeconds: 30,
      seed: stageNumber,
    );
  }

  static LevelModel _buildCorridorLevel({
    required String id,
    required int worldId,
    required int levelNumber,
    required String worldTitle,
    required String title,
    required String description,
    required List<int> route,
    List<int>? alternateRoute,
    bool openBoard = false,
    required Map<int, TileType> specials,
    required List<int> jokerOptions,
    required int timerSeconds,
    required int seed,
  }) {
    final gridSize = route.last == 24 ? 7 : 9;
    final center = gridSize * gridSize ~/ 2;
    assert(route.last == center);
    assert(alternateRoute == null || alternateRoute.last == center);
    final authoredRoutes = <List<int>>[route, ?alternateRoute];
    if (seed >= 25) {
      final oppositeGateRoute = route
          .map((index) => gridSize * gridSize - 1 - index)
          .toList(growable: false);
      if (!authoredRoutes.any(
        (candidate) => _sameRoute(candidate, oppositeGateRoute),
      )) {
        authoredRoutes.add(oppositeGateRoute);
      }
    }
    final effectiveSpecials = Map<int, TileType>.from(specials);
    for (final authoredRoute in authoredRoutes.skip(1)) {
      for (final entry in specials.entries) {
        final position = route.indexOf(entry.key);
        if (position > 0 && position < authoredRoute.length - 1) {
          effectiveSpecials[authoredRoute[position]] = entry.value;
        }
      }
    }
    final routeSet = authoredRoutes.expand((route) => route).toSet();
    final centerNeighbors = <int>{
      center - gridSize,
      center + gridSize,
      center - 1,
      center + 1,
    };
    final startIndices = alternateRoute == null
        ? <int>{route.first}
        : LevelModel.calculateDefaultStartPoints(
            gridSize,
          ).where((index) => !effectiveSpecials.containsKey(index)).toSet();
    final walkableIndices = openBoard
        ? Set<int>.from(
            List<int>.generate(gridSize * gridSize, (index) => index),
          )
        : <int>{...routeSet, ...centerNeighbors, ...startIndices};
    final values = <int, int>{};
    final clonePosition = route.indexWhere(
      (index) => effectiveSpecials[index] == TileType.clone,
    );
    final combinesMirrorAndClone =
        clonePosition >= 0 && effectiveSpecials.containsValue(TileType.mirror);
    final hasMirrorWithoutClone =
        clonePosition < 0 && effectiveSpecials.containsValue(TileType.mirror);
    var sum = 0;
    for (var position = 0; position < route.length - 1; position++) {
      final index = route[position];
      final type = effectiveSpecials[index];
      // Alternate 0 and 1. Besides putting the ordinary zero artwork
      // into the challenge boards, the smaller inputs keep Mirror and Clone
      // targets within the supplied 8-88 result-art range.
      final value = combinesMirrorAndClone && position < clonePosition
          ? 0
          : openBoard
          ? hasMirrorWithoutClone
                ? (seed + position) % 2
                : (seed + position) % 3 + 4
          : (seed + position) % 2;
      values[index] = type == null ? value : 0;
      switch (type) {
        case TileType.mirror:
          if (sum.abs() < 10) {
            sum *= 10;
          } else {
            final sign = sum < 0 ? -1 : 1;
            final reversed = sum.abs().toString().split('').reversed.join();
            sum = sign * int.parse(reversed);
          }
          break;
        case TileType.clone:
          sum *= 2;
          break;
        case TileType.zero:
          sum = 0;
          break;
        case TileType.joker:
          sum += jokerOptions.first;
          break;
        case TileType.ice:
          break;
        default:
          sum += value;
          break;
      }
    }
    if (sum < 8) {
      final lastNumberIndex = route
          .take(route.length - 1)
          .lastWhere((index) => specials[index] == null);
      final increase = 8 - sum;
      values[lastNumberIndex] = values[lastNumberIndex]! + increase;
      sum = 8;
    }
    while (sum > 88) {
      var adjusted = false;
      for (final index in route.take(route.length - 1).toList().reversed) {
        if (effectiveSpecials[index] == null && (values[index] ?? 0) > 0) {
          values[index] = values[index]! - 1;
          sum = _routeTotal(route, values, effectiveSpecials, jokerOptions);
          adjusted = true;
          break;
        }
      }
      if (!adjusted) break;
    }
    for (final authoredRoute in authoredRoutes.skip(1)) {
      for (var position = 0; position < authoredRoute.length - 1; position++) {
        final primaryIndex = route[position];
        final alternateIndex = authoredRoute[position];
        if (!route.contains(alternateIndex)) {
          values[alternateIndex] = values[primaryIndex] ?? 0;
        }
      }
    }

    final tiles = List<TileModel>.generate(gridSize * gridSize, (index) {
      final row = index ~/ gridSize;
      final col = index % gridSize;
      if (index == center) {
        return TileModel(
          index: index,
          row: row,
          col: col,
          type: TileType.target,
          value: sum,
        );
      }
      if (!walkableIndices.contains(index)) {
        return TileModel(index: index, row: row, col: col, type: TileType.wall);
      }
      if (startIndices.contains(index)) {
        return TileModel(
          index: index,
          row: row,
          col: col,
          type: TileType.start,
          value: values[index] ?? (seed + index) % 5 + 1,
        );
      }
      final type = effectiveSpecials[index] ?? TileType.number;
      return TileModel(
        index: index,
        row: row,
        col: col,
        type: type,
        value:
            values[index] ??
            (openBoard ? (seed + index) % 5 + 5 : (seed + index) % 4 + 1),
        metadata: type == TileType.joker ? {'options': jokerOptions} : const {},
      );
    });

    final authoredOptimalMoves = _countUserMoves(route, effectiveSpecials);
    final authoredLevel = LevelModel(
      id: id,
      worldId: worldId,
      levelNumber: levelNumber,
      worldTitle: worldTitle,
      title: title,
      gridSize: gridSize,
      targetNumber: sum,
      tiles: tiles,
      parMoves: authoredOptimalMoves,
      optimalMoves: authoredOptimalMoves,
      challengeTimeSeconds: timerSeconds,
      description: description,
      hints: const [],
      solutionRoutes: authoredRoutes,
    );

    if (seed < 25) return authoredLevel;

    final cachedRoutes = generatedCampaignRoutes[id] ?? authoredRoutes;
    final cachedOptimal = generatedOptimalMoves[id];
    final actualOptimalMoves =
        cachedOptimal ??
        cachedRoutes
            .map((route) => PathSolver.countUserMoves(authoredLevel, route))
            .reduce((a, b) => a < b ? a : b);

    return authoredLevel.copyWith(
      parMoves: actualOptimalMoves,
      optimalMoves: actualOptimalMoves,
      solutionRoutes: cachedRoutes,
    );
  }

  /// Produces many compact, non-corridor geometries in the top wedge of an
  /// odd board. Rotating one route gives three non-overlapping, equally valid
  /// solutions whose number/special-cell sequence remains identical.
  static List<List<int>> _buildVariedRouteBank(int gridSize) {
    final center = gridSize ~/ 2;
    final target = center * gridSize + center;
    final start = center;
    final allowed = <int>{target};
    for (var row = 0; row < center; row++) {
      final radius = center - row;
      for (var column = center - radius; column <= center + radius; column++) {
        allowed.add(row * gridSize + column);
      }
    }

    final routes = <List<int>>[];
    final path = <int>[start];
    final visited = <int>{start};
    final minimumLength = gridSize == 7 ? 7 : 11;

    void search(int current) {
      if (routes.length >= 32) return;
      if (current == target) {
        if (path.length >= minimumLength) {
          final candidate = List<int>.from(path);
          final rotated = _rotateRoute(candidate, gridSize, 1);
          final compatible = candidate.every((index) {
            final rotatedPosition = rotated.indexOf(index);
            return rotatedPosition == -1 ||
                rotatedPosition == candidate.indexOf(index);
          });
          if (compatible) routes.add(candidate);
        }
        return;
      }
      final row = current ~/ gridSize;
      final column = current % gridSize;
      final neighbors = <int>[
        if (column + 1 < gridSize) current + 1,
        if (row + 1 < gridSize) current + gridSize,
        if (column > 0) current - 1,
        if (row > 0) current - gridSize,
      ];
      for (final next in neighbors) {
        if (!allowed.contains(next) || !visited.add(next)) continue;
        path.add(next);
        search(next);
        path.removeLast();
        visited.remove(next);
      }
    }

    search(start);
    if (routes.length < 2) {
      throw StateError('Could not build varied $gridSize x $gridSize routes.');
    }
    return routes;
  }

  static (List<int>, List<int>) _variedRoutesForStage(
    int gridSize,
    int stageNumber,
  ) {
    final bank = gridSize == 7 ? _orientedRouteBank7 : _orientedRouteBank9;
    final ordinal = gridSize == 7 ? stageNumber - 25 : stageNumber - 36;
    final primary = bank[ordinal % bank.length];
    final alternate = _rotateRoute(primary, gridSize, 1);
    return (primary, alternate);
  }

  static List<List<int>> _buildOrientedRouteBank(
    List<List<int>> baseRoutes,
    int gridSize,
  ) {
    final result = <List<int>>[];
    for (final base in baseRoutes) {
      for (var orientation = 0; orientation < 8; orientation++) {
        final reflected = orientation >= 4
            ? base
                  .map((index) {
                    final row = index ~/ gridSize;
                    final column = index % gridSize;
                    return row * gridSize + (gridSize - 1 - column);
                  })
                  .toList(growable: false)
            : base;
        final candidate = _rotateRoute(reflected, gridSize, orientation % 4);
        if (!result.any((route) => _sameRoute(route, candidate))) {
          result.add(candidate);
        }
      }
    }
    return result;
  }

  static List<int> _rotateRoute(
    List<int> route,
    int gridSize,
    int quarterTurns,
  ) {
    var result = List<int>.from(route);
    for (var turn = 0; turn < quarterTurns % 4; turn++) {
      result = result
          .map((index) {
            final row = index ~/ gridSize;
            final column = index % gridSize;
            return column * gridSize + (gridSize - 1 - row);
          })
          .toList(growable: false);
    }
    return result;
  }

  static int _straightRunEntry(List<int> route) {
    for (var position = 1; position < route.length - 1; position++) {
      if (route[position] - route[position - 1] ==
          route[position + 1] - route[position]) {
        return route[position];
      }
    }
    throw StateError('Ice route has no straight continuation.');
  }

  static int _unusedInteriorIndex(
    List<int> primary,
    List<int> alternate,
    int gridSize,
  ) {
    final occupied = <int>{
      ...primary,
      ...alternate,
      ..._rotateRoute(primary, gridSize, 2),
      ...LevelModel.calculateDefaultStartPoints(gridSize),
      gridSize * gridSize ~/ 2,
    };
    for (var row = 1; row < gridSize - 1; row++) {
      for (var column = 1; column < gridSize - 1; column++) {
        final index = row * gridSize + column;
        if (!occupied.contains(index)) return index;
      }
    }
    throw StateError('No unused interior cell is available.');
  }

  static bool _sameRoute(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  static int _routeTotal(
    List<int> route,
    Map<int, int> values,
    Map<int, TileType> specials,
    List<int> jokerOptions,
  ) {
    var sum = 0;
    for (final index in route.take(route.length - 1)) {
      switch (specials[index]) {
        case TileType.mirror:
          if (sum.abs() < 10) {
            sum *= 10;
          } else {
            final sign = sum < 0 ? -1 : 1;
            final reversed = sum.abs().toString().split('').reversed.join();
            sum = sign * int.parse(reversed);
          }
          break;
        case TileType.clone:
          sum *= 2;
          break;
        case TileType.zero:
          sum = 0;
          break;
        case TileType.joker:
          sum += jokerOptions.first;
          break;
        case TileType.ice:
        case TileType.blackHole:
        case TileType.bomb:
        case TileType.trampoline:
          break;
        default:
          sum += values[index] ?? 0;
          break;
      }
    }
    return sum;
  }

  static int _countUserMoves(List<int> route, Map<int, TileType> specials) {
    var moves = 1;
    var position = 1;
    while (position < route.length) {
      moves++;
      if (specials[route[position]] == TileType.ice) {
        final previous = route[position - 1];
        final delta = route[position] - previous;
        while (position + 1 < route.length &&
            route[position + 1] - route[position] == delta &&
            specials[route[position]] == TileType.ice) {
          position++;
        }
      }
      position++;
    }
    return moves;
  }
}
