import 'package:flutter/material.dart';
import '../../../../domain/models/game_state.dart';
import 'energy_conduit.dart';
import 'tile_factory.dart';
import 'tile_widget.dart';

/// Interactive grid board containing the modular tile components and glowing energy conduit.
class BoardWidget extends StatelessWidget {
  final GameState state;
  final Function(int tileIndex) onTileTap;
  final double pulsePhase;

  const BoardWidget({
    super.key,
    required this.state,
    required this.onTileTap,
    this.pulsePhase = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final level = state.level;
    final n = level.gridSize;
    final total = n * n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        final boardSize = maxSide.clamp(280.0, 480.0);

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Stack(
              children: [
                // 1. Base Grid of Modular Tile Components
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(6),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: n,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final tile = level.tiles[index];
                    final visualState = _buildVisualState(index);

                    return TileComponentFactory.build(
                      tile: tile,
                      state: visualState,
                      gridSize: n,
                      onTap: () => onTileTap(index),
                    );
                  },
                ),

                // 2. Neon Energy Conduit connecting the path tiles
                if (state.currentPath.length >= 2 ||
                    (state.activeSolutionRoute != null &&
                        state.activeSolutionRoute!.length >= 2))
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: EnergyConduitPainter(
                            path:
                                state.activeSolutionRoute ?? state.currentPath,
                            gridSize: n,
                            pulsePhase: pulsePhase,
                            isSolution: state.activeSolutionRoute != null,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  TileVisualState _buildVisualState(int index) {
    final path = state.currentPath;
    final solution = state.activeSolutionRoute;
    final inPath = path.contains(index);
    final inSolution =
        solution != null &&
        solution.take(state.solverStepIndex + 1).contains(index);

    int? pathStep;
    if (inPath) {
      pathStep = path.indexOf(index) + 1;
    }

    int? solStep;
    if (inSolution) {
      solStep = solution.indexOf(index) + 1;
    }

    final isHead = path.isNotEmpty && path.last == index;
    final isHinted = state.nextHintIndex == index;

    return TileVisualState(
      isStart: state.level.startIndices.contains(index),
      isTarget: index == state.level.centerIndex,
      isInPath: inPath,
      pathStepNumber: pathStep,
      isPathHead: isHead,
      isSolutionStep: inSolution,
      solutionStepNumber: solStep,
      isHinted: isHinted,
      isVictory: state.isWon && inPath,
    );
  }
}
