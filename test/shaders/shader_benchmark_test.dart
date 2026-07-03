// This benchmark is intentionally disabled in `flutter test` runs.
//
// A device/real engine is required for meaningful shader performance numbers.
// Use the integration test version instead:
//   integration_test/shader_benchmark_test.dart
//
// NOTE: We still include a skipped test so the file is not reported as
// "No tests were found" (exit code 79) by CI/cron quality checks.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shader benchmark placeholder (skipped)', () {
    // Intentionally empty.
  }, skip: 'Benchmark requires a real device; see integration_test/shader_benchmark_test.dart');
}
