import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, ({String shader, FractalDimension dimension})>{
    'pascal_ulam_number_fractals': (
      shader: 'shaders/number_theory/pascal_ulam_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'fractal_terrain_noise': (
      shader: 'shaders/cellular_and_stochastic/fractal_terrain_noise_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'circle_inversion_gasket': (
      shader: 'shaders/ifs_and_geometric/circle_inversion_gasket_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'poincare_disk_tiling': (
      shader: 'shaders/ifs_and_geometric/poincare_disk_tiling_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'apollonian_sphere_packing_3d': (
      shader:
          'shaders/3d_and_hypercomplex/raymarched_volumes/apollonian_sphere_packing_gpu.frag',
      dimension: FractalDimension.threeD,
    ),
  };

  test('research-backed fractal additions are registered with shader assets',
      () {
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
