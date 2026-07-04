import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/escape_time_family/core/julia_gpu.frag';

  test('Julia shader colors bounded low-detail regions with trap detail', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('minDistSq = min(minDistSq, dSq);'));
    expect(shader, contains('float trapGlow = exp(-8.0 * sqrt(minDistSq)) + exp(-10.0 * crossDist);'));
    expect(shader, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
