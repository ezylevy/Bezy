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
  final bool isBlackHoled;

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
    this.isBlackHoled = false,
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
    // Supplied artwork carries the visual state. Board squares remain neutral
    // so tile rules are never communicated by a second, conflicting fill.
    Color bgColor = Colors.transparent;
    Color borderColor = customBorderColor ?? AppTheme.cardBorder;
    if (state.isVictory) {
      borderColor = AppTheme.gold;
    } else if (state.isSolutionStep) {
      borderColor = AppTheme.gold;
    } else if (state.isInPath) {
      borderColor = AppTheme.pathCyan;
    } else if (state.isHinted) {
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
                      : AppTheme.bgDark.withValues(alpha: 0.25)),
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
