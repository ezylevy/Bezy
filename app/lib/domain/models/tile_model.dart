import 'package:flutter/foundation.dart';

/// Enum representing the functional type of each modular tile in the grid.
enum TileType {
  /// Regular number cell that adds its value to the current sum.
  number,

  /// Start tile located on the perimeter. Path can originate from here.
  start,

  /// Target center cell with the goal number. Path must end here with exact sum.
  target,

  /// Wall / barrier obstacle (חומה) - cannot be entered by player or solver.
  wall,

  /// Trampoline / bounce tile (מקפצה) - launches player or grants bonus multiplier.
  trampoline,

  /// Smart gate (שער חכם) - passable only when a condition is met (e.g. current sum is even).
  smartGate,
}

/// Extensible model representing a single modular cell component on the board.
@immutable
class TileModel {
  final int index;
  final int row;
  final int col;
  final TileType type;
  final int value;
  final String? customLabel;
  final Map<String, dynamic> metadata;

  const TileModel({
    required this.index,
    required this.row,
    required this.col,
    this.type = TileType.number,
    this.value = 0,
    this.customLabel,
    this.metadata = const {},
  });

  bool get isWalkable => type != TileType.wall;
  bool get isStart => type == TileType.start;
  bool get isTarget => type == TileType.target;
  bool get isWall => type == TileType.wall;
  bool get isTrampoline => type == TileType.trampoline;
  bool get isSmartGate => type == TileType.smartGate;

  /// Validates whether a player with [currentSum] can enter this tile.
  bool canEnter(int currentSum) {
    if (isWall) return false;
    if (isSmartGate) {
      final gateRule = metadata['rule'] as String? ?? 'even';
      if (gateRule == 'even') {
        return currentSum % 2 == 0;
      } else if (gateRule == 'min') {
        final minVal = metadata['min'] as int? ?? 10;
        return currentSum >= minVal;
      }
    }
    return true;
  }

  /// Calculates the new sum after stepping onto this tile.
  int applyValue(int currentSum) {
    if (isTarget) {
      return currentSum; // Target cell contains the goal number, not added to sum
    }
    if (isTrampoline) {
      final bonus = metadata['bonus'] as int? ?? 2;
      return currentSum + value + bonus;
    }
    return currentSum + value;
  }

  TileModel copyWith({
    int? index,
    int? row,
    int? col,
    TileType? type,
    int? value,
    String? customLabel,
    Map<String, dynamic>? metadata,
  }) {
    return TileModel(
      index: index ?? this.index,
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      value: value ?? this.value,
      customLabel: customLabel ?? this.customLabel,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileModel &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          row == other.row &&
          col == other.col &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode =>
      index.hashCode ^
      row.hashCode ^
      col.hashCode ^
      type.hashCode ^
      value.hashCode;
}
