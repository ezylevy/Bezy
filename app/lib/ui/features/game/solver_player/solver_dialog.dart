import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/level_model.dart';
import '../../../../domain/models/tile_model.dart';
import '../../../../domain/solver/path_solver.dart';
import '../../../../l10n/app_localizations.dart';

/// An intelligent step-by-step solver player that explains the math and progression.
class SolverDialog extends StatefulWidget {
  final LevelModel level;
  final Function(List<int> solutionPath) onApplySolution;

  const SolverDialog({
    super.key,
    required this.level,
    required this.onApplySolution,
  });

  @override
  State<SolverDialog> createState() => _SolverDialogState();
}

class _SolverDialogState extends State<SolverDialog> {
  List<int>? _solutionPath;
  List<StepBreakdown> _breakdowns = [];
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  final int _playbackSpeedMs = 800;
  bool _hasComputedSolution = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasComputedSolution) {
      _hasComputedSolution = true;
      _computeSolution();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _computeSolution() {
    final sol = PathSolver.findSolution(widget.level);
    if (sol == null || sol.isEmpty) {
      _solutionPath = null;
      return;
    }

    _solutionPath = sol;
    _breakdowns = _generateBreakdowns(sol);
    _currentStepIndex = 0;
  }

  List<StepBreakdown> _generateBreakdowns(List<int> path) {
    final strings = AppLocalizations.of(context);
    final list = <StepBreakdown>[];
    var runningSum = 0;

    for (var i = 0; i < path.length; i++) {
      final tileIndex = path[i];
      final tile = widget.level.tiles[tileIndex];

      if (i == 0) {
        runningSum = tile.applyValue(0);
        list.add(
          StepBreakdown(
            step: i + 1,
            tileIndex: tileIndex,
            actionName: strings.solverStartPoint,
            formula: strings.openingTotal(runningSum),
            runningSum: runningSum,
            tileType: tile.type,
            icon: Icons.play_circle_fill_rounded,
            color: AppTheme.startGreen,
          ),
        );
      } else if (tile.isTarget) {
        list.add(
          StepBreakdown(
            step: i + 1,
            tileIndex: tileIndex,
            actionName: strings.solverReachedTarget,
            formula: strings.targetMatched(
              runningSum,
              widget.level.targetNumber,
            ),
            runningSum: runningSum,
            tileType: tile.type,
            icon: Icons.emoji_events_rounded,
            color: AppTheme.targetPink,
          ),
        );
      } else if (tile.isTrampoline) {
        final bonus = tile.metadata['bonus'] as int? ?? 2;
        final prev = runningSum;
        runningSum = tile.applyValue(runningSum);
        list.add(
          StepBreakdown(
            step: i + 1,
            tileIndex: tileIndex,
            actionName: strings.solverLaunchPad,
            formula: strings.bonusFormula(prev, tile.value, bonus, runningSum),
            runningSum: runningSum,
            tileType: tile.type,
            icon: Icons.bolt_rounded,
            color: AppTheme.trampolineOrange,
          ),
        );
      } else if (tile.isSmartGate) {
        final prev = runningSum;
        runningSum = tile.applyValue(runningSum);
        list.add(
          StepBreakdown(
            step: i + 1,
            tileIndex: tileIndex,
            actionName: strings.solverGate,
            formula: '$prev + ${tile.value} = $runningSum',
            runningSum: runningSum,
            tileType: tile.type,
            icon: Icons.lock_open_rounded,
            color: AppTheme.smartGatePurple,
          ),
        );
      } else {
        final prev = runningSum;
        runningSum = tile.applyValue(runningSum);
        list.add(
          StepBreakdown(
            step: i + 1,
            tileIndex: tileIndex,
            actionName: strings.solverNextStep,
            formula: '$prev + ${tile.value} = $runningSum',
            runningSum: runningSum,
            tileType: tile.type,
            icon: Icons.add_circle_outline_rounded,
            color: AppTheme.pathCyan,
          ),
        );
      }
    }
    return list;
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() => _isPlaying = true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(Duration(milliseconds: _playbackSpeedMs), (
      _,
    ) {
      if (_currentStepIndex < _breakdowns.length - 1) {
        setState(() => _currentStepIndex++);
      } else {
        _stopPlayback();
      }
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _stepForward() {
    _stopPlayback();
    if (_currentStepIndex < _breakdowns.length - 1) {
      setState(() => _currentStepIndex++);
    }
  }

  void _stepBackward() {
    _stopPlayback();
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    if (_solutionPath == null) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          strings.noSolution,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          strings.noSolutionDescription,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              strings.close,
              style: const TextStyle(color: AppTheme.pathCyan),
            ),
          ),
        ],
      );
    }

    final currentBreakdown = _breakdowns[_currentStepIndex];

    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.solverTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Step Progress Indicator
            LinearProgressIndicator(
              value: (_currentStepIndex + 1) / _breakdowns.length,
              backgroundColor: AppTheme.surfaceElevated,
              color: AppTheme.gold,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 6),
            Text(
              strings.stepProgress(_currentStepIndex + 1, _breakdowns.length),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Active Step Math Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: currentBreakdown.color.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentBreakdown.color.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        currentBreakdown.icon,
                        color: currentBreakdown.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentBreakdown.actionName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: currentBreakdown.color,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        strings.sumValue(currentBreakdown.runningSum),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentBreakdown.formula,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Media Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 30),
                  color: _currentStepIndex > 0
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  onPressed: _currentStepIndex > 0 ? _stepBackward : null,
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 32,
                    ),
                    onPressed: _togglePlay,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 30),
                  color: _currentStepIndex < _breakdowns.length - 1
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  onPressed: _currentStepIndex < _breakdowns.length - 1
                      ? _stepForward
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onApplySolution(_solutionPath!);
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(strings.applySolution),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pathCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepBreakdown {
  final int step;
  final int tileIndex;
  final String actionName;
  final String formula;
  final int runningSum;
  final TileType tileType;
  final IconData icon;
  final Color color;

  StepBreakdown({
    required this.step,
    required this.tileIndex,
    required this.actionName,
    required this.formula,
    required this.runningSum,
    required this.tileType,
    required this.icon,
    required this.color,
  });
}
