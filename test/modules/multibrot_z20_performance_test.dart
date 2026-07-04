import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset =
      'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag';

  test('shared Multibrot shader keeps z^20 randomize cost bounded', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 320;'));
    expect(shader, contains('vec2 zPow = cpowReal(z, power);'));
    expect(shader, contains('power * cdiv(zPow, z)'));
    expect(shader, isNot(contains('power * cpowReal(z, power - 1.0)')));
    expect(shader, isNot(contains('const int MAX_ITERS = 2000;')));
  });
}
