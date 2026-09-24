import 'package:shared_preferences/shared_preferences.dart';

/// Manages local persistent storage of player progression, stars, and settings.
class ProgressStorage {
  static const String _unlockedLevelPrefix = 'unlocked_level_';
  static const String _levelStarsPrefix = 'level_stars_';
  static const String _levelBestMovesPrefix = 'level_best_moves_';
  static const String _hapticsKey = 'pref_haptics_enabled';
  static const String _soundKey = 'pref_sound_enabled';
  static const String _localeKey = 'pref_locale_code';
  static const String _specialIntroductionPrefix = 'seen_special_intro_';
  static const String _basicInstructionsSeenKey = 'seen_basic_instructions';

  final SharedPreferences _prefs;

  ProgressStorage(this._prefs);

  static Future<ProgressStorage> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    // Ensure the very first level is unlocked by default
    if (!storage.isLevelUnlocked('w1_l1')) {
      await storage.unlockLevel('w1_l1');
    }
    return storage;
  }

  bool isLevelUnlocked(String levelId) {
    if (levelId == 'w1_l1') return true;
    return _prefs.getBool('$_unlockedLevelPrefix$levelId') ?? false;
  }

  Future<void> unlockLevel(String levelId) async {
    await _prefs.setBool('$_unlockedLevelPrefix$levelId', true);
  }

  int getStars(String levelId) {
    return _prefs.getInt('$_levelStarsPrefix$levelId') ?? 0;
  }

  int? getBestMoves(String levelId) {
    return _prefs.getInt('$_levelBestMovesPrefix$levelId');
  }

  /// Records level completion, awards stars, and unlocks the next level.
  Future<int> recordCompletion({
    required String levelId,
    required int moves,
    required int parMoves,
    String? nextLevelId,
  }) async {
    // Calculate stars: 3 stars if <= parMoves, 2 stars if <= parMoves + 2, 1 star otherwise
    int starsEarned = 1;
    if (moves <= parMoves) {
      starsEarned = 3;
    } else if (moves <= parMoves + 2) {
      starsEarned = 2;
    }

    final currentStars = getStars(levelId);
    if (starsEarned > currentStars) {
      await _prefs.setInt('$_levelStarsPrefix$levelId', starsEarned);
    }

    final currentBest = getBestMoves(levelId);
    if (currentBest == null || moves < currentBest) {
      await _prefs.setInt('$_levelBestMovesPrefix$levelId', moves);
    }

    if (nextLevelId != null) {
      await unlockLevel(nextLevelId);
    }

    return starsEarned;
  }

  int getTotalStarsForWorld(int worldId, List<String> levelIds) {
    var sum = 0;
    for (final id in levelIds) {
      sum += getStars(id);
    }
    return sum;
  }

  int getTotalStars() {
    var sum = 0;
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_levelStarsPrefix)) {
        sum += _prefs.getInt(key) ?? 0;
      }
    }
    return sum;
  }

  bool get isHapticsEnabled => _prefs.getBool(_hapticsKey) ?? true;
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(_hapticsKey, enabled);
  }

  bool get isSoundEnabled => _prefs.getBool(_soundKey) ?? true;
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundKey, enabled);
  }

  String? get localeCode => _prefs.getString(_localeKey);

  Future<void> setLocaleCode(String localeCode) async {
    await _prefs.setString(_localeKey, localeCode);
  }

  bool hasSeenSpecialIntroduction(String tileType) =>
      _prefs.getBool('$_specialIntroductionPrefix$tileType') ?? false;

  Future<void> markSpecialIntroductionSeen(String tileType) =>
      _prefs.setBool('$_specialIntroductionPrefix$tileType', true);

  bool get hasSeenBasicInstructions =>
      _prefs.getBool(_basicInstructionsSeenKey) ?? false;

  Future<void> markBasicInstructionsSeen() =>
      _prefs.setBool(_basicInstructionsSeenKey, true);
}
