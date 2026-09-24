import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_mode.dart';
import '../../../l10n/app_localizations.dart';
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
  static const _adminPasscode = String.fromEnvironment(
    'BEZY_ADMIN_PASS',
    defaultValue: 'bezy-special',
  );
  bool _adminAccess = false;

  void _refresh() {
    setState(() {});
  }

  Future<void> _requestAdminAccess() async {
    final controller = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Admin testing pass'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          onSubmitted: (_) => Navigator.of(
            dialogContext,
          ).pop(controller.text.trim() == _adminPasscode),
          decoration: const InputDecoration(labelText: 'Passcode'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(controller.text.trim() == _adminPasscode),
            child: const Text('Unlock test levels'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted) return;
    if (accepted == true) {
      setState(() => _adminAccess = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin testing access enabled')),
      );
    } else if (accepted == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect admin passcode')));
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'joker':
        return Icons.theater_comedy_rounded;
      case 'ice':
        return Icons.ac_unit_rounded;
      case 'party':
        return Icons.celebration_rounded;
      case 'emoji_events':
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = widget.storage.getTotalStars();
    final worlds = CampaignLevels.worlds;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.worldMap),
        actions: [
          IconButton(
            tooltip: _adminAccess
                ? 'Admin testing access enabled'
                : 'Admin testing pass',
            onPressed: _adminAccess ? null : _requestAdminAccess,
            icon: Icon(
              _adminAccess ? Icons.lock_open_rounded : Icons.key_rounded,
              color: _adminAccess ? AppTheme.startGreen : AppTheme.textPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 22),
                const SizedBox(width: 4),
                Text(
                  strings.stars(totalStars),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
          final progressPercent = maxStars > 0 ? (earnedStars / maxStars) : 0.0;
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
                      adminAccess: _adminAccess,
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
                                strings.worldNumber(
                                  world.id,
                                  strings.worldTitle(world.id, world.title),
                                ),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.worldSubtitle(world.id, world.subtitle),
                                style: const TextStyle(
                                  fontSize: 16,
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
                          strings.levelProgress(
                            worldLevels
                                .where(
                                  (level) =>
                                      widget.storage.isLevelUnlocked(level.id),
                                )
                                .length,
                            worldLevels.length,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
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
                                fontSize: 16,
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
    );
  }
}
