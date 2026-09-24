import 'dart:math';

import '../models/level_model.dart';
import '../models/tile_model.dart';
import 'extra_campaign_levels.dart';
import 'world_info.dart';

export 'world_info.dart';

/// Predefined campaign worlds and levels with rich progressive challenges.
class CampaignLevels {
  static List<WorldInfo> worlds = [
    const WorldInfo(
      id: 1,
      title: 'טירונות מספרים',
      subtitle: 'לוחות 3x3 - היכרות עם חוקי החיבור',
      colorHex: 0xFF10B981, // Emerald Green
      iconName: 'school',
    ),
    const WorldInfo(
      id: 2,
      title: 'עולם החומות',
      subtitle: 'לוחות 5x5 - עקיפת מכשולים וחומות אבן',
      colorHex: 0xFF3B82F6, // Ocean Blue
      iconName: 'shield',
    ),
    const WorldInfo(
      id: 3,
      title: 'מקפצות ושערים',
      subtitle: 'לוחות 5x5 ו-7x7 - שערי חישוב ומקפצות זינוק',
      colorHex: 0xFF8B5CF6, // Purple
      iconName: 'bolt',
    ),
    const WorldInfo(
      id: 4,
      title: 'מאסטר החיבור',
      subtitle: 'לוחות 7x7 ו-9x9 - תאי מראה, שכפול והפתעה',
      colorHex: 0xFFF59E0B, // Amber Gold
      iconName: 'emoji_events',
    ),
    ...ExtraCampaignLevels.worlds,
  ];

  static List<LevelModel> getAllLevels() {
    return [
      ..._world1Levels,
      ..._world2Levels,
      ..._world3Levels,
      ..._world4Levels,
      ...ExtraCampaignLevels.levels,
    ];
  }

  static List<LevelModel> getLevelsForWorld(int worldId) {
    return getAllLevels().where((lvl) => lvl.worldId == worldId).toList();
  }

  // ==========================================
  // WORLD 1: טירונות מספרים (3x3)
  // ==========================================
  static final List<LevelModel> _world1Levels = [
    // 1-1: צעד ראשון
    _createLevel(
      id: 'w1_l1',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'טירונות מספרים',
      title: 'צעד ראשון',
      gridSize: 3,
      targetNumber: 10,
      parMoves: 4,
      description:
          'התחילו מאחת ממשבצות ההתחלה בירוק והגיעו למרכז עם סכום של 10 בדיוק!',
      hints: ['חפשו התחלה מלמטה', 'התחילו ב-3, המשיכו לפינה ולימין'],
      values: [2, 4, 1, 3, 10, 4, 1, 3, 3],
      startIndices: [1, 3, 5, 7],
    ),

    // 1-2: המסלול המתפתל
    _createLevel(
      id: 'w1_l2',
      worldId: 1,
      levelNumber: 2,
      worldTitle: 'טירונות מספרים',
      title: 'המסלול המתפתל',
      gridSize: 3,
      targetNumber: 14,
      parMoves: 4,
      description: 'לפעמים הדרך הישירה אינה מספיקה וצריך לבצע פנייה.',
      hints: ['התחילו משער שמאל (ערך 5)', 'רדו לפינה התחתונה ופנו למרכז'],
      values: [2, 3, 1, 5, 14, 4, 4, 5, 2],
      startIndices: [1, 3, 5, 7],
    ),

    // 1-3: בחירת שער
    _createLevel(
      id: 'w1_l3',
      worldId: 1,
      levelNumber: 3,
      worldTitle: 'טירונות מספרים',
      title: 'בחירת שער',
      gridSize: 3,
      targetNumber: 18,
      parMoves: 6,
      description: 'לכל אחד מארבעת שערי הכניסה סכום פתיחה אחר.',
      hints: ['התחילו מהשער העליון (ערך 4)', 'עשו סיבוב דרך הפינה הימנית'],
      values: [2, 4, 3, 3, 18, 4, 1, 4, 3],
      startIndices: [1, 3, 5, 7],
    ),

    // 1-4: דיוק מתמטי
    _createLevel(
      id: 'w1_l4',
      worldId: 1,
      levelNumber: 4,
      worldTitle: 'טירונות מספרים',
      title: 'דיוק מתמטי',
      gridSize: 3,
      targetNumber: 15,
      parMoves: 4,
      description: 'שימו לב להפרש שנשאר לכם לסכום המבוקש.',
      hints: ['בדקו את הדרך דרך הפינה הימנית העליונה'],
      values: [3, 5, 4, 2, 15, 6, 1, 4, 3],
      startIndices: [1, 3, 5, 7],
    ),

    // 1-5: סיום הטירונות
    _createLevel(
      id: 'w1_l5',
      worldId: 1,
      levelNumber: 5,
      worldTitle: 'טירונות מספרים',
      title: 'סיום הטירונות',
      gridSize: 3,
      targetNumber: 22,
      parMoves: 5,
      description: 'מבחן הסיום של לוחות 3x3! עליכם לתכנן את כל המסלול מראש.',
      hints: ['עברו כמעט על כל הלוח לפני הכניסה למרכז'],
      values: [7, 4, 5, 3, 22, 6, 4, 5, 2],
      startIndices: [1, 3, 5, 7],
    ),
  ];

  // ==========================================
  // WORLD 2: עולם החומות (5x5)
  // ==========================================
  static final List<LevelModel> _world2Levels = [
    // 2-1: חומת אבן ראשונה
    _createLevelWithModifiers(
      id: 'w2_l1',
      worldId: 2,
      levelNumber: 1,
      worldTitle: 'עולם החומות',
      title: 'חומת אבן ראשונה',
      gridSize: 5,
      targetNumber: 24,
      parMoves: 5,
      description: 'החומות חוסמות את המעבר! אי אפשר לעבור דרכן.',
      wallIndices: [7], // Block straight path from top
      values: [
        2, 4, 3, 1, 5,
        3, 1, 0, 4, 2, // 7 is wall
        2, 5, 24, 3, 4, // 12 is center
        4, 2, 6, 1, 3,
        1, 3, 5, 2, 4,
      ],
    ),

    // 2-2: המעקף הכפול
    _createLevelWithModifiers(
      id: 'w2_l2',
      worldId: 2,
      levelNumber: 2,
      worldTitle: 'עולם החומות',
      title: 'המעקף הכפול',
      gridSize: 5,
      targetNumber: 28,
      parMoves: 6,
      description: 'שתי חומות סוגרות את המעברים המרכזיים.',
      wallIndices: [6, 18],
      values: [
        3,
        2,
        5,
        4,
        1,
        2,
        0,
        4,
        3,
        5,
        4,
        3,
        28,
        2,
        6,
        1,
        5,
        4,
        0,
        2,
        3,
        4,
        2,
        5,
        1,
      ],
    ),

    // 2-3: מבצר המספרים
    _createLevelWithModifiers(
      id: 'w2_l3',
      worldId: 2,
      levelNumber: 3,
      worldTitle: 'עולם החומות',
      title: 'מבצר המספרים',
      gridSize: 5,
      targetNumber: 31,
      parMoves: 7,
      description: 'שלוש חומות יוצרות מבוך שדורש תכנון מעמיק.',
      wallIndices: [7, 11, 17],
      values: [
        1,
        5,
        4,
        2,
        3,
        4,
        2,
        0,
        5,
        1,
        3,
        0,
        31,
        4,
        2,
        2,
        4,
        0,
        3,
        5,
        5,
        2,
        3,
        4,
        1,
      ],
    ),

    // 2-4: מסדרון צר
    _createLevelWithModifiers(
      id: 'w2_l4',
      worldId: 2,
      levelNumber: 4,
      worldTitle: 'עולם החומות',
      title: 'מסדרון צר',
      gridSize: 5,
      targetNumber: 35,
      parMoves: 8,
      description: 'הדרך למרכז עוברת במסדרונות מפותלים בלבד.',
      wallIndices: [8, 13, 16, 17],
      values: [
        4,
        3,
        6,
        2,
        1,
        2,
        5,
        3,
        0,
        4,
        1,
        4,
        35,
        0,
        5,
        3,
        0,
        0,
        4,
        2,
        2,
        5,
        4,
        3,
        6,
      ],
    ),

    // 2-5: מלכודת החומות
    _createLevelWithModifiers(
      id: 'w2_l5',
      worldId: 2,
      levelNumber: 5,
      worldTitle: 'עולם החומות',
      title: 'מלכודת החומות',
      gridSize: 5,
      targetNumber: 42,
      parMoves: 9,
      description: 'סיום עולם החומות! עליכם לאסוף סכום גבוה במיוחד.',
      wallIndices: [6, 8, 16, 18],
      values: [
        5,
        4,
        7,
        3,
        6,
        3,
        0,
        5,
        0,
        4,
        6,
        5,
        42,
        6,
        3,
        2,
        0,
        7,
        0,
        5,
        4,
        6,
        5,
        4,
        2,
      ],
    ),
  ];

  // ==========================================
  // WORLD 3: מקפצות ושערים (5x5 & 7x7)
  // ==========================================
  static final List<LevelModel> _world3Levels = [
    // 3-1: זינוק המקפצה
    _createLevelWithModifiers(
      id: 'w3_l1',
      worldId: 3,
      levelNumber: 1,
      worldTitle: 'מקפצות ושערים',
      title: 'זינוק המקפצה',
      gridSize: 5,
      targetNumber: 27,
      parMoves: 5,
      description: 'כניסה לדלת אחת מעבירה מיד לדלת השנייה בלי לשנות את הסכום.',
      trampolineIndices: [13, 16],
      values: [
        2,
        3,
        4,
        1,
        5,
        4,
        2,
        5,
        3,
        2,
        3,
        6,
        27,
        4,
        1,
        1,
        5,
        2,
        4,
        3,
        4,
        2,
        3,
        5,
        2,
      ],
    ),

    // 3-2: שער החוכמה הזוגי
    _createLevelWithModifiers(
      id: 'w3_l2',
      worldId: 3,
      levelNumber: 2,
      worldTitle: 'מקפצות ושערים',
      title: 'שער החוכמה הזוגי',
      gridSize: 5,
      targetNumber: 30,
      parMoves: 6,
      description: 'השער הסגול נפתח רק אם הסכום שלכם זוגי בעת הכניסה אליו!',
      smartGateIndices: [7],
      values: [
        1, 4, 3, 2, 5,
        3, 2, 4, 1, 4, // 7 is gate
        5, 3, 30, 4, 2,
        2, 4, 5, 3, 1,
        4, 1, 2, 5, 3,
      ],
    ),

    // 3-3: קפיצה מעל החומה
    _createLevelWithModifiers(
      id: 'w3_l3',
      worldId: 3,
      levelNumber: 3,
      worldTitle: 'מקפצות ושערים',
      title: 'קפיצה מעל החומה',
      gridSize: 5,
      targetNumber: 33,
      parMoves: 6,
      description: 'שילוב של חומות וזוג דלתות שמעבירות את השחקן ביניהן.',
      wallIndices: [8, 16],
      trampolineIndices: [6, 18],
      values: [
        3,
        5,
        2,
        4,
        1,
        2,
        3,
        4,
        0,
        5,
        4,
        2,
        33,
        5,
        2,
        1,
        0,
        3,
        4,
        3,
        5,
        3,
        4,
        2,
        1,
      ],
    ),

    // 3-4: מבוך השערים
    _createLevelWithModifiers(
      id: 'w3_l4',
      worldId: 3,
      levelNumber: 4,
      worldTitle: 'מקפצות ושערים',
      title: 'מבוך השערים',
      gridSize: 5,
      targetNumber: 36,
      parMoves: 7,
      description: 'שני שערים חכמים וחומות המאתגרות את המסלול.',
      wallIndices: [11, 17],
      smartGateIndices: [7, 13],
      values: [
        4,
        2,
        5,
        3,
        1,
        3,
        4,
        3,
        2,
        5,
        2,
        0,
        36,
        4,
        2,
        5,
        3,
        0,
        4,
        1,
        1,
        4,
        2,
        5,
        3,
      ],
    ),

    // 3-5: סופר מקפצה 7x7
    _createLevelWithModifiers(
      id: 'w3_l5',
      worldId: 3,
      levelNumber: 5,
      worldTitle: 'מקפצות ושערים',
      title: 'סופר מקפצה 7x7',
      gridSize: 7,
      targetNumber: 45,
      parMoves: 8,
      description: 'לוח 7x7 מרווח עם מספר מקפצות ושערי חוכמה!',
      wallIndices: [17, 31],
      trampolineIndices: [10, 38],
      smartGateIndices: [18, 30],
      values: List.generate(49, (i) {
        if (i == 24) return 45; // center
        return (i % 6) + 1;
      }),
    ),
  ];

  // ==========================================
  // WORLD 4: מאסטר החיבור (7x7 & 9x9)
  // ==========================================
  static final List<LevelModel> _world4Levels = [
    // 4-1: מבוך המראה
    _createLevelWithModifiers(
      id: 'w4_l1',
      worldId: 4,
      levelNumber: 1,
      worldTitle: 'מאסטר החיבור',
      title: 'מבוך המראה 7x7',
      gridSize: 7,
      targetNumber: 52,
      parMoves: 9,
      description: 'תא המראה הופך את סדר הספרות של הסכום הנוכחי.',
      wallIndices: [9, 11, 37, 39],
      mirrorIndices: [18],
      values: List.generate(49, (i) {
        if (i == 24) return 52;
        return (i * 3 + 2) % 9;
      }),
    ),

    // 4-2: מעבדת השכפול
    _createLevelWithModifiers(
      id: 'w4_l2',
      worldId: 4,
      levelNumber: 2,
      worldTitle: 'מאסטר החיבור',
      title: 'מעבדת השכפול',
      gridSize: 7,
      targetNumber: 56,
      parMoves: 10,
      description: 'תא השכפול מכפיל מייד את הערך הנוכחי של השחקן.',
      wallIndices: [16, 32],
      smartGateIndices: [17, 31],
      cloneIndices: [18],
      values: List.generate(49, (i) {
        if (i == 24) return 56;
        return (i * 3 + 2) % 7 + 1;
      }),
    ),

    // 4-3: ספירלת האפס
    _createLevelWithModifiers(
      id: 'w4_l3',
      worldId: 4,
      levelNumber: 3,
      worldTitle: 'מאסטר החיבור',
      title: 'ספירלת האפס',
      gridSize: 7,
      targetNumber: 64,
      parMoves: 12,
      description: 'תא האפס מאפס את הסכום ומחייב לבנות את המסלול מחדש.',
      wallIndices: [8, 9, 10, 26, 33, 40, 38, 37],
      zeroIndices: [18],
      values: List.generate(49, (i) {
        if (i == 24) return 64;
        return (i * 2 + 3) % 9 + 1;
      }),
    ),

    // 4-4: הטיטאן והחור השחור 9x9
    _createLevelWithModifiers(
      id: 'w4_l4',
      worldId: 4,
      levelNumber: 4,
      worldTitle: 'מאסטר החיבור',
      title: 'הטיטאן והחור השחור 9x9',
      gridSize: 9,
      targetNumber: 72,
      parMoves: 12,
      description: 'החור השחור משאיר רק המשך אקראי אחד פתוח.',
      wallIndices: [12, 14, 22, 32, 48, 58, 66, 68],
      trampolineIndices: [20, 60],
      blackHoleIndices: [30],
      values: List.generate(81, (i) {
        if (i == 40) return 72; // center of 81
        return (i * 7 + 3) % 9 + 1;
      }),
    ),

    // 4-5: הגראנד מאסטר 9x9
    _createLevelWithModifiers(
      id: 'w4_l5',
      worldId: 4,
      levelNumber: 5,
      worldTitle: 'מאסטר החיבור',
      title: 'הגראנד מאסטר 9x9',
      gridSize: 9,
      targetNumber: 85,
      parMoves: 14,
      description: 'שלב הגמר משלב מראה, שכפול, חור שחור, פצצה ואפס.',
      wallIndices: [21, 23, 31, 41, 49, 59, 57],
      trampolineIndices: [14, 66],
      smartGateIndices: [39, 41],
      mirrorIndices: [20],
      cloneIndices: [30],
      blackHoleIndices: [50],
      bombIndices: [60],
      zeroIndices: [70],
      values: List.generate(81, (i) {
        if (i == 40) return 85;
        return (i * 4 + 5) % 9 + 1;
      }),
    ),
  ];

  // Helper to create a basic level
  static LevelModel _createLevel({
    required String id,
    required int worldId,
    required int levelNumber,
    required String worldTitle,
    required String title,
    required int gridSize,
    required int targetNumber,
    required int parMoves,
    required String description,
    required List<int> values,
    required List<int> startIndices,
    List<String> hints = const [],
  }) {
    final total = gridSize * gridSize;
    final center = total ~/ 2;
    final tiles = <TileModel>[];

    for (var i = 0; i < total; i++) {
      final r = i ~/ gridSize;
      final c = i % gridSize;
      if (i == center) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.target,
            value: targetNumber,
          ),
        );
      } else if (startIndices.contains(i)) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.start,
            value: values[i],
          ),
        );
      } else {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.number,
            value: values[i],
          ),
        );
      }
    }

    return LevelModel(
      id: id,
      worldId: worldId,
      levelNumber: levelNumber,
      worldTitle: worldTitle,
      title: title,
      gridSize: gridSize,
      targetNumber: targetNumber,
      tiles: tiles,
      parMoves: parMoves,
      description: description,
      hints: hints,
    );
  }

  // Helper with walls, trampolines, smart gates
  static LevelModel _createLevelWithModifiers({
    required String id,
    required int worldId,
    required int levelNumber,
    required String worldTitle,
    required String title,
    required int gridSize,
    required int targetNumber,
    required int parMoves,
    required String description,
    required List<int> values,
    List<int> wallIndices = const [],
    List<int> trampolineIndices = const [],
    List<int> smartGateIndices = const [],
    List<int> mirrorIndices = const [],
    List<int> cloneIndices = const [],
    List<int> blackHoleIndices = const [],
    List<int> bombIndices = const [],
    List<int> zeroIndices = const [],
    List<String> hints = const [],
  }) {
    final total = gridSize * gridSize;
    final center = total ~/ 2;
    final defaultStarts = LevelModel.calculateDefaultStartPoints(gridSize);
    final specialPlacements = _spreadSpecialCells(
      id: id,
      gridSize: gridSize,
      center: center,
      blockedIndices: {
        ...wallIndices,
        ...trampolineIndices,
        ...smartGateIndices,
        ...defaultStarts,
      },
      requestedTypes: [
        for (final _ in mirrorIndices) TileType.mirror,
        for (final _ in cloneIndices) TileType.clone,
        for (final _ in blackHoleIndices) TileType.blackHole,
        for (final _ in bombIndices) TileType.bomb,
        for (final _ in zeroIndices) TileType.zero,
      ],
    );
    final tiles = <TileModel>[];

    for (var i = 0; i < total; i++) {
      final r = i ~/ gridSize;
      final c = i % gridSize;
      if (i == center) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.target,
            value: targetNumber,
          ),
        );
      } else if (wallIndices.contains(i)) {
        tiles.add(
          TileModel(index: i, row: r, col: c, type: TileType.wall, value: 0),
        );
      } else if (trampolineIndices.contains(i)) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.trampoline,
            value: values[i],
          ),
        );
      } else if (smartGateIndices.contains(i)) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.smartGate,
            value: values[i],
            customLabel: 'זוגי',
            metadata: {'rule': 'even'},
          ),
        );
      } else if (specialPlacements.containsKey(i)) {
        tiles.add(
          TileModel(index: i, row: r, col: c, type: specialPlacements[i]!),
        );
      } else if (defaultStarts.contains(i)) {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.start,
            value: values[i],
          ),
        );
      } else {
        tiles.add(
          TileModel(
            index: i,
            row: r,
            col: c,
            type: TileType.number,
            value: values[i],
          ),
        );
      }
    }

    return LevelModel(
      id: id,
      worldId: worldId,
      levelNumber: levelNumber,
      worldTitle: worldTitle,
      title: title,
      gridSize: gridSize,
      targetNumber: targetNumber,
      tiles: tiles,
      parMoves: parMoves,
      description: description,
      hints: hints,
    );
  }

  /// Uses a stable shuffle so special cells look randomly distributed while
  /// remaining reproducible for hints, tests, and saved campaign progress.
  static Map<int, TileType> _spreadSpecialCells({
    required String id,
    required int gridSize,
    required int center,
    required Set<int> blockedIndices,
    required List<TileType> requestedTypes,
  }) {
    if (requestedTypes.isEmpty) return const {};

    final total = gridSize * gridSize;
    final candidates = List<int>.generate(total, (index) => index).where((
      index,
    ) {
      final row = index ~/ gridSize;
      final col = index % gridSize;
      return index != center &&
          !blockedIndices.contains(index) &&
          row > 0 &&
          row < gridSize - 1 &&
          col > 0 &&
          col < gridSize - 1;
    }).toList()..shuffle(Random(_stableSeed(id)));

    final placements = <int, TileType>{};
    for (final type in requestedTypes) {
      if (candidates.isEmpty) break;
      var best = candidates.first;
      var bestDistance = -1;
      for (final candidate in candidates) {
        final candidateRow = candidate ~/ gridSize;
        final candidateCol = candidate % gridSize;
        final minimumDistance = placements.isEmpty
            ? gridSize
            : placements.keys
                  .map(
                    (placed) =>
                        (candidateRow - placed ~/ gridSize).abs() +
                        (candidateCol - placed % gridSize).abs(),
                  )
                  .reduce(min);
        if (minimumDistance > bestDistance) {
          best = candidate;
          bestDistance = minimumDistance;
        }
      }
      placements[best] = type;
      candidates.remove(best);
    }
    return placements;
  }

  static int _stableSeed(String value) {
    var seed = 17;
    for (final unit in value.codeUnits) {
      seed = (seed * 37 + unit) & 0x7fffffff;
    }
    return seed;
  }
}
