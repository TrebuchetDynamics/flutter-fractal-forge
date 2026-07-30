import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_math_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/tetrabrot_3d_gpu.frag';

  test('Tetrabrot is one fixed quadratic tricomplex slice identity', () {
    final module = ModuleRegistry().byId('tetrabrot_3d');

    expect(module.dimension, FractalDimension.threeD);
    expect(module.shaderAsset, asset);
    expect(
        module.parameters.any((parameter) => parameter.id == 'power'), isFalse);
  });

  test('shader locks the two idempotent complex Mandelbrot components', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('vec2 cMinus = vec2(point.x, point.y - point.z);'));
    expect(shader, contains('vec2 cPlus = vec2(point.x, point.y + point.z);'));
    expect(shader, contains('float complexMandelbrotDistance(vec2 c)'));
    expect(shader, contains('sqrt(0.5 * (minusDistance * minusDistance +'));
  });

  test('known Tetrabrot points pass the component-membership oracle', () {
    final result = RenderMathOracle.evaluate('tetrabrot_3d');

    expect(result.verdict, 'pass');
    expect(result.checks, hasLength(3));
    expect(result.checks.every((check) => check['passed'] == true), isTrue);
  });

  test('shader compiles as a Flutter runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
