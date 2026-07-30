import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/juliabulb_3d_gpu.frag';

  test('Juliabulb is one configurable 3D Julia-family identity', () {
    final module = ModuleRegistry().byId('juliabulb_3d');

    expect(module.dimension, FractalDimension.threeD);
    expect(module.shaderAsset, asset);
    expect(
      module.parameters.map((parameter) => parameter.id),
      containsAll(['power', 'cx', 'cy', 'cz']),
    );
    expect(module.builtInPresets, hasLength(3));
    expect(
      module.builtInPresets.map((preset) => preset.moduleId),
      everyElement('juliabulb_3d'),
    );
  });

  test('Juliabulb shader uses the polar power Julia recurrence', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('vec3 z = point;'));
    expect(shader, contains('theta *= power;'));
    expect(shader, contains('phi *= power;'));
    expect(shader, contains(') + uJuliaC;'));
    expect(shader, contains('0.5 * log(radius) * radius'));
  });

  test('Juliabulb shader compiles as a Flutter runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
