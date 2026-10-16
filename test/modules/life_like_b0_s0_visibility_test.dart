import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zero Life-like masks select no counts, not B0/S0', () {
    final shader = File('shaders/cellular_and_stochastic/maze_ca_gpu.frag')
        .readAsStringSync();

    expect(shader, isNot(contains('if (mask < 9.0)')));
    expect(shader, contains('floor(clamp(mask, 0.0, 511.0) + 0.5)'));
    expect(shader, contains('float birth = maskHas(uBirthMask, n);'));
    expect(shader, contains('float survive = maskHas(uSurvivalMask, n);'));
  });
}
