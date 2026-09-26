import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/game_state.dart';
import '../../../../l10n/app_localizations.dart';

/// Dynamic game status rendered over the supplied neon panel artwork.
class StatsBar extends StatelessWidget {
  final GameState state;
  final bool landscape;

  const StatsBar({super.key, required this.state, this.landscape = false});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final difference = state.difference;
    final remainingLabel = state.isWon
        ? strings.exact
        : difference >= 0
        ? strings.remaining(difference)
        : strings.overBy(difference.abs());
    // The supplied button is bright gold, so a warm dark-brown value keeps
    // strong contrast without introducing black into the interface.
    const remainingColor = Color(0xFF633400);

    if (landscape) {
      return _buildLandscape(
        context,
        remainingLabel: remainingLabel,
        remainingColor: remainingColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth - 20, 720.0);
        final height = (width / 3).clamp(118.0, 175.0);
        final valueTop = height * 0.26;
        final labelTop = height * 0.12;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/buttons/panel.png',
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
                _PanelText(
                  left: width * 0.14,
                  width: width * 0.14,
                  labelTop: labelTop,
                  valueTop: valueTop,
                  label: strings.moves,
                  value: '${state.moves}',
                  color: AppTheme.gold,
                ),
                _PanelText(
                  left: width * 0.42,
                  width: width * 0.16,
                  labelTop: labelTop,
                  valueTop: valueTop,
                  label: strings.currentSum,
                  value: '${state.currentSum}',
                  color: state.currentSum > state.level.targetNumber
                      ? AppTheme.targetPink
                      : AppTheme.pathCyan,
                ),
                _PanelText(
                  left: width * 0.74,
                  width: width * 0.16,
                  labelTop: labelTop,
                  valueTop: valueTop,
                  label: strings.target,
                  value: '${state.level.targetNumber}',
                  color: AppTheme.targetPink,
                ),
                Positioned(
                  key: const ValueKey('remaining-target-label'),
                  left: width * 0.28,
                  right: width * 0.28,
                  top: height * 0.55,
                  bottom: height * 0.18,
                  child: Semantics(
                    liveRegion: true,
                    label: remainingLabel,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          remainingLabel,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: remainingColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            shadows: const [
                              Shadow(color: Color(0xFF5D3500), blurRadius: 6),
                            ],
                          ),
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

  Widget _buildLandscape(
    BuildContext context, {
    required String remainingLabel,
    required Color remainingColor,
  }) {
    final strings = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth - 8, 280.0);
        final height = math.max(190.0, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/buttons/panel_landscape.png',
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
                _LandscapePanelText(
                  top: height * 0.075,
                  height: height * 0.205,
                  label: strings.moves,
                  value: '${state.moves}',
                  color: AppTheme.gold,
                ),
                _LandscapePanelText(
                  top: height * 0.285,
                  height: height * 0.195,
                  label: strings.currentSum,
                  value: '${state.currentSum}',
                  color: state.currentSum > state.level.targetNumber
                      ? AppTheme.targetPink
                      : AppTheme.pathCyan,
                ),
                _LandscapePanelText(
                  top: height * 0.49,
                  height: height * 0.19,
                  label: strings.target,
                  value: '${state.level.targetNumber}',
                  color: AppTheme.targetPink,
                ),
                Positioned(
                  key: const ValueKey('remaining-target-label'),
                  left: width * 0.13,
                  right: width * 0.13,
                  top: height * 0.69,
                  height: height * 0.095,
                  child: Semantics(
                    liveRegion: true,
                    label: remainingLabel,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        remainingLabel,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: remainingColor,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
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
}

class _LandscapePanelText extends StatelessWidget {
  final double top;
  final double height;
  final String label;
  final String value;
  final Color color;

  const _LandscapePanelText({
    required this.top,
    required this.height,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28,
      right: 28,
      top: top,
      height: height,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelText extends StatelessWidget {
  final double left;
  final double width;
  final double labelTop;
  final double valueTop;
  final String label;
  final String value;
  final Color color;

  const _PanelText({
    required this.left,
    required this.width,
    required this.labelTop,
    required this.valueTop,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: Stack(
        children: [
          Positioned(
            top: labelTop,
            left: 0,
            right: 0,
            height: 22,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: valueTop,
            left: 0,
            right: 0,
            height: 40,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
