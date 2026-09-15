import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezy/core/audio/sound_service.dart';
import 'package:bezy/core/storage/progress_storage.dart';
import 'package:bezy/main.dart';

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();

    expect(find.text('מסלול החיבור'), findsOneWidget);
    expect(find.text('מסע השלבים (קמפיין)'), findsOneWidget);
    expect(find.text('משחק חופשי (אינסופי)'), findsOneWidget);
  });
}
