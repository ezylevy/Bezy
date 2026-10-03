import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_state.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/level_model.dart';
import '../../../domain/models/tile_model.dart';
import '../../../domain/solver/path_solver.dart';
import '../../../l10n/app_localizations.dart';
import '../../components/bezy_message_dialog.dart';
import '../victory/victory_dialog.dart';
import 'components/board_widget.dart';
import 'components/stats_bar.dart';
import 'solver_player/solver_dialog.dart';

/// The primary gameplay screen where puzzles are played and solved.
class GameScreen extends StatefulWidget {
  final LevelModel initialLevel;
  final ProgressStorage storage;
  final SoundService sound;
  final GameMode mode;
  final bool showSpecialIntroductions;

  const GameScreen({
    super.key,
    required this.initialLevel,
    required this.storage,
    required this.sound,
    required this.mode,
    this.showSpecialIntroductions = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late GameState _gameState;
  late AnimationController _pulseController;
  bool _assetsPrecached = false;
  int _solutionPlaybackId = 0;
  final Random _random = Random();
  Timer? _countdownTimer;
  int? _remainingSeconds;
  bool _messageDialogVisible = false;

  bool get _usesChallengeTimer =>
      widget.mode == GameMode.challenge &&
      _gameState.level.challengeTimeSeconds != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameState = GameState(level: widget.initialLevel);
    _remainingSeconds = widget.initialLevel.challengeTimeSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    if (widget.showSpecialIntroductions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUnseenSpecialIntroductions(widget.initialLevel);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsPrecached) return;
    _assetsPrecached = true;
    for (final direction in MoveDirection.values) {
      precacheImage(AssetImage('assets/figure/${direction.name}.png'), context);
    }
    for (var digit = 0; digit <= 9; digit++) {
      precacheImage(AssetImage('assets/numbers/set1/${digit}up.png'), context);
      precacheImage(
        AssetImage('assets/numbers/set1/gates/${digit}up.png'),
        context,
      );
      precacheImage(
        AssetImage('assets/numbers/set1/${digit}pressed.png'),
        context,
      );
    }
    for (var result = 8; result <= 88; result++) {
      precacheImage(AssetImage('assets/numbers/results/$result.png'), context);
    }
    for (final asset in const [
      'mirror.png',
      'clone.png',
      'black_hole.png',
      'black_holed_cell.png',
      'bomb.png',
      'zero.png',
      'joker.png',
      'ice.png',
      'lonely_cell.png',
      'wall.png',
      'teleporting_door.png',
    ]) {
      precacheImage(AssetImage('assets/special/$asset'), context);
    }
    precacheImage(const AssetImage('assets/buttons/panel.png'), context);
    precacheImage(
      const AssetImage('assets/buttons/panel_landscape.png'),
      context,
    );
  }

  static const _introducedSpecialTypes = <TileType>{
    TileType.wall,
    TileType.trampoline,
    TileType.mirror,
    TileType.clone,
    TileType.blackHole,
    TileType.bomb,
    TileType.zero,
    TileType.joker,
    TileType.ice,
    TileType.lonely,
  };

  String _specialArt(TileType type) => switch (type) {
    TileType.wall => 'wall.png',
    TileType.trampoline => 'teleporting_door.png',
    TileType.mirror => 'mirror.png',
    TileType.clone => 'clone.png',
    TileType.blackHole => 'black_hole.png',
    TileType.bomb => 'bomb.png',
    TileType.zero => 'zero.png',
    TileType.joker => 'joker.png',
    TileType.ice => 'ice.png',
    TileType.lonely => 'lonely_cell.png',
    _ => throw StateError('No introduction artwork for $type'),
  };

  Future<void> _showUnseenSpecialIntroductions(LevelModel level) async {
    // Custom test boards have their own setup. Campaign and generated Free
    // Play levels reveal a tile only when the player first encounters it.
    final isPlayableLevel =
        level.id.startsWith('gen_') ||
        CampaignLevels.getAllLevels().any(
          (candidate) => candidate.id == level.id,
        );
    if (!isPlayableLevel) return;

    if (!widget.storage.hasSeenBasicInstructions) {
      final strings = AppLocalizations.of(context);
      var doNotShowAgain = false;
      final shouldHide = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: Text(strings.howToPlay),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strings.compactGameHelp),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    key: const ValueKey('basic-do-not-show-again'),
                    value: doNotShowAgain,
                    onChanged: (value) =>
                        setDialogState(() => doNotShowAgain = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.doNotShowAgain),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(doNotShowAgain),
                child: Text(strings.letsPlay),
              ),
            ],
          ),
        ),
      );
      if (!mounted || _gameState.level.id != level.id) return;
      if (shouldHide == true) {
        await widget.storage.markBasicInstructionsSeen();
      }
    }

    final types = level.tiles
        .map((tile) => tile.type)
        .where(_introducedSpecialTypes.contains)
        .toSet();
    for (final type in types) {
      if (!mounted || _gameState.level.id != level.id) return;
      if (widget.storage.hasSeenSpecialIntroduction(type.name)) continue;
      final strings = AppLocalizations.of(context);
      var doNotShowAgain = false;
      final shouldHide = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: Text(
              '${strings.newTileIntroduction}: ${strings.specialTileTitle(type)}',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 86,
                    height: 86,
                    child: Image.asset(
                      'assets/special/${_specialArt(type)}',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(strings.specialTileDescription(type)),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    key: ValueKey('special-${type.name}-do-not-show-again'),
                    value: doNotShowAgain,
                    onChanged: (value) =>
                        setDialogState(() => doNotShowAgain = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.doNotShowAgain),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(doNotShowAgain),
                child: Text(strings.close),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      if (shouldHide == true) {
        await widget.storage.markSpecialIntroductionSeen(type.name);
      }
    }
  }

  MoveDirection _facingFrom(int from, int to, int gridSize) {
    final rowDelta = to ~/ gridSize - from ~/ gridSize;
    final colDelta = to % gridSize - from % gridSize;
    if (colDelta.abs() >= rowDelta.abs() && colDelta != 0) {
      return colDelta > 0 ? MoveDirection.right : MoveDirection.left;
    }
    return rowDelta > 0 ? MoveDirection.down : MoveDirection.up;
  }

  List<int> _availableContinuations({
    required int from,
    required int sum,
    required List<int> path,
    required Set<int> destroyed,
    required Set<int> visitedIndices,
  }) {
    final level = _gameState.level;
    final n = level.gridSize;
    final row = from ~/ n;
    final col = from % n;
    const offsets = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    return offsets
        .map((offset) => (row + offset.$1, col + offset.$2))
        .where(
          (cell) => cell.$1 >= 0 && cell.$1 < n && cell.$2 >= 0 && cell.$2 < n,
        )
        .map((cell) => cell.$1 * n + cell.$2)
        .where(
          (index) =>
              !path.contains(index) &&
              !destroyed.contains(index) &&
              level.tiles[index].isWalkable &&
              level.canEnterTile(index, sum, visitedIndices) &&
              (index != level.centerIndex || sum == level.targetNumber),
        )
        .toList();
  }

  @override
  void dispose() {
    _solutionPlaybackId++;
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_usesChallengeTimer || !_gameState.hasStarted || _gameState.isWon) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _startCountdown();
    } else {
      _countdownTimer?.cancel();
    }
  }

  void _startCountdown() {
    if (!_usesChallengeTimer ||
        _gameState.isWon ||
        _gameState.isFailed ||
        (_remainingSeconds ?? 0) <= 0 ||
        _countdownTimer?.isActive == true) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final next = (_remainingSeconds ?? 0) - 1;
      setState(() => _remainingSeconds = next.clamp(0, 999));
      if (next == 10) {
        widget.sound.timerWarning();
      } else if (next > 0 && next <= 3) {
        widget.sound.timerFinalTick();
      }
      if (next <= 0) {
        timer.cancel();
        widget.sound.timeUp();
        setState(() => _gameState = _gameState.copyWith(isFailed: true));
        _showTimeoutDialog();
      }
    });
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = _gameState.level.challengeTimeSeconds;
  }

  void _loadLevel(LevelModel level) {
    _solutionPlaybackId++;
    _countdownTimer?.cancel();
    setState(() {
      _gameState = GameState(level: level);
      _remainingSeconds = level.challengeTimeSeconds;
    });
    if (widget.showSpecialIntroductions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUnseenSpecialIntroductions(level);
      });
    }
  }

  int _sumForPath(List<int> path, Map<int, int> jokerChoices) {
    var sum = 0;
    for (final index in path) {
      if (index == _gameState.level.centerIndex) continue;
      final tile = _gameState.level.tiles[index];
      final choice = jokerChoices[index];
      sum = choice == null
          ? tile.applyValue(sum)
          : tile.applyJokerChoice(sum, choice);
    }
    return sum;
  }

  GameState get _panelState {
    final solution = _gameState.activeSolutionRoute;
    if (solution == null || solution.isEmpty) return _gameState;
    final lastStep = _gameState.solverStepIndex.clamp(0, solution.length - 1);
    final visiblePath = solution.take(lastStep + 1).toList(growable: false);
    return _gameState.copyWith(
      currentPath: visiblePath,
      currentSum: _sumForPath(visiblePath, const {}),
      moves: _solutionMoveCount(visiblePath),
      isWon: lastStep == solution.length - 1,
    );
  }

  int _solutionMoveCount(List<int> path) {
    if (path.isEmpty) return 0;
    var moves = 1;
    for (var i = 1; i < path.length; i++) {
      final previous = _gameState.level.tiles[path[i - 1]];
      final isAutomaticTeleport =
          previous.isTrampoline &&
          _gameState.level.pairedTeleportIndex(path[i - 1]) == path[i];
      final isAutomaticIceContinuation = previous.isIce;
      if (!isAutomaticTeleport && !isAutomaticIceContinuation) moves++;
    }
    return moves;
  }

  Future<int?> _chooseJoker(TileModel tile, int currentSum) {
    final options = tile.jokerOptions;
    if (options.isEmpty) return Future<int?>.value(0);
    widget.sound.jokerReveal();
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(AppLocalizations.of(context).jokerChoice),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final option in options)
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(option),
                child: Text('+$option  →  ${currentSum + option}'),
              ),
          ],
        ),
      ),
    ).then((choice) {
      if (choice != null) widget.sound.jokerChoose();
      return choice;
    });
  }

  List<int> _iceSlide({
    required int from,
    required int firstIce,
    required List<int> currentPath,
  }) {
    final level = _gameState.level;
    final n = level.gridSize;
    final delta = firstIce - from;
    final slide = <int>[firstIce];
    var current = firstIce;
    while (level.tiles[current].isIce) {
      final next = current + delta;
      final remainsOnBoard =
          next >= 0 &&
          next < level.tiles.length &&
          (delta.abs() != 1 || next ~/ n == current ~/ n);
      if (!remainsOnBoard ||
          currentPath.contains(next) ||
          _gameState.destroyedIndices.contains(next) ||
          _gameState.blackHoledIndices.contains(next) ||
          !level.tiles[next].isWalkable) {
        break;
      }
      slide.add(next);
      current = next;
    }
    return slide;
  }

  Future<void> _handleTileTap(int clickedIndex) async {
    _solutionPlaybackId++;
    if (_gameState.isWon || _gameState.isFailed) return;
    if (_gameState.activeSolutionRoute != null) {
      _gameState = _gameState.copyWith(clearSolution: true, solverStepIndex: 0);
    }

    final level = _gameState.level;
    final n = level.gridSize;
    final currentPath = List<int>.from(_gameState.currentPath);
    final clickedTile = level.tiles[clickedIndex];
    final centerIndex = level.centerIndex;

    // 1. Initial Start Point Selection
    if (currentPath.isEmpty) {
      if (clickedTile.isStart) {
        widget.sound.startTile();
        final initialSum = clickedTile.applyValue(0);
        setState(() {
          _gameState = _gameState.copyWith(
            currentPath: [clickedIndex],
            visitedIndices: {clickedIndex},
            currentSum: initialSum,
            moves: 1,
            runnerTeleported: false,
            clearHint: true,
            clearStatusMessage: true,
          );
        });
        _startCountdown();
      } else {
        widget.sound.invalidMove();
        _showStatusSnackbar(AppLocalizations.of(context).startRequired);
      }
      return;
    }

    final prevIndex = currentPath.last;

    // 2. Backtracking: Tapping a tile already in the current path
    if (currentPath.contains(clickedIndex)) {
      if (clickedIndex == prevIndex) {
        // Tapped the current head; no-op
        return;
      }
      widget.sound.tileBacktrack();
      final idx = currentPath.indexOf(clickedIndex);
      final truncatedPath = currentPath.sublist(0, idx + 1);

      final jokerChoices = Map<int, int>.from(_gameState.jokerChoices)
        ..removeWhere((index, _) => !truncatedPath.contains(index));
      final recalculatedSum = _sumForPath(truncatedPath, jokerChoices);

      setState(() {
        _gameState = _gameState.copyWith(
          currentPath: truncatedPath,
          currentSum: recalculatedSum,
          runnerDirection: _facingFrom(prevIndex, clickedIndex, n),
          runnerTeleported: false,
          jokerChoices: jokerChoices,
          clearAllowedNext: true,
          clearHint: true,
          clearStatusMessage: true,
        );
      });
      return;
    }

    // 3. Forward Step: Must be adjacent (orthogonal)
    final prevRow = prevIndex ~/ n;
    final prevCol = prevIndex % n;
    final clickedRow = clickedIndex ~/ n;
    final clickedCol = clickedIndex % n;

    final isOrthogonal =
        (prevRow == clickedRow && (prevCol - clickedCol).abs() == 1) ||
        (prevCol == clickedCol && (prevRow - clickedRow).abs() == 1);

    if (!isOrthogonal) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).adjacentOnly);
      return;
    }

    if (_gameState.destroyedIndices.contains(clickedIndex) ||
        _gameState.blackHoledIndices.contains(clickedIndex) ||
        (_gameState.allowedNextIndices.isNotEmpty &&
            !_gameState.allowedNextIndices.contains(clickedIndex))) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).specialBlocked);
      return;
    }

    // 4. Validate Tile Walkability / Special Rules
    if (!clickedTile.isWalkable) {
      widget.sound.wallBlocked();
      _showStatusSnackbar(AppLocalizations.of(context).wallBlocked);
      return;
    }

    if (!clickedTile.canEnter(_gameState.currentSum)) {
      widget.sound.gateBlocked();
      _showStatusSnackbar(AppLocalizations.of(context).gateBlocked);
      return;
    }

    if (!level.isLonelyUnlocked(clickedIndex, _gameState.visitedIndices)) {
      widget.sound.lonelyBlocked();
      _showStatusSnackbar(AppLocalizations.of(context).lonelyBlocked);
      return;
    }

    int? jokerChoice;
    if (clickedTile.isJoker) {
      jokerChoice = await _chooseJoker(clickedTile, _gameState.currentSum);
      if (!mounted || jokerChoice == null) return;
    }

    final teleportDestination = clickedTile.isTrampoline
        ? level.pairedTeleportIndex(clickedIndex)
        : null;
    if (teleportDestination != null &&
        currentPath.contains(teleportDestination)) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).specialBlocked);
      return;
    }
    if (teleportDestination != null &&
        !level.isLonelyUnlocked(teleportDestination, {
          ..._gameState.visitedIndices,
          clickedIndex,
        })) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).lonelyBlocked);
      return;
    }

    // The center is a finish line, not an intermediate square. Reaching the
    // required sum elsewhere does not complete the level.
    if (clickedIndex == centerIndex &&
        _gameState.currentSum != level.targetNumber) {
      widget.sound.invalidMove();
      _showStatusSnackbar(
        AppLocalizations.of(
          context,
        ).wrongTarget(_gameState.currentSum, level.targetNumber),
      );
      return;
    }

    // Sound / Haptic cues for special tiles
    if (clickedTile.isTrampoline) {
      widget.sound.trampolineBounce();
    } else if (clickedTile.isSmartGate) {
      widget.sound.gatePass();
    } else if (clickedTile.isJoker) {
      // Reveal/choice sounds are emitted by the chooser dialog.
    } else if (clickedTile.isIce) {
      widget.sound.iceSlide();
    } else if (clickedTile.isMirror) {
      widget.sound.mirror();
    } else if (clickedTile.isClone) {
      widget.sound.clone();
    } else if (clickedTile.isZero) {
      widget.sound.zero();
    } else if (clickedTile.isBlackHole) {
      widget.sound.blackHole();
    } else if (clickedTile.isBomb) {
      widget.sound.bomb();
    } else if (clickedTile.isLonely) {
      widget.sound.lonelyUnlock();
    } else {
      widget.sound.tileTap();
    }

    final slide = clickedTile.isIce
        ? _iceSlide(
            from: prevIndex,
            firstIce: clickedIndex,
            currentPath: currentPath,
          )
        : <int>[clickedIndex];

    final moveVisitHistory = Set<int>.from(_gameState.visitedIndices);
    for (final index in slide) {
      if (!level.isLonelyUnlocked(index, moveVisitHistory)) {
        widget.sound.invalidMove();
        _showStatusSnackbar(AppLocalizations.of(context).lonelyBlocked);
        return;
      }
      moveVisitHistory.add(index);
    }
    if (teleportDestination != null) {
      moveVisitHistory.add(teleportDestination);
    }

    final jokerChoices = Map<int, int>.from(_gameState.jokerChoices);
    if (jokerChoice != null) jokerChoices[clickedIndex] = jokerChoice;

    // Apply every value crossed by an ice slide. Ice itself is normally zero;
    // the first non-ice stop cell contributes its configured value.
    int newSum = _gameState.currentSum;
    for (final index in slide) {
      if (index == centerIndex) continue;
      final tile = level.tiles[index];
      final choice = jokerChoices[index];
      newSum = choice == null
          ? tile.applyValue(newSum)
          : tile.applyJokerChoice(newSum, choice);
    }

    final landingIndex = teleportDestination ?? slide.last;
    if (landingIndex == centerIndex && newSum != level.targetNumber) {
      widget.sound.invalidMove();
      _showStatusSnackbar(
        AppLocalizations.of(context).wrongTarget(newSum, level.targetNumber),
      );
      return;
    }
    final newPath = [...currentPath, ...slide, ?teleportDestination];
    final newMoves = _gameState.moves + 1;
    var destroyed = Set<int>.from(_gameState.destroyedIndices);
    Set<int> allowedNext = {};
    final blackHoled = Set<int>.from(_gameState.blackHoledIndices);
    final candidates = _availableContinuations(
      from: landingIndex,
      sum: newSum,
      path: newPath,
      destroyed: {...destroyed, ...blackHoled},
      visitedIndices: moveVisitHistory,
    );
    if (clickedTile.isBlackHole && candidates.isNotEmpty) {
      final keptIndex = candidates[_random.nextInt(candidates.length)];
      allowedNext = {keptIndex};
      blackHoled.addAll(candidates.where((index) => index != keptIndex));
    } else if (clickedTile.isBomb && candidates.isNotEmpty) {
      final destructible = candidates
          .where((index) => index != centerIndex)
          .toList();
      if (destructible.isNotEmpty) {
        destroyed.add(destructible[_random.nextInt(destructible.length)]);
      }
    }

    // Check center destination condition
    if (landingIndex == centerIndex) {
      _countdownTimer?.cancel();
      widget.sound.targetReached();
      widget.sound.victory();
      setState(() {
        _gameState = _gameState.copyWith(
          currentPath: newPath,
          currentSum: newSum,
          runnerDirection: _facingFrom(prevIndex, clickedIndex, n),
          runnerTeleported: teleportDestination != null,
          moves: newMoves,
          isWon: true,
          destroyedIndices: destroyed,
          allowedNextIndices: allowedNext,
          blackHoledIndices: blackHoled,
          jokerChoices: jokerChoices,
          visitedIndices: moveVisitHistory,
          clearHint: true,
        );
      });
      _onVictory(newMoves);
      return;
    }

    setState(() {
      _gameState = _gameState.copyWith(
        currentPath: newPath,
        currentSum: newSum,
        runnerDirection: _facingFrom(prevIndex, clickedIndex, n),
        runnerTeleported: teleportDestination != null,
        destroyedIndices: destroyed,
        allowedNextIndices: allowedNext,
        blackHoledIndices: blackHoled,
        jokerChoices: jokerChoices,
        visitedIndices: moveVisitHistory,
        moves: newMoves,
        clearHint: true,
        clearStatusMessage: true,
      );
    });
  }

  void _onVictory(int moves) async {
    final level = _gameState.level;
    final allLevels = CampaignLevels.getAllLevels();
    final currentIndex = allLevels.indexWhere((l) => l.id == level.id);

    LevelModel? nextLevel;
    if (currentIndex != -1 && currentIndex < allLevels.length - 1) {
      nextLevel = allLevels[currentIndex + 1];
    }

    final stars = await widget.storage.recordCompletion(
      levelId: level.id,
      moves: moves,
      parMoves: level.parMoves,
      nextLevelId: nextLevel?.id,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VictoryDialog(
        stars: stars,
        moves: moves,
        parMoves: level.parMoves,
        targetSum: level.targetNumber,
        hasNextLevel: nextLevel != null,
        onNextLevel: () {
          Navigator.of(ctx).pop();
          if (nextLevel != null) {
            Navigator.of(context).pop();
          }
        },
        onReplay: () {
          Navigator.of(ctx).pop();
          _loadLevel(level);
        },
        onLevelSelect: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _undoStep() {
    if (_gameState.currentPath.isEmpty) return;
    widget.sound.tileBacktrack();
    final newPath = List<int>.from(_gameState.currentPath);
    final removedIndex = newPath.removeLast();
    if (_gameState.level.tiles[removedIndex].isTrampoline &&
        newPath.isNotEmpty &&
        _gameState.level.tiles[newPath.last].isTrampoline &&
        _gameState.level.pairedTeleportIndex(removedIndex) == newPath.last) {
      newPath.removeLast();
    }
    while (newPath.isNotEmpty && _gameState.level.tiles[newPath.last].isIce) {
      newPath.removeLast();
    }
    final fromIndex = _gameState.currentPath.last;

    final jokerChoices = Map<int, int>.from(_gameState.jokerChoices)
      ..removeWhere((index, _) => !newPath.contains(index));
    final recalculatedSum = _sumForPath(newPath, jokerChoices);

    setState(() {
      _gameState = _gameState.copyWith(
        currentPath: newPath,
        currentSum: recalculatedSum,
        moves: max(0, _gameState.moves - 1),
        runnerDirection: newPath.isEmpty
            ? MoveDirection.down
            : _facingFrom(fromIndex, newPath.last, _gameState.level.gridSize),
        runnerTeleported: false,
        jokerChoices: jokerChoices,
        clearAllowedNext: true,
        clearHint: true,
      );
    });
  }

  void _resetGame() {
    _solutionPlaybackId++;
    widget.sound.reset();
    _resetCountdown();
    setState(() {
      _gameState = GameState(level: _gameState.level);
    });
  }

  void _requestHint() {
    if (!widget.mode.allowsHints) return;

    final nextHint = PathSolver.getNextStepHint(
      level: _gameState.level,
      currentPath: _gameState.currentPath,
      currentSum: _gameState.currentSum,
      visitedIndices: _gameState.visitedIndices,
    );

    final backtrackHint = nextHint == null && _gameState.currentPath.length > 1
        ? _gameState.currentPath[_gameState.currentPath.length - 2]
        : null;
    final effectiveHint = nextHint ?? backtrackHint;

    if (effectiveHint != null) {
      widget.sound.hint();
      setState(() {
        _gameState = _gameState.copyWith(nextHintIndex: effectiveHint);
      });
      _showStatusSnackbar(AppLocalizations.of(context).hintShown);
    } else {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).noValidPath);
    }
  }

  void _openSolver() {
    if (!widget.mode.allowsSolutions) return;

    widget.sound.solutionReveal();

    showDialog(
      context: context,
      builder: (ctx) => SolverDialog(
        level: _gameState.level,
        onPreviewSolution: (solution, stepIndex) {
          if (!mounted) return;
          setState(() {
            _gameState = _gameState.copyWith(
              activeSolutionRoute: solution,
              solverStepIndex: stepIndex,
              clearHint: true,
            );
          });
        },
        onApplySolution: _animateSolution,
      ),
    );
  }

  Future<void> _animateSolution(List<int> solution) async {
    if (solution.isEmpty) return;
    final playbackId = ++_solutionPlaybackId;
    final level = _gameState.level;
    _countdownTimer?.cancel();
    setState(() {
      // A guided solution is a fresh demonstration. Clear the player's
      // pressed path and every derived board effect before drawing it.
      _gameState = GameState(
        level: level,
      ).copyWith(activeSolutionRoute: solution, solverStepIndex: 0);
      _remainingSeconds = level.challengeTimeSeconds;
    });

    for (var step = 1; step < solution.length; step++) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted || playbackId != _solutionPlaybackId) return;
      setState(() {
        _gameState = _gameState.copyWith(
          activeSolutionRoute: solution,
          solverStepIndex: step,
        );
      });
      widget.sound.solutionStep();
    }
    if (!mounted || playbackId != _solutionPlaybackId) return;
    await _showSolutionFinishedDialog();
  }

  Future<void> _showSolutionFinishedDialog() async {
    final strings = AppLocalizations.of(context);
    final allLevels = CampaignLevels.getAllLevels();
    final currentIndex = allLevels.indexWhere(
      (level) => level.id == _gameState.level.id,
    );
    final nextLevel = currentIndex >= 0 && currentIndex < allLevels.length - 1
        ? allLevels[currentIndex + 1]
        : null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(strings.solutionFinished),
        content: Text(strings.solutionFinishedQuestion),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetGame();
            },
            icon: const Icon(Icons.replay_rounded),
            label: Text(strings.tryThisLevel),
          ),
          if (nextLevel != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.map_rounded),
              label: Text(strings.levelMap),
            ),
        ],
      ),
    );
  }

  void _showStatusSnackbar(String message) {
    if (_messageDialogVisible) return;
    _messageDialogVisible = true;
    unawaited(
      showBezyMessageDialog(
        context,
        message: message,
        sound: widget.sound,
      ).whenComplete(() {
        _messageDialogVisible = false;
      }),
    );
  }

  void _showTimeoutDialog() {
    final strings = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(strings.timeUp),
        content: Text(strings.timeUpDescription),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetGame();
            },
            icon: const Icon(Icons.replay_rounded),
            label: Text(strings.tryAgain),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _gameState.level;
    final strings = AppLocalizations.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isLandscape ? 48 : null,
        title: Column(
          children: [
            Text(
              strings.levelTitle(
                level.id,
                level.title,
                gridSize: level.gridSize,
              ),
              style: TextStyle(
                fontSize: isLandscape ? 17 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              strings.worldTitle(level.worldId, level.worldTitle),
              style: TextStyle(
                fontSize: isLandscape ? 12 : 16,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: strings.resetBoard,
            onPressed: _resetGame,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: strings.instructions,
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            if (isLandscape) {
              final infoWidth = min(270.0, constraints.maxWidth * 0.32);
              return Row(
                children: [
                  Expanded(child: _buildBoardArea()),
                  SizedBox(
                    width: infoWidth,
                    child: Column(
                      children: [
                        Expanded(
                          child: StatsBar(state: _panelState, landscape: true),
                        ),
                        if (_usesChallengeTimer) _buildChallengeStrip(),
                        _buildBottomControls(compact: true),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                StatsBar(state: _panelState),
                if (_usesChallengeTimer) _buildChallengeStrip(),
                Expanded(child: _buildBoardArea()),
                _buildBottomControls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardArea() {
    return Column(
      children: [
        Expanded(child: _buildBoard()),
        const _BezyMark(),
      ],
    );
  }

  Widget _buildChallengeStrip() {
    final strings = AppLocalizations.of(context);
    final seconds = _remainingSeconds ?? 0;
    final urgent = seconds <= 10;
    final best = widget.storage.getBestMoves(_gameState.level.id);
    final optimal = _gameState.level.optimalMoves;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: urgent ? AppTheme.targetPink : AppTheme.pathCyan,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_rounded,
            color: urgent ? AppTheme.targetPink : AppTheme.pathCyan,
          ),
          const SizedBox(width: 6),
          Text(
            '0:${seconds.toString().padLeft(2, '0')}',
            key: const ValueKey('challenge-countdown'),
            style: TextStyle(
              color: urgent ? AppTheme.targetPink : AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              best == null
                  ? strings.minimumMovesChallenge(_gameState.moves)
                  : strings.minimumMovesRevealed(
                      _gameState.moves,
                      optimal ?? _gameState.level.parMoves,
                    ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return BoardWidget(
            state: _gameState,
            onTileTap: _handleTileTap,
            pulsePhase: _pulseController.value,
          );
        },
      ),
    );
  }

  Widget _buildBottomControls({bool compact = false}) {
    final strings = AppLocalizations.of(context);
    final controls = <Widget>[
      _ControlButton(
        icon: Icons.undo_rounded,
        label: strings.undo,
        onTap: _gameState.currentPath.isNotEmpty ? _undoStep : null,
        compact: compact,
      ),
      _ControlButton(
        icon: Icons.restart_alt_rounded,
        label: strings.reset,
        onTap: _gameState.currentPath.isNotEmpty ? _resetGame : null,
        compact: compact,
      ),
      if (widget.mode.allowsHints)
        _ControlButton(
          icon: Icons.tips_and_updates_rounded,
          label: strings.smartHint,
          color: AppTheme.gold,
          onTap: _requestHint,
          compact: compact,
        ),
      if (widget.mode.allowsSolutions)
        _ControlButton(
          icon: Icons.auto_awesome_rounded,
          label: strings.guidedSolution,
          color: AppTheme.pathCyan,
          onTap: _openSolver,
          compact: compact,
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 16,
        vertical: compact ? 4 : 12,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controls,
      ),
    );
  }

  void _showHelpDialog() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(strings.howToPlay),
        content: SingleChildScrollView(
          child: Text(
            strings.compactGameHelp,
            style: const TextStyle(height: 1.5, color: AppTheme.textPrimary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.letsPlay),
          ),
        ],
      ),
    );
  }
}

class _BezyMark extends StatelessWidget {
  const _BezyMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BEZY',
      image: true,
      child: Container(
        key: const ValueKey('bezy-board-mark'),
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.pathCyan, width: 1.2),
        ),
        child: const Text(
          'BEZY',
          style: TextStyle(
            color: AppTheme.pathCyan,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool compact;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color = AppTheme.textPrimary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final activeColor = isEnabled ? color : AppTheme.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 10,
          vertical: compact ? 2 : 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: compact ? 20 : 24),
            SizedBox(height: compact ? 1 : 4),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 54 : 90),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: compact ? 11 : 15,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
