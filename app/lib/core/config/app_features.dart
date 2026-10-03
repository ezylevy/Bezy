import 'package:flutter/foundation.dart';

/// Release feature switches.
///
/// Free Play stays compiled and tested, but is intentionally hidden from the
/// public V1 navigation. Local debug web runs expose it for QA without
/// changing Android, iOS, or release-web navigation.
abstract final class AppFeatures {
  static bool get freePlayEnabled => kIsWeb && kDebugMode;

  /// V1 has no Learning/Challenge choice for players: the campaign always runs
  /// in the mode Home passes to the world map. The mode code stays compiled and
  /// tested so it can return later as an explicit product decision.
  static const bool modeToggleEnabled = false;

  /// QA-only shortcut that unlocks every stage on the world map. Hidden in
  /// release builds so players always progress linearly.
  static bool get adminPassEnabled => !kReleaseMode;
}
