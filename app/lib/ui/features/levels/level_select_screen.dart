import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/level_model.dart';
import '../game/game_screen.dart';

/// Screen displaying the grid of levels for a specific world.
class LevelSelectScreen extends StatefulWidget {
  final WorldInfo world;
  final ProgressStorage storage;
  final SoundService sound;

  const LevelSelectScreen({
    super.key,
    required this.world,
    required this.storage,
    required this.sound,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late List<LevelModel> _levels;

  @override
  void initState() {
    super.initState();
    _levels = CampaignLevels.getLevelsForWorld(widget.world.id);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.world.title),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];
            final isUnlocked = widget.storage.isLevelUnlocked(level.id);
            final stars = widget.storage.getStars(level.id);
            final bestMoves = widget.storage.getBestMoves(level.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isUnlocked
                    ? () async {
                        widget.sound.tileTap();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              initialLevel: level,
                              storage: widget.storage,
                              sound: widget.sound,
                            ),
                          ),
                        );
                        _refresh();
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppTheme.surfaceDark
                        : AppTheme.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? (stars > 0 ? AppTheme.gold : AppTheme.cardBorder)
                          : AppTheme.surfaceElevated,
                      width: isUnlocked && stars == 3 ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Level Number Badge or Lock
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? Color(widget.world.colorHex).withValues(alpha: 0.2)
                              : AppTheme.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isUnlocked
                              ? Text(
                                  '${level.levelNumber}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(widget.world.colorHex),
                                  ),
                                )
                              : const Icon(
                                  Icons.lock_rounded,
                                  color: AppTheme.textMuted,
                                  size: 22,
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Level Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'לוח ${level.gridSize}x${level.gridSize} • יעד סכום: ${level.targetNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (isUnlocked && bestMoves != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'שיא: $bestMoves צעדים (יעד: ${level.parMoves})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Stars Indicator
                      if (isUnlocked)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (starIdx) {
                            final isEarned = starIdx < stars;
                            return Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: isEarned ? AppTheme.gold : AppTheme.wallGray,
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
