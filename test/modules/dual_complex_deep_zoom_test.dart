import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/3d_and_hypercomplex/hypercomplex_escape_time/dual_complex_gpu.frag';

  test('Dual-Complex shader colors bounded deep-zoom points', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float dualGlow = exp(-8.0 * trap);'));
    expect(shader, contains('orbit += exp(-2.0 * magSq);'));
    expect(shader, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
