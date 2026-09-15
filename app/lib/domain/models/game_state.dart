import 'package:flutter/foundation.dart';
import 'level_model.dart';

/// Represents the active interactive state of a game session.
@immutable
class GameState {
  final LevelModel level;
  final List<int> currentPath;
  final int currentSum;
  final int moves;
  final bool isWon;
  final bool isFailed;
  final int? nextHintIndex;
  final List<int>? activeSolutionRoute;
  final int solverStepIndex;
  final String? statusMessage;

  const GameState({
    required this.level,
    this.currentPath = const [],
    this.currentSum = 0,
    this.moves = 0,
    this.isWon = false,
    this.isFailed = false,
    this.nextHintIndex,
    this.activeSolutionRoute,
    this.solverStepIndex = 0,
    this.statusMessage,
  });

  int get difference => level.targetNumber - currentSum;
  int? get currentCellIndex => currentPath.isEmpty ? null : currentPath.last;
  bool get hasStarted => currentPath.isNotEmpty;
  bool get isOverSum => currentSum > level.targetNumber;

  GameState copyWith({
    LevelModel? level,
    List<int>? currentPath,
    int? currentSum,
    int? moves,
    bool? isWon,
    bool? isFailed,
    int? nextHintIndex,
    bool clearHint = false,
    List<int>? activeSolutionRoute,
    bool clearSolution = false,
    int? solverStepIndex,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return GameState(
      level: level ?? this.level,
      currentPath: currentPath ?? this.currentPath,
      currentSum: currentSum ?? this.currentSum,
      moves: moves ?? this.moves,
      isWon: isWon ?? this.isWon,
      isFailed: isFailed ?? this.isFailed,
      nextHintIndex: clearHint ? null : (nextHintIndex ?? this.nextHintIndex),
      activeSolutionRoute: clearSolution
          ? null
          : (activeSolutionRoute ?? this.activeSolutionRoute),
      solverStepIndex: solverStepIndex ?? this.solverStepIndex,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }
}
