import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../domain/models/game_state.dart';
import 'energy_conduit.dart';
import 'tile_factory.dart';
import 'tile_widget.dart';

/// Interactive grid board containing the modular tile components and glowing energy conduit.
class BoardWidget extends StatefulWidget {
  final GameState state;
  final FutureOr<void> Function(int tileIndex) onTileTap;
  final double pulsePhase;

  const BoardWidget({
    super.key,
    required this.state,
    required this.onTileTap,
    this.pulsePhase = 0.0,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  int? _activePointer;
  int? _lastTouchedIndex;
  Offset? _lastPointerPosition;
  Future<void> _moveQueue = Future<void>.value();

  void _queueTile(int index) {
    if (_lastTouchedIndex == index) return;
    _lastTouchedIndex = index;
    // Game moves can contain asynchronous effects (for example, the Joker
    // choice). Keep all cells crossed by the finger in their original order.
    _moveQueue = _moveQueue.then((_) async => widget.onTileTap(index));
  }

  int? _tileAt(Offset position, double boardSize, int gridSize) {
    const padding = 6.0;
    const spacing = 5.0;
    final cellSize =
        (boardSize - padding * 2 - spacing * (gridSize - 1)) / gridSize;
    final x = position.dx - padding;
    final y = position.dy - padding;
    if (x < 0 || y < 0) return null;

    final stride = cellSize + spacing;
    final col = x ~/ stride;
    final row = y ~/ stride;
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return null;
    }
    // Do not treat the visual gap between two cells as either cell.
    if (x - col * stride > cellSize || y - row * stride > cellSize) {
      return null;
    }
    return row * gridSize + col;
  }

  void _tracePointer(Offset position, double boardSize, int gridSize) {
    final previous = _lastPointerPosition;
    _lastPointerPosition = position;
    if (previous == null) {
      final index = _tileAt(position, boardSize, gridSize);
      if (index != null) _queueTile(index);
      return;
    }

    // Sample the whole pointer segment so a fast swipe cannot jump over a
    // narrow cell between two pointer events.
    final cellSize = (boardSize - 12 - 5 * (gridSize - 1)) / gridSize;
    final distance = (position - previous).distance;
    final samples = (distance / (cellSize * 0.3)).ceil().clamp(1, 40);
    for (var step = 1; step <= samples; step++) {
      final point = Offset.lerp(previous, position, step / samples)!;
      final index = _tileAt(point, boardSize, gridSize);
      if (index != null) _queueTile(index);
    }
  }

  void _finishPointer(int pointer) {
    if (_activePointer != pointer) return;
    _activePointer = null;
    _lastTouchedIndex = null;
    _lastPointerPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.state.level;
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
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                if (_activePointer != null) return;
                _activePointer = event.pointer;
                _lastTouchedIndex = null;
                _lastPointerPosition = null;
                _tracePointer(event.localPosition, boardSize, n);
              },
              onPointerMove: (event) {
                if (_activePointer != event.pointer) return;
                _tracePointer(event.localPosition, boardSize, n);
              },
              onPointerUp: (event) => _finishPointer(event.pointer),
              onPointerCancel: (event) => _finishPointer(event.pointer),
              child: Stack(
                children: [
                  // 1. Base Grid of Modular Tile Components
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: GridView.builder(
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

                        return KeyedSubtree(
                          key: ValueKey('tile-$index'),
                          child: TileComponentFactory.build(
                            tile: tile,
                            state: visualState,
                            gridSize: n,
                            // Pointer input is handled once at board level so a
                            // continuous drag can cross multiple cells.
                            onTap: null,
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Neon Energy Conduit connecting the path tiles
                  if (widget.state.currentPath.length >= 2 ||
                      (widget.state.activeSolutionRoute != null &&
                          widget.state.activeSolutionRoute!.length >= 2))
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: EnergyConduitPainter(
                              path: widget.state.activeSolutionRoute == null
                                  ? widget.state.currentPath
                                  : widget.state.activeSolutionRoute!
                                        .take(widget.state.solverStepIndex + 1)
                                        .toList(),
                              gridSize: n,
                              pulsePhase: widget.pulsePhase,
                              isSolution:
                                  widget.state.activeSolutionRoute != null,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // The runner is a separate layer above the route, so neither
                  // the path nor the number artwork is replaced by the sprite.
                  if (widget.state.activeSolutionRoute != null &&
                      widget.state.activeSolutionRoute!.isNotEmpty)
                    _buildRunner(
                      widget.state.activeSolutionRoute![widget
                          .state
                          .solverStepIndex
                          .clamp(
                            0,
                            widget.state.activeSolutionRoute!.length - 1,
                          )],
                      n,
                      boardSize,
                      _solutionDirection(),
                      instant: false,
                    )
                  else if (widget.state.currentPath.isNotEmpty)
                    _buildRunner(
                      widget.state.currentPath.last,
                      n,
                      boardSize,
                      widget.state.runnerDirection.name,
                      instant: widget.state.runnerTeleported,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _solutionDirection() {
    final route = widget.state.activeSolutionRoute!;
    final step = widget.state.solverStepIndex.clamp(0, route.length - 1);
    if (step == 0) return MoveDirection.down.name;
    final from = route[step - 1];
    final to = route[step];
    if (to == from + 1) return MoveDirection.right.name;
    if (to == from - 1) return MoveDirection.left.name;
    return to > from ? MoveDirection.down.name : MoveDirection.up.name;
  }

  Widget _buildRunner(
    int head,
    int gridSize,
    double boardSize,
    String direction, {
    required bool instant,
  }) {
    const padding = 6.0;
    const spacing = 5.0;
    final cellSize =
        (boardSize - padding * 2 - spacing * (gridSize - 1)) / gridSize;
    final runnerSize = cellSize * 0.82;
    final row = head ~/ gridSize;
    final col = head % gridSize;

    return AnimatedPositioned(
      duration: instant ? Duration.zero : const Duration(milliseconds: 70),
      curve: Curves.linear,
      left: padding + col * (cellSize + spacing) + (cellSize - runnerSize) / 2,
      top: padding + row * (cellSize + spacing) + (cellSize - runnerSize) / 2,
      width: runnerSize,
      height: runnerSize,
      child: IgnorePointer(
        child: Image.asset(
          'assets/figure/$direction.png',
          key: ValueKey('runner-at-$head'),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  TileVisualState _buildVisualState(int index) {
    final path = widget.state.currentPath;
    final solution = widget.state.activeSolutionRoute;
    final inPath = path.contains(index);
    final inSolution =
        solution != null &&
        solution.take(widget.state.solverStepIndex + 1).contains(index);

    int? pathStep;
    if (inPath) {
      pathStep = path.indexOf(index) + 1;
    }

    int? solStep;
    if (inSolution) {
      solStep = solution.indexOf(index) + 1;
    }

    final isHead = path.isNotEmpty && path.last == index;
    final isHinted = widget.state.nextHintIndex == index;

    return TileVisualState(
      isStart: widget.state.hasStarted
          ? path.first == index
          : widget.state.level.startIndices.contains(index),
      isTarget: index == widget.state.level.centerIndex,
      isInPath: inPath,
      pathStepNumber: pathStep,
      isPathHead: isHead,
      isSolutionStep: inSolution,
      solutionStepNumber: solStep,
      isHinted: isHinted,
      isVictory: widget.state.isWon && inPath,
      isLocked: widget.state.destroyedIndices.contains(index),
      isBlackHoled: widget.state.blackHoledIndices.contains(index),
      isRuleLocked:
          widget.state.level.tiles[index].isLonely &&
          !widget.state.level.isLonelyUnlocked(
            index,
            widget.state.visitedIndices,
          ),
      isResolvedLonely:
          widget.state.level.tiles[index].isLonely &&
          widget.state.visitedIndices.contains(index),
    );
  }
}
