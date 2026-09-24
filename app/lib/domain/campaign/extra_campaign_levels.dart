import '../models/level_model.dart';
import '../models/tile_model.dart';
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
  static const _route9Left = <int>[
    4,
    3,
    12,
    11,
    20,
    19,
    28,
    27,
    36,
    45,
    46,
    47,
    38,
    39,
    40,
  ];
  static const _route9Right = <int>[
    4,
    5,
    14,
    15,
    24,
    25,
    34,
    35,
    44,
    53,
    52,
    51,
    42,
    41,
    40,
  ];

  static LevelModel _jokerLevel(int offset) {
    final route = offset.isEven ? _route7Left : _route7Right;
    final jokerIndex = route[6];
    final specials = <int, TileType>{jokerIndex: TileType.joker};
    if (offset >= 2) specials[route[4]] = TileType.mirror;
    if (offset >= 7) specials[route[8]] = TileType.clone;
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
      specials: specials,
      jokerOptions: [2 + offset % 3, 5 + offset % 4],
      timerSeconds: 60,
      seed: 21 + offset,
    );
  }

  static LevelModel _iceLevel(int offset) {
    final useNine = offset >= 5;
    final route = useNine
        ? (offset.isEven ? _route9Left : _route9Right)
        : (offset.isEven ? _route7Left : _route7Right);
    final iceStart = useNine
        ? (offset.isEven ? 36 : 44)
        : (offset.isEven ? 21 : 27);
    final specials = <int, TileType>{iceStart: TileType.ice};
    if (offset >= 2) specials[route[3]] = TileType.joker;
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
      specials: specials,
      jokerOptions: [3, 6 + offset % 3],
      timerSeconds: 45,
      seed: 31 + offset,
    );
  }

  static LevelModel _masterLevel(int offset) {
    final route = offset.isEven ? _route9Left : _route9Right;
    final iceStart = offset.isEven ? 36 : 44;
    final specials = <int, TileType>{
      route[3]: TileType.joker,
      route[5]: offset % 3 == 0 ? TileType.zero : TileType.mirror,
      iceStart: TileType.ice,
    };
    if (offset >= 4) specials[route[11]] = TileType.clone;
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
      specials: specials,
      jokerOptions: [2 + offset % 3, 7 + offset % 3],
      timerSeconds: 30,
      seed: 41 + offset,
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
    required Map<int, TileType> specials,
    required List<int> jokerOptions,
    required int timerSeconds,
    required int seed,
  }) {
    final gridSize = route.last == 24 ? 7 : 9;
    final center = gridSize * gridSize ~/ 2;
    assert(route.last == center);
    final routeSet = route.toSet();
    final values = <int, int>{};
    final clonePosition = route.indexWhere(
      (index) => specials[index] == TileType.clone,
    );
    final combinesMirrorAndClone =
        clonePosition >= 0 && specials.containsValue(TileType.mirror);
    var sum = 0;
    for (var position = 0; position < route.length - 1; position++) {
      final index = route[position];
      final type = specials[index];
      // Alternate 0 and 1. Besides putting the ordinary zero artwork
      // into the challenge boards, the smaller inputs keep Mirror and Clone
      // targets within the supplied 8-88 result-art range.
      final value = combinesMirrorAndClone && position < clonePosition
          ? 0
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
      if (!routeSet.contains(index)) {
        return TileModel(index: index, row: row, col: col, type: TileType.wall);
      }
      if (index == route.first) {
        return TileModel(
          index: index,
          row: row,
          col: col,
          type: TileType.start,
          value: values[index]!,
        );
      }
      final type = specials[index] ?? TileType.number;
      return TileModel(
        index: index,
        row: row,
        col: col,
        type: type,
        value: values[index] ?? 0,
        metadata: type == TileType.joker ? {'options': jokerOptions} : const {},
      );
    });

    final optimalMoves = _countUserMoves(route, specials);
    return LevelModel(
      id: id,
      worldId: worldId,
      levelNumber: levelNumber,
      worldTitle: worldTitle,
      title: title,
      gridSize: gridSize,
      targetNumber: sum,
      tiles: tiles,
      parMoves: optimalMoves,
      optimalMoves: optimalMoves,
      challengeTimeSeconds: timerSeconds,
      description: description,
      hints: const [],
    );
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
