import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset = 'shaders/strange_attractors/aizawa_gpu.frag';

  test('Aizawa shader maps world projection to screen with normal pan direction', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('vec2 screenPos = (proj.xy - uCenter) * uZoom;'));
    expect(shader, isNot(contains('vec2 screenPos = proj.xy / uZoom + uCenter;')));
  });

  test('Aizawa shader keeps per-pixel RK4 work bounded for performance', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('for (int seed = 0; seed < 6; seed++)'));
    expect(shader, contains('for (int i = 0; i < 64; i++)'));
    expect(shader, isNot(contains('for (int i = 0; i < 300; i++)')));
  });
}
