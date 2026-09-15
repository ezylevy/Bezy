import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/game_state.dart';

/// Top stats indicator displaying Target, Current Sum, Difference, and Moves.
class StatsBar extends StatelessWidget {
  final GameState state;

  const StatsBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final target = state.level.targetNumber;
    final current = state.currentSum;
    final diff = target - current;

    Color sumColor = AppTheme.pathCyan;
    if (current == target) {
      sumColor = AppTheme.startGreen;
    } else if (current > target) {
      sumColor = AppTheme.targetPink;
    }

    String diffText;
    Color diffColor = AppTheme.textSecondary;
    if (diff == 0) {
      diffText = 'מדויק!';
      diffColor = AppTheme.startGreen;
    } else if (diff > 0) {
      diffText = 'חסר: $diff';
      diffColor = AppTheme.gold;
    } else {
      diffText = 'חריגה: ${diff.abs()}';
      diffColor = AppTheme.targetPink;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Target Number Badge
          _StatColumn(
            label: 'יעד',
            value: '$target',
            color: AppTheme.targetPink,
            icon: Icons.flag_rounded,
          ),

          _buildDivider(),

          // Current Sum Badge
          _StatColumn(
            label: 'סכום נוכחי',
            value: '$current',
            color: sumColor,
            icon: Icons.calculate_rounded,
          ),

          _buildDivider(),

          // Difference Badge
          _StatColumn(
            label: 'הפרש',
            value: diffText,
            color: diffColor,
            icon: Icons.compare_arrows_rounded,
          ),

          _buildDivider(),

          // Moves vs Par
          _StatColumn(
            label: 'צעדים',
            value: '${state.moves}',
            subValue: 'יעד: ${state.level.parMoves}',
            color: AppTheme.textPrimary,
            icon: Icons.directions_walk_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.cardBorder,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color color;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    this.subValue,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subValue != null)
          Text(
            subValue!,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textMuted,
            ),
          ),
      ],
    );
  }
}
