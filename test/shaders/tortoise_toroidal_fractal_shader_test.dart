import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const moduleId = 'tortoise_toroidal_fractal';
  const shaderPath =
      'shaders/ifs_and_geometric/raymarched_3d/tortoise_toroidal_fractal_gpu.frag';

  test('TORTOISE toroidal fractal is a time-driven 3D catalog module', () {
    final module = ModuleRegistry().byId(moduleId);
    final config = raymarched3DCatalog.singleWhere((item) => item.id == moduleId);

    expect(module.dimension, FractalDimension.threeD);
    expect(
      module.animationCapability,
      FractalAnimationCapability.timeDriven,
    );
    expect(module.shaderAsset, shaderPath);
    expect(config.defaultIterations, 2);
    expect(config.minIterations, 1);
    expect(config.maxIterations, 3);
    expect(config.defaultPower, 6);
    expect(module.parameters.map((parameter) => parameter.id), containsAll([
      'power',
      'iterations',
      'steps',
      'bailout',
      'colorScheme',
    ]));
  });

  test('shader preserves the source construction contract', () {
    final source = File(shaderPath).readAsStringSync();

    expect(source, contains('TORTOISE / Symbol Composer'));
    expect(source, contains('positive-chirality'));
    expect(source, contains('negative-chirality'));
    expect(source, contains('carrier torus'));
    expect(source, contains('for (int sector = 0; sector < 6; sector++)'));
    expect(source, contains('for (int generation = 1; generation < 3; generation++)'));
    expect(source, contains('6 explicit parents, then 36 and 216'));
    expect(source, contains('sectorAngle'));
    expect(source, contains('fiberPositive'));
    expect(source, contains('fiberNegative'));
    expect(source, contains('depthFade'));
  });

  test('shader is declared as a Flutter shader asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- $shaderPath'));
  });
}
