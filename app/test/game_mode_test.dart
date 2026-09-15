import 'package:bezy/domain/models/game_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameMode help policy', () {
    test('Learning mode allows hints and guided solutions', () {
      expect(GameMode.learning.allowsHints, isTrue);
      expect(GameMode.learning.allowsSolutions, isTrue);
    });

    test('Challenge mode blocks hints and guided solutions', () {
      expect(GameMode.challenge.allowsHints, isFalse);
      expect(GameMode.challenge.allowsSolutions, isFalse);
    });
  });
}
