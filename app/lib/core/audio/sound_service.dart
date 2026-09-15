import 'package:flutter/services.dart';
import '../storage/progress_storage.dart';

/// Centralized service for sound and tactile haptic feedback.
class SoundService {
  final ProgressStorage _storage;

  SoundService(this._storage);

  /// Subtle click when touching or selecting a tile
  void tileTap() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Feedback when backtracking / unselecting a tile
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
  }

  /// Feedback when bouncing on a trampoline
  void trampolineBounce() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Feedback when unlocking or passing through a smart gate
  void gatePass() {
    if (_storage.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }
}
