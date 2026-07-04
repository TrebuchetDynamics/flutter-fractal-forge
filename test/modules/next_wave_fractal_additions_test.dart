import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, ({String shader, FractalDimension dimension})>{
    'quasicrystal_interference': (
      shader: 'shaders/ifs_and_geometric/quasicrystal_interference_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'l_system_plants_trees': (
      shader: 'shaders/ifs_and_geometric/l_system_plants_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'brownian_tree_dla': (
      shader: 'shaders/cellular_and_stochastic/brownian_tree_dla_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'multifractal_plasma_cascade': (
      shader: 'shaders/cellular_and_stochastic/multifractal_plasma_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'kleinian_schottky_necklace': (
      shader: 'shaders/ifs_and_geometric/kleinian_schottky_necklace_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
  };

  test('next-wave researched fractal additions are registered', () {
    final registry = ModuleRegistry();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final entry in expected.entries) {
      final module = registry.byId(entry.key);
      expect(module.shaderAsset, entry.value.shader);
      expect(module.dimension, entry.value.dimension);
      expect(File(entry.value.shader).existsSync(), isTrue,
          reason: '${entry.value.shader} should exist');
      expect(pubspec, contains('- ${entry.value.shader}'),
          reason: '${entry.value.shader} should be declared in pubspec.yaml');
    }
  });
}
