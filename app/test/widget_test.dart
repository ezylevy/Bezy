import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezy/core/audio/sound_service.dart';
import 'package:bezy/core/storage/progress_storage.dart';
import 'package:bezy/main.dart';

void main() {
  testWidgets('First launch asks for a language and persists English',
      (WidgetTester tester) async {
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
  });

  testWidgets('A saved Hebrew locale opens the RTL home screen',
      (WidgetTester tester) async {
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
}
