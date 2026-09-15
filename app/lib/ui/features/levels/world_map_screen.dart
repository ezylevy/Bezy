import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_mode.dart';
import 'level_select_screen.dart';

/// World map showing progressive difficulty chapters and overall stars.
class WorldMapScreen extends StatefulWidget {
  final ProgressStorage storage;
  final SoundService sound;
  final GameMode mode;

  const WorldMapScreen({
    super.key,
    required this.storage,
    required this.sound,
    required this.mode,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  void _refresh() {
    setState(() {});
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'emoji_events':
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = widget.storage.getTotalStars();
    final worlds = CampaignLevels.worlds;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מפת העולמות'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppTheme.gold,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStars כוכבים',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: worlds.length,
          itemBuilder: (context, index) {
            final world = worlds[index];
            final worldLevels = CampaignLevels.getLevelsForWorld(world.id);
            final worldLevelIds = worldLevels.map((l) => l.id).toList();
            final earnedStars = widget.storage.getTotalStarsForWorld(
              world.id,
              worldLevelIds,
            );
            final maxStars = worldLevels.length * 3;
            final progressPercent = maxStars > 0
                ? (earnedStars / maxStars)
                : 0.0;
            final color = Color(world.colorHex);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  widget.sound.tileTap();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LevelSelectScreen(
                        world: world,
                        storage: widget.storage,
                        sound: widget.sound,
                        mode: widget.mode,
                      ),
                    ),
                  );
                  _refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _getIcon(world.iconName),
                              color: color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'עולם ${world.id}: ${world.title}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  world.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: AppTheme.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'התקדמות שלבים: ${worldLevels.where((l) => widget.storage.isLevelUnlocked(l.id)).length} / ${worldLevels.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.gold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$earnedStars / $maxStars',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gold,
                                ),
                              ),
                            ],
                          ),
                        ],
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
