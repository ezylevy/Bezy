import 'package:flutter/material.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/game_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../custom/custom_game_screen.dart';
import '../levels/world_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.storage, required this.sound});

  final ProgressStorage storage;
  final SoundService sound;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), AppTheme.bgDark],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildSettingsBar(strings),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isLandscape
                          ? Row(
                              children: [
                                Expanded(
                                  child: _buildHero(strings, compact: true),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: _buildMenu(strings),
                                  ),
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildHero(strings),
                                  const SizedBox(height: 34),
                                  _buildMenu(strings),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsBar(AppLocalizations strings) {
    final totalStars = widget.storage.getTotalStars();
    final isHaptics = widget.storage.isHapticsEnabled;
    final isSound = widget.storage.isSoundEnabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.gold, size: 22),
              const SizedBox(width: 6),
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
        Row(
          children: [
            IconButton(
              icon: Icon(
                isHaptics ? Icons.vibration_rounded : Icons.smartphone_rounded,
                color: isHaptics ? AppTheme.pathCyan : AppTheme.textMuted,
              ),
              tooltip: strings.haptics,
              onPressed: () async {
                await widget.storage.setHapticsEnabled(!isHaptics);
                widget.sound.tileTap();
                _refresh();
              },
            ),
            IconButton(
              icon: Icon(
                isSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: isSound ? AppTheme.pathCyan : AppTheme.textMuted,
              ),
              tooltip: strings.sounds,
              onPressed: () async {
                await widget.storage.setSoundEnabled(!isSound);
                widget.sound.tileTap();
                _refresh();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHero(AppLocalizations strings, {bool compact = false}) {
    final iconSize = compact ? 70.0 : 90.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.startGreen, AppTheme.pathCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(compact ? 22 : 26),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.pathCyan.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.route_rounded,
              size: compact ? 42 : 52,
              color: AppTheme.bgDark,
            ),
          ),
          SizedBox(height: compact ? 12 : 20),
          Text(
            strings.appTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 33 : 38,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.appSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            strings.createdBy,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.pathCyan,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(AppLocalizations strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MenuCard(
          title: strings.campaignTitle,
          subtitle: strings.campaignSubtitle,
          icon: Icons.map_rounded,
          accentColor: AppTheme.startGreen,
          onTap: () async {
            widget.sound.tileTap();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WorldMapScreen(
                  storage: widget.storage,
                  sound: widget.sound,
                  mode: GameMode.learning,
                ),
              ),
            );
            _refresh();
          },
        ),
        const SizedBox(height: 14),
        _MenuCard(
          title: strings.freePlayTitle,
          subtitle: strings.freePlaySubtitle,
          icon: Icons.casino_rounded,
          accentColor: AppTheme.pathCyan,
          onTap: () {
            widget.sound.tileTap();
            showDialog(
              context: context,
              builder: (context) => CustomGameDialog(
                storage: widget.storage,
                sound: widget.sound,
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        _MenuCard(
          title: strings.howToPlay,
          subtitle: strings.howToPlaySubtitle,
          icon: Icons.lightbulb_outline_rounded,
          accentColor: AppTheme.gold,
          onTap: () {
            widget.sound.tileTap();
            _showHowToPlay();
          },
        ),
        const SizedBox(height: 24),
        Text(
          strings.versionLabel,
          style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showHowToPlay() {
    final strings = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: AppTheme.gold),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.instructionsTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ruleItem(
                Icons.play_circle_fill_rounded,
                AppTheme.startGreen,
                strings.startTile,
                strings.startTileDescription,
              ),
              _ruleItem(
                Icons.directions_walk_rounded,
                AppTheme.pathCyan,
                strings.boardMovement,
                strings.boardMovementDescription,
              ),
              _ruleItem(
                Icons.flag_rounded,
                AppTheme.targetPink,
                strings.reachTarget,
                strings.reachTargetDescription,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  Widget _ruleItem(
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
