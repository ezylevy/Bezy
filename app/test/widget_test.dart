import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezy/core/audio/sound_service.dart';
import 'package:bezy/core/storage/progress_storage.dart';
import 'package:bezy/domain/campaign/campaign_levels.dart';
import 'package:bezy/domain/models/game_mode.dart';
import 'package:bezy/l10n/app_localizations.dart';
import 'package:bezy/main.dart';
import 'package:bezy/ui/features/game/game_screen.dart';

void main() {
  testWidgets('First launch asks for a language and persists English', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language\nבחרו שפה'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(storage.localeCode, 'en');
    expect(find.text('BEZY'), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Free Play'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Journey'))),
      TextDirection.ltr,
    );

    await tester.tap(find.text('Journey'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a mode'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Challenge'), findsOneWidget);
  });

  testWidgets('A saved Hebrew locale opens the RTL home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'he'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();

    expect(find.text('מסע השלבים'), findsOneWidget);
    expect(find.text('משחק חופשי'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('מסע השלבים'))),
      TextDirection.rtl,
    );
  });

  testWidgets('English journey and world content are localized', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learning'));
    await tester.pumpAndSettle();

    expect(find.text('World map'), findsOneWidget);
    expect(find.text('World 1: Number Academy'), findsOneWidget);
  });

  testWidgets('Home remains usable in landscape', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();

    expect(find.text('BEZY'), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Free Play'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Challenge gameplay exposes no hint or solution controls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: GameScreen(
          initialLevel: CampaignLevels.getAllLevels().first,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('Solution'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
