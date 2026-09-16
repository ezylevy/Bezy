import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'core/audio/sound_service.dart';
import 'core/storage/progress_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'ui/features/home/home_screen.dart';
import 'ui/features/onboarding/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style for immersive gaming experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storage = await ProgressStorage.initialize();
  final sound = SoundService(storage);

  runApp(BezyApp(storage: storage, sound: sound));
}

class BezyApp extends StatefulWidget {
  final ProgressStorage storage;
  final SoundService sound;

  const BezyApp({super.key, required this.storage, required this.sound});

  @override
  State<BezyApp> createState() => _BezyAppState();
}

class _BezyAppState extends State<BezyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    final savedLocale = widget.storage.localeCode;
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
  }

  Future<void> _selectLocale(Locale locale) async {
    await widget.storage.setLocaleCode(locale.languageCode);
    if (!mounted) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BEZY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: _locale ?? const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _locale == null
          ? LanguageSelectionScreen(onLocaleSelected: _selectLocale)
          : HomeScreen(storage: widget.storage, sound: widget.sound),
    );
  }
}
