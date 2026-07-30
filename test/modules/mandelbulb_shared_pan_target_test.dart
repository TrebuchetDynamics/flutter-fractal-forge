import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag';

  test('time-modulated Mandelbulb passes pan into the shader target', () {
    final builder = File(
      'lib/core/modules/builders/raymarched_3d/builder.dart',
    ).readAsStringSync();
    final shader = File(shaderAsset).readAsStringSync();

    expect(
      builder,
      contains('Raymarched3DUniformSlots.mouseX, state.view.pan.x'),
    );
    expect(
      builder,
      contains('Raymarched3DUniformSlots.mouseY, state.view.pan.y'),
    );
    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
    expect(shader, contains('vec3 camPos = target + rot * vec3'));
  });

  test('time-modulated Mandelbulb shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(shaderAsset), isNotNull);
  });
}
