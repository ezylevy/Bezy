import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// A sleek custom painter that draws a glowing neon energy conduit connecting tiles in a path.
class EnergyConduitPainter extends CustomPainter {
  static const double cellSpacing = 5;

  final List<int> path;
  final int gridSize;
  final double pulsePhase; // 0.0 to 1.0 for animating pulsing particles
  final Color conduitColor;
  final bool isSolution;

  EnergyConduitPainter({
    required this.path,
    required this.gridSize,
    this.pulsePhase = 0.0,
    this.conduitColor = AppTheme.pathCyan,
    this.isSolution = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final horizontalSpacing = cellSpacing * (gridSize - 1);
    final verticalSpacing = cellSpacing * (gridSize - 1);
    final cellWidth = (size.width - horizontalSpacing) / gridSize;
    final cellHeight = (size.height - verticalSpacing) / gridSize;

    Offset getCenter(int index) {
      final col = index % gridSize;
      final row = index ~/ gridSize;
      return Offset(
        col * (cellWidth + cellSpacing) + cellWidth / 2,
        row * (cellHeight + cellSpacing) + cellHeight / 2,
      );
    }

    final points = path.map(getCenter).toList();

    // Outer glow paint
    final glowPaint = Paint()
      ..color = conduitColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Inner bright beam paint
    final beamPaint = Paint()
      ..color = isSolution ? AppTheme.gold : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathObject = Path();
    pathObject.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previousIndex = path[i - 1];
      final currentIndex = path[i];
      final rowDistance = (previousIndex ~/ gridSize - currentIndex ~/ gridSize)
          .abs();
      final colDistance = (previousIndex % gridSize - currentIndex % gridSize)
          .abs();
      if (rowDistance + colDistance == 1) {
        pathObject.lineTo(points[i].dx, points[i].dy);
      } else {
        // Teleport jumps do not draw a false route segment across the board.
        pathObject.moveTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(pathObject, glowPaint);
    canvas.drawPath(pathObject, beamPaint);

    // Draw animated pulse spark at head of path
    if (points.isNotEmpty) {
      final head = points.last;
      final sparkPaint = Paint()
        ..color = isSolution ? Colors.amberAccent : Colors.cyanAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(head, 6.0 + 2.0 * pulsePhase, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnergyConduitPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.pulsePhase != pulsePhase ||
        oldDelegate.conduitColor != conduitColor ||
        oldDelegate.isSolution != isSolution;
  }
}
