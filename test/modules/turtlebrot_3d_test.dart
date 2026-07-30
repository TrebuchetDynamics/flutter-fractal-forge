import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_math_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/turtlebrot_3d_gpu.frag';

  test('Turtlebrot is one fixed quadratic principal tricomplex slice', () {
    final module = ModuleRegistry().byId('turtlebrot_3d');

    expect(module.dimension, FractalDimension.threeD);
    expect(module.shaderAsset, asset);
    expect(
        module.parameters.any((parameter) => parameter.id == 'power'), isFalse);
  });

  test('shader locks the four reflected-Mousebrot components', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('vec2 c0 = vec2(-point.z, point.x - point.y);'));
    expect(shader, contains('vec2 c1 = vec2(point.z, point.x + point.y);'));
    expect(shader, contains('vec2 c2 = vec2(point.z, point.x - point.y);'));
    expect(shader, contains('vec2 c3 = vec2(-point.z, point.x + point.y);'));
    expect(shader, contains('sqrt(0.25 * (d0 * d0 + d1 * d1 +'));
  });

  test('known points prove Turtlebrot is a strict Mousebrot subset', () {
    final result = RenderMathOracle.evaluate('turtlebrot_3d');

    expect(result.verdict, 'pass');
    expect(result.checks, hasLength(3));
    expect(result.checks.every((check) => check['passed'] == true), isTrue);
  });

  test('shader compiles as a Flutter runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
