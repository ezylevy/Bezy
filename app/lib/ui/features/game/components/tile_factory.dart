import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/tile_model.dart';
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
    if (tile.isLonely && state.isResolvedLonely) {
      return NumberTileComponent(
        tile: tile.copyWith(type: TileType.number),
        state: state,
        gridSize: gridSize,
        onTap: onTap,
      );
    }
    if (state.isBlackHoled) {
      return ModularTileContainer(
        tile: tile,
        state: state,
        onTap: onTap,
        child: Image.asset(
          'assets/special/black_holed_cell.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      );
    }
    if (state.isLocked) {
      return ModularTileContainer(
        tile: tile,
        state: state,
        onTap: onTap,
        child: Image.asset('assets/special/wall.png', fit: BoxFit.contain),
      );
    }
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

      case TileType.mirror:
      case TileType.clone:
      case TileType.blackHole:
      case TileType.bomb:
      case TileType.zero:
      case TileType.joker:
      case TileType.ice:
      case TileType.lonely:
        return SpecialTileComponent(tile: tile, state: state, onTap: onTap);

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

class SpecialTileComponent extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final VoidCallback? onTap;

  const SpecialTileComponent({
    super.key,
    required this.tile,
    required this.state,
    this.onTap,
  });

  String get _assetName => switch (tile.type) {
    TileType.mirror => 'mirror.png',
    TileType.clone => 'clone.png',
    TileType.blackHole => 'black_hole.png',
    TileType.bomb => 'bomb.png',
    TileType.zero => 'zero.png',
    TileType.joker => 'joker.png',
    TileType.ice => 'ice.png',
    TileType.lonely => 'lonely_cell.png',
    _ => throw StateError('Not a special tile'),
  };

  IconData get _fallbackIcon => switch (tile.type) {
    TileType.joker => Icons.theater_comedy_rounded,
    TileType.ice => Icons.ac_unit_rounded,
    TileType.lonely => Icons.person_outline_rounded,
    _ => Icons.auto_awesome_rounded,
  };

  Color get _fallbackColor => switch (tile.type) {
    TileType.joker => const Color(0xFFFF4FA3),
    TileType.ice => const Color(0xFF50D8FF),
    TileType.lonely => const Color(0xFFFFB84D),
    _ => AppTheme.pathCyan,
  };

  @override
  Widget build(BuildContext context) {
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/special/$_assetName',
            fit: BoxFit.contain,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                Icon(_fallbackIcon, color: _fallbackColor, size: 34),
          ),
          if (tile.isJoker && tile.jokerOptions.isNotEmpty)
            Positioned(
              bottom: 2,
              child: Text(
                tile.jokerOptions.join(' / '),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
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
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      child: NumberTileArt(value: tile.value, state: state),
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
    final isSelected = state.isInPath || state.isSolutionStep;
    final showAsStart = state.isStart;

    // Entry gates keep their golden artwork and get a bold gold frame and
    // glow so they stand out on the board (the old green border faded away).
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBorderColor: showAsStart ? AppTheme.gold : null,
      emphasized: showAsStart && !isSelected,
      child: Stack(
        alignment: Alignment.center,
        children: [
          NumberTileArt(
            value: tile.value,
            state: state,
            upAssetDirectory: showAsStart && !isSelected
                ? 'assets/numbers/set1/gates'
                : 'assets/numbers/set1',
          ),
          if (showAsStart)
            Positioned(
              top: 2,
              left: 2,
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: gridSize > 5 ? 11 : 15,
                color: AppTheme.gold,
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
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      customBorderColor: state.isVictory ? AppTheme.gold : AppTheme.targetPink,
      child: Image.asset(
        'assets/numbers/results/${tile.value}.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            NumberTileArt(value: tile.value, state: state),
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
      child: Image.asset(
        'assets/special/wall.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
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
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      child: Image.asset(
        'assets/special/teleporting_door.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
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
    return ModularTileContainer(
      tile: tile,
      state: state,
      onTap: onTap,
      child: NumberTileArt(value: tile.value, state: state),
    );
  }
}

/// Uses the supplied up/pressed artwork for every digit, including two-digit
/// targets. Keeping each digit separate avoids stretching the artwork.
class NumberTileArt extends StatelessWidget {
  final int value;
  final TileVisualState state;
  final String upAssetDirectory;

  const NumberTileArt({
    super.key,
    required this.value,
    required this.state,
    this.upAssetDirectory = 'assets/numbers/set1',
  });

  @override
  Widget build(BuildContext context) {
    final pressed = state.isInPath || state.isSolutionStep;
    final digits = value.toString().split('');
    final artwork = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final digit in digits)
          Expanded(
            child: Image.asset(
              pressed
                  ? 'assets/numbers/set1/${digit}pressed.png'
                  : '$upAssetDirectory/${digit}up.png',
              fit: digits.length > 1 ? BoxFit.cover : BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => Text(
                digit,
                style: const TextStyle(
                  fontSize: 24,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      label: '$value',
      image: true,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: state.isVictory && state.isTarget
            ? ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.55,
                  0,
                  0,
                  0,
                  22,
                  0,
                  0.9,
                  0,
                  0,
                  80,
                  0,
                  0,
                  0.65,
                  0,
                  35,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: artwork,
              )
            : pressed
            ? ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.65,
                  0,
                  0,
                  0,
                  25,
                  0,
                  0.8,
                  0,
                  0,
                  32,
                  0,
                  0,
                  0.95,
                  0,
                  55,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: artwork,
              )
            : artwork,
      ),
    );
  }
}
