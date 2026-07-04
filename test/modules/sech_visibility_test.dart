import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag';

  test('sech/tanh shader colors bounded no-image regions', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float sechGlow = exp(-10.0 * trap);'));
    expect(shader, contains('orbit += exp(-2.0 * mag2);'));
    expect(shader, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
