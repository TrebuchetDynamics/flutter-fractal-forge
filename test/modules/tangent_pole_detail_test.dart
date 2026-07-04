import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/trigonometric_and_transcendental/elementary_trig/tangent_gpu.frag';

  test('Tangent shader highlights tan pole structure', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float poleTrap = 1e9;'));
    expect(shader, contains('poleTrap = min(poleTrap, length(ccos(z)));'));
    expect(shader, contains('float poleGlow = exp(-6.0 * poleTrap);'));
  });
}
