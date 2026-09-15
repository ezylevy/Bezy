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
