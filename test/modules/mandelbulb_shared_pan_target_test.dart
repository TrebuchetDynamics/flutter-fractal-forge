import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag';

  test('shared Mandelbulb modules pass pan into the shader target', () {
    final builder = File(
      'lib/core/modules/builders/shared_catalogs/shared_3d_catalog.dart',
    ).readAsStringSync();
    final shader = File(shaderAsset).readAsStringSync();

    expect(builder, contains('shader.setFloat(3, state.view.pan.x);'));
    expect(builder, contains('shader.setFloat(4, state.view.pan.y);'));
    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
    expect(shader, contains('vec3 camPos = target + rot * vec3'));
  });

  test('shared Mandelbulb shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(shaderAsset), isNotNull);
  });
}
