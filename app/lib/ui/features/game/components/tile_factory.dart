import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/tile_model.dart';
import '../../../../l10n/app_localizations.dart';
import 'tile_widget.dart';

/// Modular Factory that creates the dedicated UI component for any tile type.
/// Easily extended with new tile types (e.g., portals, switches, timers, etc.).
class TileComponentFactory {
  static Widget build({
    required TileModel tile,
    required TileVisualState state,
    required int gridSize,
    VoidCallback? onTap,
  }) {
    switch (tile.type) {
      case TileType.start:
        return StartTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );

      case TileType.target:
        return TargetTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );

      case TileType.wall:
        return WallTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );

      case TileType.trampoline:
        return TrampolineTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );

      case TileType.smartGate:
        return SmartGateTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );

      case TileType.number:
        return NumberTileComponent(
          tile: tile,
          state: state,
          gridSize: gridSize,
          onTap: onTap,
        );
    }
  }
}

/// 1. Standard Number Tile Component
class NumberTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const NumberTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateFontSize(gridSize);
    final textColor = state.isInPath || state.isSolutionStep || state.isVictory
        ? Colors.black
        : AppTheme.textPrimary;

    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      child: Center(
        child: Text(
          '${tile.value}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// 2. Start Tile Component
class StartTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const StartTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateFontSize(gridSize);
    final isSelected = state.isInPath || state.isSolutionStep;

    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBgColor: isSelected
          ? null
          : AppTheme.startGreen.withValues(alpha: 0.2),
      customBorderColor: AppTheme.startGreen,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: gridSize > 5 ? 10 : 14,
              color: AppTheme.startGreen,
            ),
          ),
          Center(
            child: Text(
              '${tile.value}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : AppTheme.startGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Target Center Tile Component
class TargetTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const TargetTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateFontSize(gridSize) * 0.95;
    final isVictory = state.isVictory;

    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBgColor: isVictory
          ? AppTheme.startGreen
          : AppTheme.targetPink.withValues(alpha: 0.28),
      customBorderColor: isVictory ? AppTheme.gold : AppTheme.targetPink,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 3,
            child: Icon(
              Icons.flag_rounded,
              size: gridSize > 5 ? 10 : 14,
              color: isVictory ? Colors.white : AppTheme.targetPink,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tile.value}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: isVictory ? Colors.black : AppTheme.targetPink,
                ),
              ),
              if (gridSize <= 5)
                Text(
                  AppLocalizations.of(context).target,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isVictory
                        ? Colors.black.withValues(alpha: 0.8)
                        : AppTheme.targetPink.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4. Wall / Obstacle Component (חומה)
class WallTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const WallTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBgColor: AppTheme.wallDark,
      customBorderColor: AppTheme.wallGray,
      child: Center(
        child: Icon(
          Icons.fence_rounded,
          size: gridSize > 5 ? 16 : 24,
          color: AppTheme.wallGray.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// 5. Trampoline Component (מקפצה)
class TrampolineTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const TrampolineTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateFontSize(gridSize);
    final bonus = tile.metadata['bonus'] as int? ?? 2;

    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBgColor: AppTheme.trampolineOrange.withValues(alpha: 0.22),
      customBorderColor: AppTheme.trampolineOrange,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.bolt_rounded,
              size: gridSize > 5 ? 10 : 13,
              color: AppTheme.trampolineOrange,
            ),
          ),
          Center(
            child: Text(
              '${tile.value}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.trampolineOrange,
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Text(
              '+$bonus',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.trampolineOrange.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. Smart Gate Component (שער חכם)
class SmartGateTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final int gridSize;
  final VoidCallback? onTap;

  const SmartGateTileComponent({
    super.key,
    required this.tile,
    required this.state,
    required this.gridSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _calculateFontSize(gridSize);
    final label = AppLocalizations.of(context).even;

    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBgColor: AppTheme.smartGatePurple.withValues(alpha: 0.25),
      customBorderColor: AppTheme.smartGatePurple,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.lock_open_rounded,
              size: gridSize > 5 ? 10 : 12,
              color: AppTheme.smartGatePurple,
            ),
          ),
          Center(
            child: Text(
              '${tile.value}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.smartGatePurple,
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.smartGatePurple.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _calculateFontSize(int gridSize) {
  if (gridSize <= 3) return 26.0;
  if (gridSize <= 5) return 20.0;
  if (gridSize <= 7) return 15.0;
  return 12.0;
}
