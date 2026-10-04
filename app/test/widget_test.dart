import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezy/core/audio/sound_service.dart';
import 'package:bezy/core/storage/progress_storage.dart';
import 'package:bezy/domain/campaign/campaign_levels.dart';
import 'package:bezy/domain/models/game_mode.dart';
import 'package:bezy/domain/models/game_state.dart';
import 'package:bezy/domain/models/level_model.dart';
import 'package:bezy/domain/models/tile_model.dart';
import 'package:bezy/l10n/app_localizations.dart';
import 'package:bezy/main.dart';
import 'package:bezy/ui/components/bezy_message_dialog.dart';
import 'package:bezy/ui/features/game/game_screen.dart';
import 'package:bezy/ui/features/game/components/board_widget.dart';
import 'package:bezy/ui/features/game/components/stats_bar.dart';
import 'package:bezy/ui/features/game/components/tile_factory.dart';

void main() {
  testWidgets('Home sound button persists mute and unmute', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('sound-toggle'));
    expect(toggle, findsOneWidget);
    expect(storage.isSoundEnabled, isTrue);
    await tester.tap(toggle);
    await tester.pump();
    expect(storage.isSoundEnabled, isFalse);
    await tester.tap(toggle);
    await tester.pump();
    expect(storage.isSoundEnabled, isTrue);
  });

  testWidgets('Framed messages grow vertically without leaking content', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const message =
        'This is a longer gameplay explanation that needs enough room inside '
        'the illustrated message frame. It must remain readable without text '
        'crossing the frame or covering the confirmation button.';
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
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showBezyMessageDialog(context, message: message),
            child: const Text('Show message'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show message'));
    await tester.pumpAndSettle();
    final frameSize = tester.getSize(
      find.byKey(const ValueKey('bezy-message-frame')),
    );
    expect(frameSize.height, greaterThan(frameSize.width / 1.5));
    expect(find.text(message), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    expect(find.byKey(const ValueKey('home-bezy-logo')), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Free Play'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('Journey'))),
      TextDirection.ltr,
    );

    await tester.tap(find.text('Journey'));
    await tester.pumpAndSettle();

    expect(find.text('Level map'), findsOneWidget);
    expect(find.byKey(const ValueKey('stage-node-1')), findsOneWidget);
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
    expect(find.text('משחק חופשי'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('מסע השלבים'))),
      TextDirection.rtl,
    );
  });

  testWidgets('Home instructions teach only the basic path rules', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();

    expect(find.text('Entry gate'), findsOneWidget);
    expect(find.text('Move on the board'), findsOneWidget);
    expect(find.text('Reach the target'), findsOneWidget);
    expect(find.text('Stone walls'), findsNothing);
    expect(find.text('Teleporting doors'), findsNothing);
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

    expect(find.text('Level map'), findsOneWidget);
    expect(find.byKey(const ValueKey('stage-node-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('stage-node-50')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.byType(FittedBox), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('campaign-map-overview')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.minScale, 1);
    expect(viewer.boundaryMargin, EdgeInsets.zero);
    expect(
      viewer.transformationController!.value.getMaxScaleOnAxis(),
      greaterThan(1),
    );
    // The map is clamped to cover the viewport, so it starts flush with the
    // top edge instead of leaving a gap of background above it.
    expect(
      viewer.transformationController!.value.getTranslation().y,
      closeTo(0, 0.1),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('stage-node-1'))).dy,
      greaterThan(0),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('stage-node-6'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('stage-node-10'))).dx,
      ),
    );
  });

  testWidgets('Late-stage map focus never reveals space beyond the artwork', (
    WidgetTester tester,
  ) async {
    final levels = CampaignLevels.getAllLevels();
    final values = <String, Object>{
      'pref_locale_code': 'en',
      'seen_basic_instructions': true,
    };
    for (final level in levels.take(levels.length - 2)) {
      values['unlocked_level_${level.id}'] = true;
      values['level_stars_${level.id}'] = 3;
    }
    values['unlocked_level_${levels[levels.length - 2].id}'] = true;
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('campaign-map-overview')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final viewerFinder = find.byType(InteractiveViewer);
    final viewer = tester.widget<InteractiveViewer>(viewerFinder);
    final viewport = tester.getSize(viewerFinder);
    final transform = viewer.transformationController!.value;
    final scale = transform.getMaxScaleOnAxis();
    final translation = transform.getTranslation();
    final mapHeight = viewport.width / (941 / 1672) * scale;
    final mapWidth = viewport.width * scale;

    expect(translation.y, lessThanOrEqualTo(0.01));
    expect(translation.x, lessThanOrEqualTo(0.01));
    expect(translation.y + mapHeight, greaterThanOrEqualTo(viewport.height - 0.5));
    expect(translation.x + mapWidth, greaterThanOrEqualTo(viewport.width - 0.5));
  });

  testWidgets('Newly approved stage plays unlock sequence before opening', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'pref_locale_code': 'en',
      'unlocked_level_w1_l2': true,
      'level_stars_w1_l1': 3,
      'seen_basic_instructions': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);

    await tester.pumpWidget(BezyApp(storage: storage, sound: sound));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journey'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('campaign-map-overview')));
    await tester.pump(const Duration(milliseconds: 500));

    final stageTwo = find.byKey(const ValueKey('stage-node-2'));
    expect(storage.isLevelRevealed('w1_l2'), isFalse);
    expect(
      tester
          .widgetList<Image>(
            find.descendant(of: stageTwo, matching: find.byType(Image)),
          )
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/stages/lock.png'),
    );

    await tester.tap(stageTwo);
    await tester.pump();
    expect(
      tester
          .widgetList<Image>(
            find.descendant(of: stageTwo, matching: find.byType(Image)),
          )
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/stages/unlock.png'),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester
          .widgetList<Image>(
            find.descendant(of: stageTwo, matching: find.byType(Image)),
          )
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/stages/free.png'),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(storage.isLevelRevealed('w1_l2'), isTrue);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen), findsOneWidget);
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

    expect(find.byKey(const ValueKey('home-bezy-logo')), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Free Play'), findsNothing);
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

  testWidgets('Landscape game keeps the board left and uses side panel art', (
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
          mode: GameMode.learning,
        ),
      ),
    );
    await tester.pump();

    final landscapePanel = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/buttons/panel_landscape.png',
    );
    expect(landscapePanel, findsOneWidget);
    expect(
      tester.getCenter(find.byType(BoardWidget)).dx,
      lessThan(tester.getCenter(find.byType(StatsBar)).dx),
    );
    expect(find.byKey(const ValueKey('bezy-board-mark')), findsOneWidget);
    expect(
      tester.getSize(find.byType(BoardWidget)).height,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('A new special tile is explained once before play', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final level = CampaignLevels.getLevelsForWorld(2).first;

    Widget game(Key key) => MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: GameScreen(
        key: key,
        initialLevel: level,
        storage: storage,
        sound: sound,
        mode: GameMode.learning,
        showSpecialIntroductions: true,
      ),
    );

    await tester.pumpWidget(game(const ValueKey('first-visit')));
    await tester.pump();
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text("Don't show this again"), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('basic-do-not-show-again')));
    await tester.pump();
    await tester.tap(find.text("Let's play"));
    await tester.pump();
    expect(storage.hasSeenBasicInstructions, isTrue);
    expect(find.text('New tile: Stone walls'), findsOneWidget);
    expect(
      find.text('Walls block the way, so find a route around them.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('special-wall-do-not-show-again')),
    );
    await tester.pump();
    await tester.tap(find.text('Got it'));
    await tester.pump();
    expect(storage.hasSeenSpecialIntroduction(TileType.wall.name), isTrue);

    await tester.pumpWidget(game(const ValueKey('return-visit')));
    await tester.pump();
    expect(find.text('New tile: Stone walls'), findsNothing);
  });

  testWidgets('Board path geometry and start selection stay aligned', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final level = CampaignLevels.getAllLevels().first;
    final startIndex = level.startIndices.first;
    final startValue = level.tiles[startIndex].applyValue(0);

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.learning,
        ),
      ),
    );
    await tester.pump();

    expect(
      Directionality.of(tester.element(find.byType(GridView))),
      TextDirection.ltr,
    );
    expect(
      find.byIcon(Icons.play_circle_fill_rounded),
      findsNWidgets(level.startIndices.length),
    );
    expect(
      find.byKey(const ValueKey('remaining-target-label')),
      findsOneWidget,
    );
    final centerArt = tester
        .widgetList<Image>(
          find.descendant(
            of: find.byType(TargetTileComponent),
            matching: find.byType(Image),
          ),
        )
        .map((image) => (image.image as AssetImage).assetName)
        .toList();
    expect(centerArt, ['assets/numbers/results/10.png']);

    await tester.tap(find.byKey(ValueKey('tile-$startIndex')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
    expect(
      find.text('${level.targetNumber - startValue} left'),
      findsOneWidget,
    );
    expect(find.text('#1'), findsNothing);
    final pressedStartArt = tester
        .widgetList<Image>(
          find.descendant(
            of: find.byType(StartTileComponent),
            matching: find.byType(Image),
          ),
        )
        .map((image) => (image.image as AssetImage).assetName);
    expect(
      pressedStartArt,
      contains(
        'assets/numbers/set1/${level.tiles[startIndex].value}pressed.png',
      ),
    );
  });

  testWidgets('A continuous pointer drag enters every crossed board cell', (
    WidgetTester tester,
  ) async {
    final tiles = List.generate(
      9,
      (index) => TileModel(
        index: index,
        row: index ~/ 3,
        col: index % 3,
        type: index == 0 ? TileType.start : TileType.number,
        value: 1,
      ),
    );
    final level = LevelModel(
      id: 'continuous-drag-test',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Continuous drag',
      gridSize: 3,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 3,
    );
    final touched = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BoardWidget(
            state: GameState(level: level),
            onTileTap: touched.add,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('tile-0'))),
    );
    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('tile-1'))),
    );
    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('tile-2'))),
    );
    await gesture.up();
    await tester.pump();

    expect(touched, [0, 1, 2]);
  });

  testWidgets('Center stays blocked until the exact total, then wins', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(9, (index) {
      return TileModel(
        index: index,
        row: index ~/ 3,
        col: index % 3,
        type: index == 1
            ? TileType.start
            : index == 4
            ? TileType.target
            : TileType.number,
        value: index == 1 || index == 0
            ? 1
            : index == 4
            ? 2
            : 0,
      );
    });
    final level = LevelModel(
      id: 'center-rule-test',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Center',
      gridSize: 3,
      targetNumber: 2,
      tiles: tiles,
      parMoves: 4,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('tile-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-4')));
    await tester.pump();
    expect(
      tester.widget<BoardWidget>(find.byType(BoardWidget)).state.currentPath,
      [1],
    );
    expect(find.text('Exact!'), findsNothing);
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/buttons/msg.png'),
    );
    await tester.tap(find.text('Got it'));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('tile-0')));
    await tester.pump();
    expect(find.text('0 left'), findsOneWidget);
    expect(find.text('Exact!'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('tile-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-4')));
    await tester.pump();
    expect(
      tester.widget<BoardWidget>(find.byType(BoardWidget)).state.isWon,
      isTrue,
    );
    expect(find.text('Exact!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Runner faces the current tap, including a left backtrack', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(
      25,
      (index) => TileModel(
        index: index,
        row: index ~/ 5,
        col: index % 5,
        type: index == 10
            ? TileType.start
            : index == 12
            ? TileType.target
            : TileType.number,
        value: index == 12 ? 99 : 1,
      ),
    );
    final level = LevelModel(
      id: 'runner-direction-test',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Runner',
      gridSize: 5,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 5,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();

    Future<void> tapAndExpect(int index, MoveDirection facing) async {
      await tester.tap(find.byKey(ValueKey('tile-$index')));
      await tester.pump();
      expect(
        tester
            .widget<BoardWidget>(find.byType(BoardWidget))
            .state
            .runnerDirection,
        facing,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/figure/${facing.name}.png',
        ),
        findsOneWidget,
      );
    }

    await tapAndExpect(10, MoveDirection.down);
    await tapAndExpect(5, MoveDirection.up);
    await tapAndExpect(6, MoveDirection.right);
    await tapAndExpect(5, MoveDirection.left);
  });

  testWidgets('Guided solution is previewed and remains on the board', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final level = CampaignLevels.getAllLevels().first;

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.learning,
        ),
      ),
    );
    await tester.pump();

    final attemptedStart = level.startIndices.first;
    await tester.tap(find.byKey(ValueKey('tile-$attemptedStart')));
    await tester.pump();
    var boardState = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(boardState.currentPath, isNotEmpty);

    await tester.tap(find.text('Solution'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    boardState = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(boardState.activeSolutionRoute, isNotNull);
    expect(boardState.solverStepIndex, 0);
    var panelState = tester.widget<StatsBar>(find.byType(StatsBar)).state;
    expect(
      panelState.currentSum,
      level.tiles[boardState.activeSolutionRoute!.first].value,
    );
    expect(panelState.moves, 1);
    expect(find.byKey(const ValueKey('bezy-board-mark')), findsOneWidget);

    await tester.tap(find.text('Apply this solution'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    boardState = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(boardState.currentPath, isEmpty);
    expect(boardState.activeSolutionRoute, isNotNull);
    expect(
      boardState.solverStepIndex,
      lessThan(boardState.activeSolutionRoute!.length - 1),
    );
    await tester.pump(
      Duration(milliseconds: boardState.activeSolutionRoute!.length * 700),
    );
    boardState = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(
      boardState.solverStepIndex,
      boardState.activeSolutionRoute!.length - 1,
    );
    expect(boardState.currentPath, isEmpty);
    expect(boardState.isWon, isFalse);
    panelState = tester.widget<StatsBar>(find.byType(StatsBar)).state;
    expect(panelState.currentSum, level.targetNumber);
    expect(panelState.isWon, isTrue);
    expect(find.text('Solution complete'), findsOneWidget);
    expect(find.text('Try this level'), findsOneWidget);
    expect(find.text('Level map'), findsOneWidget);

    await tester.tap(find.text('Try this level'));
    await tester.pump();
    boardState = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(boardState.activeSolutionRoute, isNull);
  });

  testWidgets('Lonely Cell remembers neighbors visited before backtracking', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(25, (index) {
      final type = switch (index) {
        3 => TileType.start,
        8 => TileType.lonely,
        12 => TileType.target,
        _ => TileType.number,
      };
      return TileModel(
        index: index,
        row: index ~/ 5,
        col: index % 5,
        type: type,
        value: index == 12 ? 99 : 0,
      );
    });
    final level = LevelModel(
      id: 'lonely-widget-test',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Lonely history',
      gridSize: 5,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 8,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.learning,
        ),
      ),
    );
    await tester.pump();

    Future<void> tapTile(int index) async {
      await tester.tap(find.byKey(ValueKey('tile-$index')));
      await tester.pump();
    }

    await tapTile(3);
    await tapTile(8);
    var state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [3]);
    expect(find.textContaining('Visit all four neighboring'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pump();

    for (final route in const [
      [2, 7],
      [4, 9],
      [4, 9, 14, 13],
    ]) {
      for (final index in route) {
        await tapTile(index);
      }
      await tapTile(3);
    }

    state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [3]);
    expect(state.visitedIndices, containsAll({3, 7, 9, 13}));
    expect(find.byIcon(Icons.lock_rounded), findsNothing);

    await tapTile(8);
    state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [3, 8]);
    expect(state.visitedIndices, contains(8));
    final lonelyCellAssets = tester
        .widgetList<Image>(
          find.descendant(
            of: find.byKey(const ValueKey('tile-8')),
            matching: find.byType(Image),
          ),
        )
        .map((image) => (image.image as AssetImage).assetName);
    expect(lonelyCellAssets, isNot(contains('assets/special/lonely_cell.png')));
    expect(lonelyCellAssets, contains('assets/numbers/set1/0pressed.png'));
  });

  testWidgets('Special and gate tiles use supplied PNG artwork', (
    WidgetTester tester,
  ) async {
    final tiles = List.generate(
      9,
      (index) => TileModel(
        index: index,
        row: index ~/ 3,
        col: index % 3,
        type: switch (index) {
          0 => TileType.wall,
          1 => TileType.trampoline,
          2 => TileType.smartGate,
          4 => TileType.target,
          5 => TileType.start,
          _ => TileType.number,
        },
        value: index == 4 ? 10 : 4,
      ),
    );
    final level = LevelModel(
      id: 'asset-test',
      worldId: 1,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Assets',
      gridSize: 3,
      targetNumber: 10,
      tiles: tiles,
      parMoves: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BoardWidget(
            state: GameState(level: level, blackHoledIndices: const {3}),
            onTileTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => (image.image as AssetImage).assetName)
        .toList();
    expect(assetNames, contains('assets/special/wall.png'));
    expect(assetNames, contains('assets/special/black_holed_cell.png'));
    expect(assetNames, contains('assets/special/teleporting_door.png'));
    expect(assetNames, contains('assets/numbers/set1/gates/4up.png'));
    expect(assetNames, contains('assets/numbers/results/10.png'));
  });

  testWidgets('Black Hole keeps one continuation and blocks the others', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(25, (index) {
      final type = switch (index) {
        12 => TileType.target,
        17 => TileType.blackHole,
        22 => TileType.start,
        _ => TileType.number,
      };
      return TileModel(
        index: index,
        row: index ~/ 5,
        col: index % 5,
        type: type,
        value: index == 12 ? 99 : 1,
      );
    });
    final level = LevelModel(
      id: 'black-hole-test',
      worldId: 4,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Black Hole',
      gridSize: 5,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 5,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-22')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-17')));
    await tester.pump();

    var state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.allowedNextIndices, hasLength(1));
    expect(state.blackHoledIndices, hasLength(1));
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/special/black_holed_cell.png'),
    );

    final blockedIndex = state.blackHoledIndices.single;
    await tester.tap(find.byKey(ValueKey('tile-$blockedIndex')));
    await tester.pump();
    state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [22, 17]);
    await tester.tap(find.text('Got it'));
    await tester.pump();

    final allowedIndex = state.allowedNextIndices.single;
    await tester.tap(find.byKey(ValueKey('tile-$allowedIndex')));
    await tester.pump();
    state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.blackHoledIndices, contains(blockedIndex));
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName),
      contains('assets/special/black_holed_cell.png'),
    );
  });

  testWidgets('Teleporting door moves to its pair without changing total', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(25, (index) {
      final type = switch (index) {
        7 || 17 => TileType.trampoline,
        12 => TileType.target,
        22 => TileType.start,
        _ => TileType.number,
      };
      return TileModel(
        index: index,
        row: index ~/ 5,
        col: index % 5,
        type: type,
        value: index == 12
            ? 99
            : index == 22
            ? 3
            : 8,
      );
    });
    final level = LevelModel(
      id: 'teleport-test',
      worldId: 3,
      levelNumber: 1,
      worldTitle: 'Test',
      title: 'Teleport',
      gridSize: 5,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 5,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-22')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-17')));
    await tester.pump(const Duration(milliseconds: 100));

    final state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [22, 17, 7]);
    expect(state.currentCellIndex, 7);
    expect(state.currentSum, 3);
    expect(state.moves, 2);
    expect(find.byKey(const ValueKey('runner-at-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('runner-at-17')), findsNothing);
  });

  testWidgets('A normal-looking legacy gate accepts an upward move', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final tiles = List.generate(25, (index) {
      final type = switch (index) {
        12 => TileType.target,
        17 => TileType.smartGate,
        22 => TileType.start,
        _ => TileType.number,
      };
      return TileModel(
        index: index,
        row: index ~/ 5,
        col: index % 5,
        type: type,
        value: index == 12
            ? 99
            : index == 17
            ? 5
            : 1,
        metadata: index == 17 ? const {'rule': 'even'} : const {},
      );
    });
    final level = LevelModel(
      id: 'upward-gate-test',
      worldId: 4,
      levelNumber: 2,
      worldTitle: 'Test',
      title: 'Upward',
      gridSize: 5,
      targetNumber: 99,
      tiles: tiles,
      parMoves: 5,
    );

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-22')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-17')));
    await tester.pump();

    final state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, [22, 17]);
    expect(state.currentSum, 6);
    expect(state.runnerDirection, MoveDirection.up);
  });

  testWidgets('Extra challenge starts its timer and records a Joker choice', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final level = CampaignLevels.getLevelsForWorld(5).first;

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-3')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:59'), findsOneWidget);

    for (final index in [2, 9, 8, 15, 14]) {
      await tester.tap(find.byKey(ValueKey('tile-$index')));
      await tester.pump();
    }
    expect(find.text('Choose the Joker value'), findsOneWidget);
    await tester.tap(find.textContaining('+2').first);
    await tester.pump();

    final state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath.last, 14);
    expect(state.jokerChoices[14], 2);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('Ice crosses its chain and lands in one move', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'pref_locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final storage = ProgressStorage(prefs);
    final sound = SoundService(storage);
    final level = CampaignLevels.getLevelsForWorld(6).first;

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
          initialLevel: level,
          storage: storage,
          sound: sound,
          mode: GameMode.challenge,
        ),
      ),
    );
    await tester.pump();
    final route = level.solutionRoutes.first;
    final icePosition = route.indexWhere((index) => level.tiles[index].isIce);
    expect(icePosition, greaterThan(0));
    expect(icePosition, lessThan(route.length - 1));
    for (final index in route.take(icePosition + 1)) {
      await tester.tap(find.byKey(ValueKey('tile-$index')));
      await tester.pump();
    }

    final state = tester.widget<BoardWidget>(find.byType(BoardWidget)).state;
    expect(state.currentPath, route.take(icePosition + 2).toList());
    expect(state.currentCellIndex, route[icePosition + 1]);
    expect(state.moves, icePosition + 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
