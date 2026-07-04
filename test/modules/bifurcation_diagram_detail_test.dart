import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/lyapunov_and_stability/bifurcation_diagram_gpu.frag';

  test('Bifurcation diagram shader keeps nearest-orbit ridge detail', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float ridge = exp(-nearest * 1400.0 / max(uZoom, 0.35));'));
    expect(shader, contains('palette(fract(xNorm + 0.23), uColorScheme) * ridge * 0.42'));
  });
}
