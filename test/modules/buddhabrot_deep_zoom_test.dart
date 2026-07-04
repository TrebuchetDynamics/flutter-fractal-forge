import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag';

  test('Buddhabrot shader colors bounded deep-zoom points', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float interiorGlow = exp(-10.0 * trap);'));
    expect(shader, contains('orbit += exp(-2.0 * mag2);'));
    expect(shader, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
