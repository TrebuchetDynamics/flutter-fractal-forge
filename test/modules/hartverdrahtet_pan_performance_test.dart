import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset =
      'shaders/3d_and_hypercomplex/raymarched_volumes/hartverdrahtet_gpu.frag';

  test('Hartverdrahtet uses normal pan target and full rotation ray basis', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
    expect(shader, contains('vec3 ro = target + rot * vec3'));
    expect(
        shader, contains('vec3 rd = normalize(rot * vec3(uv.x, uv.y, -1.5));'));
    expect(shader, isNot(contains('cross(vec3(0.0, 1.0, 0.0)')));
  });

  test('raymarched 3D builder sends view pan through shared pan slots', () {
    final builder = File(
      'lib/core/modules/builders/raymarched_3d/builder.dart',
    ).readAsStringSync();

    expect(
        builder, contains('Raymarched3DUniformSlots.mouseX, state.view.pan.x'));
    expect(
        builder, contains('Raymarched3DUniformSlots.mouseY, state.view.pan.y'));
  });

  test('Hartverdrahtet default params stay below bad-performance issue values',
      () {
    final module = ModuleRegistry().byId('hartverdrahtet');

    expect(module.defaultPreset.params['power'], 2.0);
    expect(module.defaultPreset.params['iterations'], 14.0);
    expect(module.defaultPreset.params['steps'], 90.0);

    final paramsById = {for (final param in module.parameters) param.id: param};
    expect(paramsById['power']!.max, 3.2);
    expect(paramsById['iterations']!.max, 32.0);
  });

  test('Hartverdrahtet raymarch loop is capped for shader performance', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('int maxSteps = int(clamp(uSteps, 30.0, 120.0));'));
    expect(shader, contains('for (int i = 0; i < 120; i++)'));
    expect(shader, isNot(contains('for (int i = 0; i < 170; i++)')));
  });
}
