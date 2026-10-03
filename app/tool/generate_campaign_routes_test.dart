import 'package:flutter_test/flutter_test.dart';

import 'generate_campaign_routes.dart' as generator;

void main() {
  test(
    'generates the frozen DFS route cache',
    generator.main,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
