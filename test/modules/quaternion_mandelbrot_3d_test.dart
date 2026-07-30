import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_math_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_mandelbrot_3d_gpu.frag';

  test('Quaternion Mandelbrot is a distinct parameter-space identity', () {
    final module = ModuleRegistry().byId('quaternion_mandelbrot_3d');

    expect(module.dimension, FractalDimension.threeD);
    expect(module.shaderAsset, asset);
    expect(
        module.parameters.any((parameter) => parameter.id == 'power'), isFalse);
  });

  test('shader locks q0 = 0 and the quaternion parameter recurrence', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('vec4 z = vec4(0.0);'));
    expect(shader, contains('vec4 c = vec4(pos, 0.0);'));
    expect(shader, contains('z = zSquared + c;'));
    expect(
        shader, contains('derivative = 2.0 * length(z) * derivative + 1.0;'));
  });

  test('known quaternion parameter points pass the CPU oracle', () {
    final result = RenderMathOracle.evaluate('quaternion_mandelbrot_3d');

    expect(result.verdict, 'pass');
    expect(result.checks, hasLength(3));
    expect(result.checks.every((check) => check['passed'] == true), isTrue);
  });

  test('shader compiles as a Flutter runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
