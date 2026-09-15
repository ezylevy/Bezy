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
    this.description = '',
    this.hints = const [],
  });

  int get totalCells => gridSize * gridSize;
  int get centerIndex => totalCells ~/ 2;

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
      description: description ?? this.description,
      hints: hints ?? this.hints,
    );
  }
}
