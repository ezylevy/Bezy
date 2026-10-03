import 'package:flutter/foundation.dart';

/// Release feature switches.
///
/// Free Play stays compiled and tested, but is intentionally hidden from the
/// public V1 navigation. Local debug web runs expose it for QA without
/// changing Android, iOS, or release-web navigation.
abstract final class AppFeatures {
  static bool get freePlayEnabled => kIsWeb && kDebugMode;
}
