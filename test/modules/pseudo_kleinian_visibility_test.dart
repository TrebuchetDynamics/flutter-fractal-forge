import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/ifs_and_geometric/pseudo_kleinian_gpu.frag';

  test('Pseudo-Kleinian is promoted to a rotatable 3D module', () {
    final module = ModuleRegistry().byId('pseudo_kleinian');

    expect(module.dimension, FractalDimension.threeD);
    expect(module.shaderAsset, asset);
    expect(
        module.parameters.any((parameter) => parameter.id == 'power'), isTrue);
  });

  test('Pseudo-Kleinian keeps box fold, sphere inversion, and 3D camera', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('2.0 * clamp(z'));
    expect(
        shader, contains('float inversion = max(1.0 / radiusSquared, 1.0);'));
    expect(shader, contains('derivative *= inversion;'));
    expect(shader, contains('mat3 rotation = rotationMatrix(uRotation);'));
    expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'));
  });

  test('Pseudo-Kleinian shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
