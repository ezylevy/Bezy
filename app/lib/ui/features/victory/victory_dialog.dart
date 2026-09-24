import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Celebratory victory modal showing stars, stats, and navigation options.
class VictoryDialog extends StatelessWidget {
  final int stars;
  final int moves;
  final int parMoves;
  final int targetSum;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelSelect;
  final bool hasNextLevel;

  const VictoryDialog({
    super.key,
    required this.stars,
    required this.moves,
    required this.parMoves,
    required this.targetSum,
    required this.onNextLevel,
    required this.onReplay,
    required this.onLevelSelect,
    this.hasNextLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.gold, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Trophy / Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: AppTheme.gold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              strings.victoryTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              strings.exactTarget(targetSum),
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // 3 Animated Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isEarned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 42,
                    color: isEarned ? AppTheme.gold : AppTheme.wallGray,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Performance Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(strings.yourMoves, '$moves'),
                  Container(width: 1, height: 30, color: AppTheme.cardBorder),
                  _statItem(strings.targetMoves, '$parMoves'),
                  Container(width: 1, height: 30, color: AppTheme.cardBorder),
                  _statItem(strings.starLabel, '$stars / 3'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (hasNextLevel)
              ElevatedButton.icon(
                onPressed: onNextLevel,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(strings.nextLevel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.startGreen,
                  foregroundColor: AppTheme.bgDark,
                  minimumSize: const Size.fromHeight(46),
                ),
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReplay,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(strings.playAgain),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLevelSelect,
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    label: Text(strings.levelMap),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
