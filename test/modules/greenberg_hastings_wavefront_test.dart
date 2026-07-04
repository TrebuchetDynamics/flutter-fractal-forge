import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/cellular_and_stochastic/greenberg_hastings_ca_gpu.frag';

  test('Greenberg-Hastings shader keeps excitable wavefronts visible', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float waveFront = abs(sin('));
    expect(shader, contains('if (state < 0.5 && waveFront < 0.055) state = 1.0;'));
  });
}
