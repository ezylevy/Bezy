import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('he')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get _isHebrew => locale.languageCode == 'he';

  String _value({required String en, required String he}) =>
      _isHebrew ? he : en;

  String get appTitle => 'BEZY';
  String get appSubtitle => _value(
    en: 'A path-building math adventure',
    he: 'הרפתקת חשיבה ומתמטיקה במסלולים',
  );
  String get createdBy =>
      _value(en: 'Created by Ezy Levy', he: 'נוצר על ידי עזי לוי');
  String stars(int count) => _value(en: '$count stars', he: '$count כוכבים');
  String get haptics => _value(en: 'Haptic feedback', he: 'רטט הפטי');
  String get sounds => _value(en: 'Sounds', he: 'צלילים');
  String get campaignTitle => _value(en: 'Journey', he: 'מסע השלבים');
  String get campaignSubtitle => _value(
    en: 'Explore worlds with walls, launch pads, and smart gates',
    he: 'עולמות עם חומות, מקפצות ושערים חכמים',
  );
  String get chooseMode => _value(en: 'Choose a mode', he: 'בחרו מצב משחק');
  String get learningMode => _value(en: 'Learning', he: 'לימודי');
  String get learningModeDescription => _value(
    en: 'Learn at your pace with hints and guided solutions',
    he: 'לומדים בקצב שלכם עם רמזים ופתרונות מודרכים',
  );
  String get challengeMode => _value(en: 'Challenge', he: 'אתגרי');
  String get challengeModeDescription => _value(
    en: 'Solve independently — no hints and no solutions',
    he: 'פותרים באופן עצמאי — ללא רמזים וללא פתרונות',
  );
  String get freePlayTitle => _value(en: 'Free Play', he: 'משחק חופשי');
  String get freePlaySubtitle => _value(
    en: 'Fresh boards from 3×3 to 9×9',
    he: 'לוחות חדשים מ־3×3 עד 9×9',
  );
  String get howToPlay => _value(en: 'How to play', he: 'איך משחקים?');
  String get howToPlaySubtitle => _value(
    en: 'Rules, special tiles, and winning tips',
    he: 'חוקי המשחק, משבצות מיוחדות וטיפים לניצחון',
  );
  String get versionLabel => _value(
    en: 'Version 1.0.0 • Android and iOS',
    he: 'גרסה 1.0.0 • Android ו־iOS',
  );
  String get instructionsTitle =>
      _value(en: 'Game instructions', he: 'הוראות המשחק');
  String get startTile => _value(en: 'Start tile', he: 'משבצת התחלה');
  String get startTileDescription => _value(
    en: 'Begin at one of the green start tiles around the board.',
    he: 'התחילו מאחת ממשבצות ההתחלה הירוקות שבהיקף הלוח.',
  );
  String get boardMovement => _value(en: 'Move on the board', he: 'תנועה בלוח');
  String get boardMovementDescription => _value(
    en: 'Move to a neighboring tile. Each tile adds its value to the total.',
    he: 'התקדמו למשבצת סמוכה. כל משבצת מוסיפה את ערכה לסכום.',
  );
  String get reachTarget => _value(en: 'Reach the target', he: 'הגעה ליעד');
  String get reachTargetDescription => _value(
    en: 'Reach the center with exactly the required total.',
    he: 'הגיעו למשבצת שבמרכז בדיוק עם הסכום הנדרש.',
  );
  String get walls => _value(en: 'Stone walls', he: 'חומות אבן');
  String get wallsDescription => _value(
    en: 'Walls block the way, so find a route around them.',
    he: 'החומות חוסמות מעבר ולכן צריך למצוא נתיב עוקף.',
  );
  String get launchPads => _value(en: 'Launch pads', he: 'מקפצות זינוק');
  String get launchPadsDescription => _value(
    en: 'Launch pads add a bonus to your running total.',
    he: 'המקפצות מעניקות תוספת בונוס לסכום המצטבר.',
  );
  String get smartGates => _value(en: 'Smart gates', he: 'שערים חכמים');
  String get smartGatesDescription => _value(
    en: 'Gates open only when their number rule is satisfied.',
    he: 'השערים נפתחים רק כאשר התנאי המספרי שלהם מתקיים.',
  );
  String get smartHelp => _value(en: 'Smart help', he: 'עזרה חכמה');
  String get smartHelpDescription => _value(
    en: 'In Learning mode, use a hint or the guided solution when needed.',
    he: 'במצב לימודי אפשר להשתמש ברמז או בפתרון מודרך בעת הצורך.',
  );
  String get close => _value(en: 'Got it', he: 'הבנתי');

  String get worldMap => _value(en: 'World map', he: 'מפת העולמות');
  String worldNumber(int number, String title) =>
      _value(en: 'World $number: $title', he: 'עולם $number: $title');
  String levelProgress(int unlocked, int total) => _value(
    en: 'Levels unlocked: $unlocked / $total',
    he: 'שלבים פתוחים: $unlocked / $total',
  );
  String boardTarget(int size, int target) => _value(
    en: '$size×$size board • Target: $target',
    he: 'לוח $size×$size • יעד: $target',
  );
  String bestMoves(int best, int par) => _value(
    en: 'Best: $best moves (par: $par)',
    he: 'שיא: $best צעדים (יעד: $par)',
  );

  String get exact => _value(en: 'Exact!', he: 'מדויק!');
  String remaining(int amount) =>
      _value(en: '$amount left', he: 'חסר: $amount');
  String overBy(int amount) => _value(en: '$amount over', he: 'חריגה: $amount');
  String get target => _value(en: 'Target', he: 'יעד');
  String get even => _value(en: 'Even', he: 'זוגי');
  String get currentSum => _value(en: 'Current', he: 'סכום נוכחי');
  String get difference => _value(en: 'Difference', he: 'הפרש');
  String get moves => _value(en: 'Moves', he: 'צעדים');
  String par(int value) => _value(en: 'Par: $value', he: 'יעד: $value');
  String get undo => _value(en: 'Undo', he: 'ביטול צעד');
  String get reset => _value(en: 'Reset', he: 'איפוס');
  String get smartHint => _value(en: 'Hint', he: 'רמז חכם');
  String get guidedSolution => _value(en: 'Solution', he: 'פתרון חכם');
  String get resetBoard => _value(en: 'Reset board', he: 'איפוס לוח');
  String get instructions => _value(en: 'Instructions', he: 'הוראות');
  String get startRequired => _value(
    en: 'Start from one of the green start tiles.',
    he: 'עליכם להתחיל מאחת ממשבצות ההתחלה הירוקות.',
  );
  String get adjacentOnly => _value(
    en: 'Move only to an adjacent tile: up, down, left, or right.',
    he: 'ניתן לנוע רק למשבצת סמוכה: למעלה, למטה, ימינה או שמאלה.',
  );
  String get wallBlocked => _value(
    en: 'Stone walls cannot be crossed.',
    he: 'אי אפשר לעבור דרך חומת אבן!',
  );
  String get gateBlocked => _value(
    en: 'The smart gate is locked. An even total is required.',
    he: 'השער החכם נעול! דרוש סכום זוגי למעבר.',
  );
  String wrongTarget(int current, int goal) => _value(
    en: 'Your total is $current, not $goal. Go back and try another path.',
    he: 'הסכום הנוכחי ($current) אינו תואם ליעד ($goal). חזרו אחורה.',
  );
  String get hintShown => _value(
    en: 'Hint: the recommended next tile is glowing gold.',
    he: 'רמז: המשבצת המומלצת הבאה מהבהבת בזהב.',
  );
  String get noValidPath => _value(
    en: 'No valid path remains. Undo a move and try again.',
    he: 'אין מסלול תקף מהמצב הנוכחי. בטלו צעד ונסו שוב.',
  );
  String get compactGameHelp => _value(
    en: '1. Start on a green tile.\n2. Move up, down, left, or right.\n3. Each tile changes your total.\n4. Walls block movement.\n5. Launch pads add a bonus.\n6. Smart gates open only when their rule is satisfied.\n7. Reach the center with the exact target total.',
    he: '1. התחילו במשבצת ירוקה.\n2. נועו למעלה, למטה, ימינה או שמאלה.\n3. כל משבצת משנה את הסכום.\n4. חומות חוסמות מעבר.\n5. מקפצות מוסיפות בונוס.\n6. שערים נפתחים רק כאשר התנאי מתקיים.\n7. הגיעו למרכז עם הסכום המדויק.',
  );
  String get letsPlay => _value(en: "Let's play", he: 'בואו נשחק');

  String get victoryTitle =>
      _value(en: 'Brilliant! You did it!', he: 'כל הכבוד! הצלחתם!');
  String exactTarget(int value) =>
      _value(en: 'You reached exactly $value.', he: 'הגעתם בדיוק ליעד $value.');
  String get yourMoves => _value(en: 'Your moves', he: 'הצעדים שלכם');
  String get targetMoves => _value(en: 'Par', he: 'יעד צעדים');
  String get starLabel => _value(en: 'Stars', he: 'כוכבים');
  String get nextLevel => _value(en: 'Next level', he: 'השלב הבא');
  String get playAgain => _value(en: 'Play again', he: 'שחקו שוב');
  String get levelMap => _value(en: 'Level map', he: 'מפת השלבים');

  String get customGame =>
      _value(en: 'Custom Free Play', he: 'משחק חופשי מותאם אישית');
  String get selectBoardSize =>
      _value(en: 'Choose a board size', he: 'בחרו גודל לוח');
  String get specialElements =>
      _value(en: 'Special elements', he: 'אלמנטים מיוחדים');
  String get wallsAndObstacles =>
      _value(en: 'Walls and obstacles', he: 'חומות ומכשולים');
  String get cancel => _value(en: 'Cancel', he: 'ביטול');
  String get startGame => _value(en: 'Start game', he: 'התחלת משחק');
  String get noSolution => _value(en: 'No solution found', he: 'לא נמצא פתרון');
  String get noSolutionDescription => _value(
    en: 'No valid path reaches the requested target on this board.',
    he: 'לא נמצא מסלול תקף שמגיע לסכום המבוקש בלוח הזה.',
  );
  String get solverTitle => _value(en: 'Guided solution', he: 'פתרון מודרך');
  String stepProgress(int current, int total) =>
      _value(en: 'Step $current of $total', he: 'צעד $current מתוך $total');
  String sumValue(int value) => _value(en: 'Total: $value', he: 'סכום: $value');
  String get applySolution =>
      _value(en: 'Apply this solution', he: 'החלת הפתרון על הלוח');
  String get solverStartPoint =>
      _value(en: 'Starting point', he: 'נקודת התחלה');
  String openingTotal(int value) =>
      _value(en: 'Opening total: $value', he: 'סכום פתיחה: $value');
  String get solverReachedTarget =>
      _value(en: 'Target reached!', he: 'הגעה למרכז!');
  String targetMatched(int total, int targetValue) => _value(
    en: '$total matches the target $targetValue.',
    he: 'הסכום $total תואם ליעד $targetValue.',
  );
  String get solverLaunchPad =>
      _value(en: 'Launch pad bonus', he: 'בונוס מקפצה');
  String bonusFormula(int previous, int value, int bonus, int total) => _value(
    en: '$previous + $value value + $bonus bonus = $total',
    he: '$previous + $value ערך + $bonus בונוס = $total',
  );
  String get solverGate => _value(en: 'Smart gate passed', he: 'מעבר בשער חכם');
  String get solverNextStep => _value(en: 'Continue the path', he: 'צעד נוסף');

  String worldTitle(int worldId, String fallback) {
    if (_isHebrew) return fallback;
    return const {
          0: 'Free Play',
          1: 'Number Academy',
          2: 'The Wall Maze',
          3: 'Launch Pads & Gates',
          4: 'Master Circuit',
        }[worldId] ??
        fallback;
  }

  String worldSubtitle(int worldId, String fallback) {
    if (_isHebrew) return fallback;
    return const {
          1: '3×3 boards — learn the path rules',
          2: '5×5 boards — navigate walls and obstacles',
          3: '5×5 and 7×7 boards — bonuses and number rules',
          4: '7×7 and 9×9 boards — expert challenges',
        }[worldId] ??
        fallback;
  }

  String levelTitle(String levelId, String fallback, {int? gridSize}) {
    if (_isHebrew) return fallback;
    if (levelId.startsWith('gen_') || levelId.startsWith('fallback_')) {
      return gridSize == null
          ? 'Challenge board'
          : '$gridSize×$gridSize challenge';
    }
    return const {
          'w1_l1': 'First Step',
          'w1_l2': 'The Winding Path',
          'w1_l3': 'Choose a Gate',
          'w1_l4': 'Exact Math',
          'w1_l5': 'Academy Final',
          'w2_l1': 'First Stone Wall',
          'w2_l2': 'Double Detour',
          'w2_l3': 'Number Fortress',
          'w2_l4': 'Narrow Corridor',
          'w2_l5': 'The Wall Trap',
          'w3_l1': 'Launch Pad Boost',
          'w3_l2': 'The Even Gate',
          'w3_l3': 'Over the Wall',
          'w3_l4': 'Gate Maze',
          'w3_l5': 'Super Launch Pad 7×7',
          'w4_l1': 'The Grand Maze 7×7',
          'w4_l2': 'Chain of Gates',
          'w4_l3': 'Spiral Maze',
          'w4_l4': 'The Titan 9×9',
          'w4_l5': 'Grand Master 9×9',
        }[levelId] ??
        fallback;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
