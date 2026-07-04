import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag';

  test('sine escape-expression shader honors deep-zoom iteration settings', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 500;'));
    expect(shader, contains('float singularGlow = exp(-12.0 * trap);'));
    expect(shader, isNot(contains('vec4(0.0,0.0,0.0,1.0)')));
  });
}
