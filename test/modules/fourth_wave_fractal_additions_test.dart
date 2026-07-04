import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, ({String shader, FractalDimension dimension})>{
    'fractal_antenna_curves': (
      shader: 'shaders/ifs_and_geometric/fractal_antenna_curves_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'levy_brownian_paths': (
      shader: 'shaders/cellular_and_stochastic/levy_brownian_paths_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'basin_entropy_uncertainty': (
      shader: 'shaders/root_finding/basin_entropy_map_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'ulam_warburton_toothpick': (
      shader:
          'shaders/cellular_and_stochastic/ulam_warburton_toothpick_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'circle_packing_conformal_map': (
      shader: 'shaders/ifs_and_geometric/circle_packing_conformal_map_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
  };

  test('fourth-wave researched fractal additions are registered', () {
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
