import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, ({String shader, FractalDimension dimension})>{
    'external_rays_equipotential_overlay': (
      shader:
          'shaders/escape_time_family/orbit_and_domain/external_rays_equipotential_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'newton_flow_streamlines': (
      shader: 'shaders/root_finding/newton_flow_streamlines_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'wada_riddled_basin_visualizer': (
      shader: 'shaders/root_finding/wada_riddled_basins_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'fuchsian_limit_set_lace': (
      shader: 'shaders/ifs_and_geometric/fuchsian_limit_set_lace_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'wild_knot_pearl_limit_set': (
      shader: 'shaders/ifs_and_geometric/wild_knot_pearls_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
  };

  test('fifth-wave researched fractal additions are registered', () {
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
