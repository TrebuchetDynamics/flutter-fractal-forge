import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Power-formula shader regressions', () {
    const checks = <String, List<String>>{
      'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag': [
        'if (dot(c, c) > bailoutSq)',
        'float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(3.0);',
      ],
      'shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag': [
        'if (dot(c, c) > bailoutSq)',
        'float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(4.0);',
      ],
      'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_power4_gpu.frag': [
        'if (dot(c, c) > bailoutSq)',
        'float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(4.0);',
      ],
      'shaders/escape_time_family/families/mandelbar/mandelbar_power6_gpu.frag': [
        'if (dot(c, c) > bailoutSq)',
        'float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(6.0);',
      ],
      'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_power6_gpu.frag': [
        'if (dot(c, c) > bailoutSq)',
        'float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(6.0);',
      ],
    };

    for (final entry in checks.entries) {
      test('${entry.key} contains corrected smoothing + early-out', () {
        final source = File(entry.key).readAsStringSync();
        for (final snippet in entry.value) {
          expect(
            source,
            contains(snippet),
            reason: 'Missing snippet in ${entry.key}: $snippet',
          );
        }
      });
    }
  });
}
