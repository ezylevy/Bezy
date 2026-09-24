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

  /// Teleporting door - moves the player to its pair without changing value.
  trampoline,

  /// Legacy smart-gate level cell. Entry gates are now visual start cells only,
  /// so this behaves like a normal number during route movement.
  smartGate,
  mirror,
  clone,
  blackHole,
  bomb,
  zero,
  joker,
  ice,
  lonely,
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
  bool get isMirror => type == TileType.mirror;
  bool get isClone => type == TileType.clone;
  bool get isBlackHole => type == TileType.blackHole;
  bool get isBomb => type == TileType.bomb;
  bool get isZero => type == TileType.zero;
  bool get isJoker => type == TileType.joker;
  bool get isIce => type == TileType.ice;
  bool get isLonely => type == TileType.lonely;

  List<int> get jokerOptions {
    final raw = metadata['options'];
    if (raw is List) return raw.whereType<int>().toList(growable: false);
    return const [];
  }

  /// Validates whether a player with [currentSum] can enter this tile.
  bool canEnter(int currentSum) {
    if (isWall) return false;
    return true;
  }

  /// Calculates the new sum after stepping onto this tile.
  int applyValue(int currentSum) {
    if (isTarget) {
      return currentSum; // Target cell contains the goal number, not added to sum
    }
    if (isTrampoline) return currentSum;
    if (isMirror) {
      final sign = currentSum < 0 ? -1 : 1;
      if (currentSum.abs() < 10) return currentSum * 10;
      final reversed = currentSum.abs().toString().split('').reversed.join();
      return sign * int.parse(reversed);
    }
    if (isClone) return currentSum * 2;
    if (isZero) return 0;
    if (isJoker) {
      final options = jokerOptions;
      return currentSum + (options.isEmpty ? 0 : options.first);
    }
    if (isBlackHole || isBomb) return currentSum;
    return currentSum + value;
  }

  int applyJokerChoice(int currentSum, int choice) {
    if (!isJoker || !jokerOptions.contains(choice)) {
      return applyValue(currentSum);
    }
    return currentSum + choice;
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
