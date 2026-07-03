import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared Mandelbulb shader honors reported deep-zoom detail settings',
      () {
    final source = File(
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
    ).readAsStringSync();

    expect(source, contains('clamp(uIterations, 1.0, 64.0)'));
    expect(source, contains('for (int i = 0; i < 64; i++)'));
    expect(source, contains('clamp(uSteps, 10.0, 200.0)'));
    expect(source, contains('for (int i = 0; i < 200; i++)'));
  });
}
