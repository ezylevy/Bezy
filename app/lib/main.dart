import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/audio/sound_service.dart';
import 'core/storage/progress_storage.dart';
import 'core/theme/app_theme.dart';
import 'ui/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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

class BezyApp extends StatelessWidget {
  final ProgressStorage storage;
  final SoundService sound;

  const BezyApp({
    super.key,
    required this.storage,
    required this.sound,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מסלול החיבור',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(storage: storage, sound: sound),
    );
  }
}
