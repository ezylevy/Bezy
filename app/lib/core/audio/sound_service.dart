import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../storage/progress_storage.dart';

/// Central registry for BEZY's original sound effects and tactile feedback.
///
/// To replace a sound without changing code, export a new WAV using the same
/// filename under assets/audio/sfx/. Keep effects short and peak-normalized.
class SoundService {
  final ProgressStorage _storage;
  final List<AudioPlayer> _players = List.generate(6, (_) => AudioPlayer());
  int _nextPlayer = 0;

  SoundService(this._storage);

  void _sound(String filename, {double volume = 0.72}) {
    if (!_storage.isSoundEnabled) return;
    unawaited(_play(filename, volume));
  }

  Future<void> _play(String filename, double volume) async {
    final player = _players[_nextPlayer++ % _players.length];
    try {
      await player.stop();
      await player.play(
        AssetSource('audio/sfx/$filename.wav'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Audio must never interrupt gameplay (and plugin channels are absent in
      // widget tests). A missing/replaced asset therefore fails silently.
    }
  }

  void uiTap() {
    if (_storage.isHapticsEnabled) HapticFeedback.selectionClick();
    _sound('ui_tap', volume: 0.5);
  }

  void toggleChanged(bool enabled) {
    if (_storage.isHapticsEnabled) HapticFeedback.selectionClick();
    if (enabled) _sound('toggle_on', volume: 0.58);
  }

  /// Movement stays silent so forward/back path editing feels fluid. Haptics
  /// still provide tactile confirmation when enabled.
  void tileTap() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void startTile() {
    if (_storage.isHapticsEnabled) HapticFeedback.mediumImpact();
    _sound('tile_start', volume: 0.68);
  }

  /// Silent backtracking with optional tactile confirmation.
  void tileBacktrack() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Warning feedback when hitting a wall or overshooting the sum
  void invalidMove() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    _sound('move_invalid', volume: 0.64);
  }

  void wallBlocked() => _sound('wall_blocked', volume: 0.62);
  void gateBlocked() => _sound('gate_closed', volume: 0.62);
  void lonelyBlocked() => _sound('lonely_locked', volume: 0.62);
  void reset() => _sound('reset', volume: 0.62);
  void hint() => _sound('hint', volume: 0.56);
  void solutionReveal() => _sound('solution_preview', volume: 0.52);
  void solutionStep() => _sound('solution_step', volume: 0.38);
  void messageReport() => _sound('message_report', volume: 0.68);
  void targetReached() => _sound('target_reached', volume: 0.72);
  void stageUnlock() => _sound('stage_unlock', volume: 0.75);
  void mapOpen() => _sound('map_open', volume: 0.48);
  void lockedStage() => _sound('locked_stage', volume: 0.6);
  void timerWarning() => _sound('timer_warning', volume: 0.65);
  void timerFinalTick() => _sound('timer_final_tick', volume: 0.65);
  void timeUp() => _sound('time_up', volume: 0.72);
  void jokerReveal() => _sound('joker_reveal', volume: 0.58);
  void jokerChoose() => _sound('joker_choose', volume: 0.62);
  void iceSlide() => _sound('ice_slide', volume: 0.52);
  void mirror() => _sound('mirror', volume: 0.58);
  void clone() => _sound('clone', volume: 0.58);
  void zero() => _sound('zero', volume: 0.56);
  void blackHole() => _sound('black_hole', volume: 0.6);
  void bomb() => _sound('bomb', volume: 0.65);
  void lonelyUnlock() => _sound('lonely_unlock', volume: 0.58);

  /// Plays once per cold launch, together with the animated home logo.
  void appLaunch() => _sound('app_launch', volume: 0.7);

  /// One short accent per awarded star, after the victory sting.
  void starsEarned(int stars) {
    for (var i = 0; i < stars; i++) {
      Future.delayed(
        Duration(milliseconds: 900 + i * 260),
        () => _sound('star_earned', volume: 0.6),
      );
    }
  }

  /// Celebratory vibration pattern when solving a puzzle
  void victory() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 250), () {
        HapticFeedback.heavyImpact();
      });
    }
    _sound('victory_sting', volume: 0.82);
  }

  /// Feedback when bouncing on a trampoline
  void trampolineBounce() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    _sound('teleport', volume: 0.68);
  }

  /// Feedback when unlocking or passing through a smart gate
  void gatePass() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    _sound('gate_open', volume: 0.65);
  }

  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
  }
}
