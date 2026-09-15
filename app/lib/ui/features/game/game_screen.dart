import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_state.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/level_model.dart';
import '../../../domain/solver/path_solver.dart';
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
        _showStatusSnackbar('עליכם להתחיל מאחת ממשבצות ההתחלה הירוקות');
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
      _showStatusSnackbar(
        'ניתן לנוע רק למשבצת סמוכה (מעלה, מטה, ימינה או שמאלה)',
      );
      return;
    }

    // 4. Validate Tile Walkability / Special Rules
    if (!clickedTile.isWalkable) {
      widget.sound.invalidMove();
      _showStatusSnackbar('אי אפשר לעבור דרך חומת אבן!');
      return;
    }

    if (!clickedTile.canEnter(_gameState.currentSum)) {
      widget.sound.invalidMove();
      _showStatusSnackbar('השער החכם נעול! דרוש סכום זוגי למעבר');
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
          'הסכום הנוכחי ($newSum) אינו תואם ליעד (${level.targetNumber})! חזרו אחורה',
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
      _showStatusSnackbar('רמז חכם: המשבצת המומלצת הבאה מהבהבת בזהב!');
    } else {
      widget.sound.invalidMove();
      _showStatusSnackbar(
        'אין מסלול תקף מהמצב הנוכחי - לחצו על ביטול צעד וחזרו אחורה!',
      );
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                level.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                level.worldTitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'איפוס לוח',
              onPressed: _resetGame,
            ),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded),
              tooltip: 'הוראות',
              onPressed: _showHelpDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Stats indicator
              StatsBar(state: _gameState),

              // Interactive Board with Pulse Animation
              Expanded(
                child: Padding(
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
                ),
              ),

              // Bottom Control Buttons
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo Step
          _ControlButton(
            icon: Icons.undo_rounded,
            label: 'ביטול צעד',
            onTap: _gameState.currentPath.isNotEmpty ? _undoStep : null,
          ),

          // Reset
          _ControlButton(
            icon: Icons.restart_alt_rounded,
            label: 'איפוס',
            onTap: _gameState.currentPath.isNotEmpty ? _resetGame : null,
          ),

          if (widget.mode.allowsHints)
            _ControlButton(
              icon: Icons.tips_and_updates_rounded,
              label: 'רמז חכם',
              color: AppTheme.gold,
              onTap: _requestHint,
            ),

          if (widget.mode.allowsSolutions)
            _ControlButton(
              icon: Icons.auto_awesome_rounded,
              label: 'פתרון חכם',
              color: AppTheme.pathCyan,
              onTap: _openSolver,
            ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('איך משחקים?', textAlign: TextAlign.right),
        content: const SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              '1. התחילו מאחת ממשבצות ההתחלה בירוק.\n'
              '2. התקדמו למשבצת סמוכה (מעלה, מטה, ימינה או שמאלה).\n'
              '3. כל משבצת מוסיפה את ערכה לסכום המצטבר.\n'
              '4. חומות אבן חוסמות את המעבר.\n'
              '5. מקפצות מעניקות בונוס זינוק לסכום.\n'
              '6. שערים חכמים נפתחים רק כאשר עומדים בתנאי (כגון סכום זוגי).\n'
              '7. המטרה: להגיע למשבצת היעד במרכז עם סכום מדויק!',
              style: TextStyle(height: 1.5, color: AppTheme.textPrimary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('הבנתי, בוא נשחק!'),
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
