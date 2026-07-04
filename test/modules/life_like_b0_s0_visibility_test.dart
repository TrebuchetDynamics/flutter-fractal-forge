import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/cellular_and_stochastic/maze_ca_gpu.frag';

  test('Life-like B0/S0 shader treats small masks as neighbor counts', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('if (mask < 9.0)'));
    expect(shader, contains('abs(count - floor(mask + 0.5))'));
    expect(shader, contains('float birth = maskHas(uBirthMask, n);'));
  });
}
