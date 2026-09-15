import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/tile_model.dart';

/// Visual state descriptors passed to each modular tile component.
class TileVisualState {
  final bool isStart;
  final bool isTarget;
  final bool isInPath;
  final int? pathStepNumber;
  final bool isPathHead;
  final bool isSolutionStep;
  final int? solutionStepNumber;
  final bool isHinted;
  final bool isVictory;
  final bool isLocked;

  const TileVisualState({
    this.isStart = false,
    this.isTarget = false,
    this.isInPath = false,
    this.pathStepNumber,
    this.isPathHead = false,
    this.isSolutionStep = false,
    this.solutionStepNumber,
    this.isHinted = false,
    this.isVictory = false,
    this.isLocked = false,
  });
}

/// Base modular component wrapper for any tile type.
class ModularTileContainer extends StatelessWidget {
  final TileModel tile;
  final TileVisualState state;
  final VoidCallback? onTap;
  final Widget child;
  final Color? customBgColor;
  final Color? customBorderColor;

  const ModularTileContainer({
    super.key,
    required this.tile,
    required this.state,
    required this.child,
    this.onTap,
    this.customBgColor,
    this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = customBgColor ?? AppTheme.surfaceElevated;
    Color borderColor = customBorderColor ?? AppTheme.cardBorder;
    if (state.isVictory) {
      bgColor = AppTheme.startGreen.withValues(alpha: 0.85);
      borderColor = AppTheme.gold;
    } else if (state.isSolutionStep) {
      bgColor = AppTheme.gold.withValues(alpha: 0.85);
      borderColor = Colors.white;
    } else if (state.isInPath) {
      bgColor = AppTheme.pathCyan.withValues(alpha: 0.9);
      borderColor = Colors.white;
    } else if (state.isHinted) {
      bgColor = AppTheme.gold.withValues(alpha: 0.35);
      borderColor = AppTheme.gold;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: state.isHinted || state.isInPath ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: state.isInPath
                ? AppTheme.pathCyan.withValues(alpha: 0.4)
                : (state.isHinted
                    ? AppTheme.gold.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.25)),
            blurRadius: state.isInPath || state.isHinted ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              child,

              // Step indicator badge for active path
              if (state.isInPath && state.pathStepNumber != null)
                Positioned(
                  top: 2,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${state.pathStepNumber}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Pulse hint icon
              if (state.isHinted)
                Positioned(
                  bottom: 2,
                  left: 3,
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 14,
                    color: AppTheme.gold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
