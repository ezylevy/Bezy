import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/campaign/campaign_levels.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/level_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../components/bezy_message_dialog.dart';
import '../game/game_screen.dart';

enum _UnlockPhase { idle, unlocking, free }

/// A single winding campaign map. The artwork contains all 50 numbered stage
/// stones; interactive lock layers are positioned over those stones.
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({
    super.key,
    required this.storage,
    required this.sound,
    required this.mode,
  });

  final ProgressStorage storage;
  final SoundService sound;
  final GameMode mode;

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with SingleTickerProviderStateMixin {
  static const _adminPasscode = String.fromEnvironment(
    'BEZY_ADMIN_PASS',
    defaultValue: 'bezy-special',
  );
  static const _mapAspectRatio = 941 / 1672;

  // Centers of the numbered stones in map.png, normalized to its source size.
  static const _physicalStageCenters = <Offset>[
    Offset(310 / 941, 145 / 1672),
    Offset(416 / 941, 166 / 1672),
    Offset(522 / 941, 184 / 1672),
    Offset(627 / 941, 205 / 1672),
    Offset(731 / 941, 237 / 1672),
    Offset(291 / 941, 345 / 1672),
    Offset(383 / 941, 311 / 1672),
    Offset(484 / 941, 313 / 1672),
    Offset(592 / 941, 329 / 1672),
    Offset(689 / 941, 301 / 1672),
    Offset(330 / 941, 418 / 1672),
    Offset(433 / 941, 455 / 1672),
    Offset(540 / 941, 473 / 1672),
    Offset(650 / 941, 495 / 1672),
    Offset(760 / 941, 522 / 1672),
    Offset(291 / 941, 604 / 1672),
    Offset(393 / 941, 582 / 1672),
    Offset(505 / 941, 607 / 1672),
    Offset(616 / 941, 622 / 1672),
    Offset(726 / 941, 603 / 1672),
    Offset(326 / 941, 695 / 1672),
    Offset(436 / 941, 719 / 1672),
    Offset(550 / 941, 742 / 1672),
    Offset(662 / 941, 765 / 1672),
    Offset(773 / 941, 799 / 1672),
    Offset(278 / 941, 872 / 1672),
    Offset(386 / 941, 883 / 1672),
    Offset(501 / 941, 908 / 1672),
    Offset(615 / 941, 919 / 1672),
    Offset(728 / 941, 901 / 1672),
    Offset(325 / 941, 1006 / 1672),
    Offset(438 / 941, 1021 / 1672),
    Offset(551 / 941, 1051 / 1672),
    Offset(660 / 941, 1080 / 1672),
    Offset(765 / 941, 1107 / 1672),
    Offset(287 / 941, 1160 / 1672),
    Offset(400 / 941, 1170 / 1672),
    Offset(516 / 941, 1175 / 1672),
    Offset(631 / 941, 1196 / 1672),
    Offset(748 / 941, 1185 / 1672),
    Offset(328 / 941, 1260 / 1672),
    Offset(438 / 941, 1300 / 1672),
    Offset(551 / 941, 1331 / 1672),
    Offset(660 / 941, 1358 / 1672),
    Offset(770 / 941, 1382 / 1672),
    Offset(272 / 941, 1447 / 1672),
    Offset(379 / 941, 1405 / 1672),
    Offset(488 / 941, 1442 / 1672),
    Offset(601 / 941, 1467 / 1672),
    Offset(725 / 941, 1501 / 1672),
  ];

  // The illustrated road snakes across each row. Keep campaign numbering in
  // travel order: left-to-right on one row, then right-to-left on the next.
  static final List<Offset> _stageCenters = <Offset>[
    for (var row = 0; row < 10; row++)
      ...(row.isEven
          ? _physicalStageCenters.skip(row * 5).take(5)
          : _physicalStageCenters
                .skip(row * 5)
                .take(5)
                .toList(growable: false)
                .reversed),
  ];

  final TransformationController _mapController = TransformationController();
  late final AnimationController _focusController;
  Animation<Matrix4>? _focusAnimation;
  late GameMode _mode;
  final Map<int, _UnlockPhase> _unlockPhases = {};
  List<LevelModel> get _levels => CampaignLevels.getAllLevels();
  Size? _viewportSize;
  double? _mapWidth;
  bool _mapFocused = false;
  bool _stageImagesPrecached = false;
  bool _adminAccess = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _focusController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
        )..addListener(() {
          final animation = _focusAnimation;
          if (animation != null) _mapController.value = animation.value;
        });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stageImagesPrecached) return;
    _stageImagesPrecached = true;
    for (final asset in const [
      'assets/stages/map.png',
      'assets/stages/lock.png',
      'assets/stages/unlock.png',
      'assets/stages/free.png',
      'assets/buttons/msg.png',
    ]) {
      precacheImage(AssetImage(asset), context);
    }
  }

  int get _currentStageIndex {
    final firstPending = _levels.indexWhere(
      (level) =>
          (_adminAccess || widget.storage.isLevelUnlocked(level.id)) &&
          widget.storage.getStars(level.id) == 0,
    );
    return firstPending == -1 ? _levels.length - 1 : firstPending;
  }

  bool _isUnlocked(LevelModel level) =>
      _adminAccess || widget.storage.isLevelUnlocked(level.id);

  bool _isRevealed(LevelModel level) =>
      _adminAccess || widget.storage.isLevelRevealed(level.id);

  void _focusCurrentGroup({bool animate = true}) {
    final viewport = _viewportSize;
    final mapWidth = _mapWidth;
    if (viewport == null || mapWidth == null) return;
    _mapFocused = true;

    final groupStart = (_currentStageIndex ~/ 5) * 5;
    final group = _stageCenters.skip(groupStart).take(5).toList();
    final center = group.reduce((a, b) => a + b) / group.length.toDouble();
    final top = group.map((point) => point.dy).reduce((a, b) => a < b ? a : b);
    final mapHeight = mapWidth / _mapAspectRatio;
    final scale = viewport.height > viewport.width ? 1.55 : 1.18;
    final tx = viewport.width / 2 - center.dx * mapWidth * scale;
    final ty = 70 - top * mapHeight * scale;
    final target = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(tx, ty, 0);

    _animateMapTo(target, animate: animate);
  }

  void _focusMapStart({bool animate = true}) {
    final viewport = _viewportSize;
    final mapWidth = _mapWidth;
    if (viewport == null || mapWidth == null) return;
    final mapHeight = mapWidth / _mapAspectRatio;
    final firstGroup = _stageCenters.take(5).toList();
    final center =
        firstGroup.reduce((a, b) => a + b) / firstGroup.length.toDouble();
    final scale = viewport.height > viewport.width ? 1.28 : 1.1;
    final tx = viewport.width / 2 - center.dx * mapWidth * scale;
    const ty = 10.0;
    final target = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(tx, ty, 0);

    // Entering the detailed map should feel like a gentle glide to its top,
    // with stage 1 comfortably inside the viewport rather than clipped above it.
    final firstStageY = ty + _stageCenters.first.dy * mapHeight * scale;
    assert(firstStageY > 40);
    _animateMapTo(target, animate: animate);
  }

  void _animateMapTo(Matrix4 target, {required bool animate}) {
    if (!animate) {
      _mapController.value = target;
      return;
    }
    _focusController.stop();
    _focusAnimation = Matrix4Tween(begin: _mapController.value, end: target)
        .animate(
          CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic),
        );
    unawaited(_focusController.forward(from: 0));
  }

  void _enterFocusedMap() {
    if (_mapFocused) {
      _focusCurrentGroup();
      return;
    }
    setState(() => _mapFocused = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusMapStart();
    });
  }

  Future<void> _handleStageTap(int index) async {
    final level = _levels[index];
    if (!_isUnlocked(level)) {
      widget.sound.invalidMove();
      await showBezyMessageDialog(
        context,
        message: AppLocalizations.of(context).stageLocked,
      );
      return;
    }

    if (!_isRevealed(level)) {
      await _playUnlock(index, level);
      return;
    }

    await _openLevel(level);
  }

  Future<void> _openLevel(LevelModel level) async {
    widget.sound.tileTap();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialLevel: level,
          storage: widget.storage,
          sound: widget.sound,
          mode: _mode,
          showSpecialIntroductions: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusCurrentGroup();
    });
  }

  Future<void> _playUnlock(int index, LevelModel level) async {
    if (_unlockPhases[index] != null) return;
    widget.sound.tileTap();
    setState(() => _unlockPhases[index] = _UnlockPhase.unlocking);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _unlockPhases[index] = _UnlockPhase.free);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await widget.storage.revealLevel(level.id);
    if (!mounted) return;
    setState(() => _unlockPhases.remove(index));
    await _openLevel(level);
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
    if (!mounted || accepted != true) return;
    setState(() => _adminAccess = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusCurrentGroup();
    });
  }

  String _lockAsset(int index) {
    return switch (_unlockPhases[index] ?? _UnlockPhase.idle) {
      _UnlockPhase.unlocking => 'assets/stages/unlock.png',
      _UnlockPhase.free => 'assets/stages/free.png',
      _UnlockPhase.idle => 'assets/stages/lock.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final currentNumber = _currentStageIndex + 1;
    final groupStart = (_currentStageIndex ~/ 5) * 5 + 1;
    final groupEnd = (groupStart + 4).clamp(1, _levels.length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.levelMap),
            Text(
              '$groupStart–$groupEnd • ${strings.levelTitle(_levels[_currentStageIndex].id, _levels[_currentStageIndex].title)}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _mode == GameMode.learning
                ? strings.learningMode
                : strings.challengeMode,
            onPressed: () {
              widget.sound.tileTap();
              setState(() {
                _mode = _mode == GameMode.learning
                    ? GameMode.challenge
                    : GameMode.learning;
              });
            },
            icon: Icon(
              _mode == GameMode.learning
                  ? Icons.school_rounded
                  : Icons.emoji_events_rounded,
              color: _mode == GameMode.learning
                  ? AppTheme.startGreen
                  : AppTheme.gold,
            ),
          ),
          IconButton(
            tooltip: 'Admin testing pass',
            onPressed: _adminAccess ? null : _requestAdminAccess,
            icon: Icon(
              _adminAccess ? Icons.lock_open_rounded : Icons.key_rounded,
              color: _adminAccess ? AppTheme.startGreen : AppTheme.textPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Center(
              child: Text(
                '$currentNumber / ${_levels.length}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final mapWidth = constraints.maxWidth;
          final mapHeight = mapWidth / _mapAspectRatio;
          _viewportSize = viewport;
          _mapWidth = mapWidth;

          return Stack(
            children: [
              Positioned.fill(
                child: _mapFocused
                    ? InteractiveViewer(
                        transformationController: _mapController,
                        constrained: false,
                        minScale: 0.18,
                        maxScale: 3.5,
                        boundaryMargin: EdgeInsets.all(viewport.longestSide),
                        child: _buildMapCanvas(
                          mapWidth,
                          mapHeight,
                          strings,
                          interactive: true,
                        ),
                      )
                    : GestureDetector(
                        key: const ValueKey('campaign-map-overview'),
                        behavior: HitTestBehavior.opaque,
                        onTap: _enterFocusedMap,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: IgnorePointer(
                              child: _buildMapCanvas(
                                941,
                                1672,
                                strings,
                                interactive: false,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              PositionedDirectional(
                start: 12,
                end: 12,
                bottom: 10,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.pathCyan),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: Text(
                          strings.campaignMapHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStageNode(
    int index,
    double mapWidth,
    double mapHeight,
    AppLocalizations strings,
  ) {
    final level = _levels[index];
    final center = _stageCenters[index];
    final size = mapWidth * 0.095;
    final unlocked = _isUnlocked(level);
    final revealed = _isRevealed(level);
    final phase = _unlockPhases[index];
    final showLock = !revealed || phase != null;
    final stars = widget.storage.getStars(level.id);

    return Positioned(
      key: ValueKey('stage-node-${index + 1}'),
      left: center.dx * mapWidth - size / 2,
      top: center.dy * mapHeight - size / 2,
      width: size,
      height: size,
      child: Semantics(
        button: true,
        enabled: unlocked,
        label: showLock && unlocked
            ? '${strings.tapToUnlock}: ${index + 1}'
            : strings.levelTitle(level.id, level.title),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleStageTap(index),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Colors.transparent),
              ),
              if (showLock)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.82, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                  child: Image.asset(
                    _lockAsset(index),
                    key: ValueKey(_lockAsset(index)),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              if (!showLock && stars > 0)
                Positioned(
                  bottom: -size * 0.12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (star) => Icon(
                        Icons.star_rounded,
                        size: size * 0.2,
                        color: star < stars ? AppTheme.gold : AppTheme.wallGray,
                      ),
                    ),
                  ),
                ),
              if (!showLock)
                Container(
                  width: size * 0.58,
                  height: size * 0.58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bgDark.withValues(alpha: 0.58),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.72),
                      width: 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.34,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapCanvas(
    double mapWidth,
    double mapHeight,
    AppLocalizations strings, {
    required bool interactive,
  }) {
    return SizedBox(
      width: mapWidth,
      height: mapHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: interactive
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _focusCurrentGroup,
                    child: Image.asset(
                      'assets/stages/map.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                    ),
                  )
                : Image.asset(
                    'assets/stages/map.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
          ),
          for (var index = 0; index < _levels.length; index++)
            _buildStageNode(index, mapWidth, mapHeight, strings),
        ],
      ),
    );
  }
}
