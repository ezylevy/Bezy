import 'package:flutter/foundation.dart';
import 'tile_model.dart';

/// Represents a distinct playable puzzle stage.
@immutable
class LevelModel {
  final String id;
  final int worldId;
  final int levelNumber;
  final String worldTitle;
  final String title;
  final int gridSize;
  final int targetNumber;
  final List<TileModel> tiles;
  final int parMoves;
  final int? optimalMoves;
  final int? challengeTimeSeconds;
  final String description;
  final List<String> hints;

  const LevelModel({
    required this.id,
    required this.worldId,
    required this.levelNumber,
    required this.worldTitle,
    required this.title,
    required this.gridSize,
    required this.targetNumber,
    required this.tiles,
    required this.parMoves,
    this.optimalMoves,
    this.challengeTimeSeconds,
    this.description = '',
    this.hints = const [],
  });

  int get totalCells => gridSize * gridSize;
  int get centerIndex => totalCells ~/ 2;
  bool get hasChallengeTimer => challengeTimeSeconds != null;

  /// Teleporting doors are paired in board-index order: 0↔1, 2↔3, etc.
  int? pairedTeleportIndex(int index) {
    final doors =
        tiles
            .where((tile) => tile.isTrampoline)
            .map((tile) => tile.index)
            .toList()
          ..sort();
    final position = doors.indexOf(index);
    if (position == -1) return null;
    final pairedPosition = position.isEven ? position + 1 : position - 1;
    if (pairedPosition < 0 || pairedPosition >= doors.length) return null;
    return doors[pairedPosition];
  }

  List<int> get startIndices {
    return tiles
        .where((tile) => tile.isStart)
        .map((tile) => tile.index)
        .toList();
  }

  /// Calculates the default perimeter start positions for an odd NxN grid.
  static List<int> calculateDefaultStartPoints(int size) {
    final middle = size ~/ 2;
    return [
      middle, // Top middle
      middle * size, // Left middle
      middle * size + (size - 1), // Right middle
      size * (size - 1) + middle, // Bottom middle
    ];
  }

  LevelModel copyWith({
    String? id,
    int? worldId,
    int? levelNumber,
    String? worldTitle,
    String? title,
    int? gridSize,
    int? targetNumber,
    List<TileModel>? tiles,
    int? parMoves,
    int? optimalMoves,
    int? challengeTimeSeconds,
    String? description,
    List<String>? hints,
  }) {
    return LevelModel(
      id: id ?? this.id,
      worldId: worldId ?? this.worldId,
      levelNumber: levelNumber ?? this.levelNumber,
      worldTitle: worldTitle ?? this.worldTitle,
      title: title ?? this.title,
      gridSize: gridSize ?? this.gridSize,
      targetNumber: targetNumber ?? this.targetNumber,
      tiles: tiles ?? this.tiles,
      parMoves: parMoves ?? this.parMoves,
      optimalMoves: optimalMoves ?? this.optimalMoves,
      challengeTimeSeconds: challengeTimeSeconds ?? this.challengeTimeSeconds,
      description: description ?? this.description,
      hints: hints ?? this.hints,
    );
  }
}
