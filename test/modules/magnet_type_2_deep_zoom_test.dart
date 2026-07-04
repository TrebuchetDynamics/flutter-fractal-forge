import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet2_gpu.frag';

  test('Magnet Type II shader colors bounded deep-zoom basins', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float basinGlow = exp(-10.0 * trap);'));
    expect(shader, contains('orbit += exp(-2.0 * mag2);'));
    expect(shader, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
