import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/clifford_gpu.frag';

  test('Clifford shader honors high-detail shared catalog settings', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 500;'));
    expect(shader, contains('int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)))'));
  });
}
