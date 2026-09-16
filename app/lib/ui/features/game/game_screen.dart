import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_state.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/level_model.dart';
import '../../../domain/solver/path_solver.dart';
import '../../../l10n/app_localizations.dart';
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

  const GameScreen({
    super.key,
    required this.initialLevel,
    required this.storage,
    required this.sound,
    required this.mode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameState _gameState;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(level: widget.initialLevel);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadLevel(LevelModel level) {
    setState(() {
      _gameState = GameState(level: level);
    });
  }

  void _handleTileTap(int clickedIndex) {
    if (_gameState.isWon) return;

    final level = _gameState.level;
    final n = level.gridSize;
    final currentPath = List<int>.from(_gameState.currentPath);
    final clickedTile = level.tiles[clickedIndex];
    final centerIndex = level.centerIndex;

    // 1. Initial Start Point Selection
    if (currentPath.isEmpty) {
      if (clickedTile.isStart) {
        widget.sound.tileTap();
        final initialSum = clickedTile.applyValue(0);
        setState(() {
          _gameState = _gameState.copyWith(
            currentPath: [clickedIndex],
            currentSum: initialSum,
            moves: 1,
            clearHint: true,
            clearStatusMessage: true,
          );
        });
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

      // Recalculate sum from scratch along the truncated path
      var recalculatedSum = 0;
      for (final stepIndex in truncatedPath) {
        if (stepIndex != centerIndex) {
          recalculatedSum = level.tiles[stepIndex].applyValue(recalculatedSum);
        }
      }

      setState(() {
        _gameState = _gameState.copyWith(
          currentPath: truncatedPath,
          currentSum: recalculatedSum,
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

    // 4. Validate Tile Walkability / Special Rules
    if (!clickedTile.isWalkable) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).wallBlocked);
      return;
    }

    if (!clickedTile.canEnter(_gameState.currentSum)) {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).gateBlocked);
      return;
    }

    // Sound / Haptic cues for special tiles
    if (clickedTile.isTrampoline) {
      widget.sound.trampolineBounce();
    } else if (clickedTile.isSmartGate) {
      widget.sound.gatePass();
    } else {
      widget.sound.tileTap();
    }

    // Apply value
    int newSum = _gameState.currentSum;
    if (clickedIndex != centerIndex) {
      newSum = clickedTile.applyValue(newSum);
    }

    final newPath = [...currentPath, clickedIndex];
    final newMoves = _gameState.moves + 1;

    // Check center destination condition
    if (clickedIndex == centerIndex) {
      if (newSum == level.targetNumber) {
        // Victory!
        widget.sound.victory();
        setState(() {
          _gameState = _gameState.copyWith(
            currentPath: newPath,
            currentSum: newSum,
            moves: newMoves,
            isWon: true,
            clearHint: true,
          );
        });
        _onVictory(newMoves);
        return;
      } else {
        widget.sound.invalidMove();
        setState(() {
          _gameState = _gameState.copyWith(
            currentPath: newPath,
            currentSum: newSum,
            moves: newMoves,
            clearHint: true,
          );
        });
        _showStatusSnackbar(
          AppLocalizations.of(context).wrongTarget(newSum, level.targetNumber),
        );
        return;
      }
    }

    setState(() {
      _gameState = _gameState.copyWith(
        currentPath: newPath,
        currentSum: newSum,
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
            _loadLevel(nextLevel);
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
    final newPath = List<int>.from(_gameState.currentPath)..removeLast();

    var recalculatedSum = 0;
    for (final stepIndex in newPath) {
      if (stepIndex != _gameState.level.centerIndex) {
        recalculatedSum = _gameState.level.tiles[stepIndex].applyValue(
          recalculatedSum,
        );
      }
    }

    setState(() {
      _gameState = _gameState.copyWith(
        currentPath: newPath,
        currentSum: recalculatedSum,
        clearHint: true,
      );
    });
  }

  void _resetGame() {
    widget.sound.tileBacktrack();
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
    );

    if (nextHint != null) {
      widget.sound.tileTap();
      setState(() {
        _gameState = _gameState.copyWith(nextHintIndex: nextHint);
      });
      _showStatusSnackbar(AppLocalizations.of(context).hintShown);
    } else {
      widget.sound.invalidMove();
      _showStatusSnackbar(AppLocalizations.of(context).noValidPath);
    }
  }

  void _openSolver() {
    if (!widget.mode.allowsSolutions) return;

    showDialog(
      context: context,
      builder: (ctx) => SolverDialog(
        level: _gameState.level,
        onApplySolution: (solution) {
          // Replay solution onto board
          var s = 0;
          for (final idx in solution) {
            if (idx != _gameState.level.centerIndex) {
              s = _gameState.level.tiles[idx].applyValue(s);
            }
          }
          setState(() {
            _gameState = _gameState.copyWith(
              currentPath: solution,
              currentSum: s,
              moves: solution.length,
              isWon: s == _gameState.level.targetNumber,
              clearHint: true,
            );
          });
          if (s == _gameState.level.targetNumber) {
            _onVictory(solution.length);
          }
        },
      ),
    );
  }

  void _showStatusSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _gameState.level;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              strings.levelTitle(
                level.id,
                level.title,
                gridSize: level.gridSize,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              strings.worldTitle(level.worldId, level.worldTitle),
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
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
              return Column(
                children: [
                  StatsBar(state: _gameState),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildBoard()),
                        SizedBox(
                          width: 250,
                          child: _buildBottomControls(wrap: true),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                StatsBar(state: _gameState),
                Expanded(child: _buildBoard()),
                _buildBottomControls(),
              ],
            );
          },
        ),
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

  Widget _buildBottomControls({bool wrap = false}) {
    final strings = AppLocalizations.of(context);
    final controls = <Widget>[
      _ControlButton(
        icon: Icons.undo_rounded,
        label: strings.undo,
        onTap: _gameState.currentPath.isNotEmpty ? _undoStep : null,
      ),
      _ControlButton(
        icon: Icons.restart_alt_rounded,
        label: strings.reset,
        onTap: _gameState.currentPath.isNotEmpty ? _resetGame : null,
      ),
      if (widget.mode.allowsHints)
        _ControlButton(
          icon: Icons.tips_and_updates_rounded,
          label: strings.smartHint,
          color: AppTheme.gold,
          onTap: _requestHint,
        ),
      if (widget.mode.allowsSolutions)
        _ControlButton(
          icon: Icons.auto_awesome_rounded,
          label: strings.guidedSolution,
          color: AppTheme.pathCyan,
          onTap: _openSolver,
        ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: wrap
          ? Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 16,
              children: controls,
            )
          : Row(
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final activeColor = isEnabled ? color : AppTheme.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
