import 'dart:io';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, ({String shader, FractalDimension dimension})>{
    'bifurcation_diagram_explorer': (
      shader: 'shaders/lyapunov_and_stability/bifurcation_diagram_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'voronoi_fractal_crackle': (
      shader: 'shaders/ifs_and_geometric/voronoi_fractal_crackle_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'takagi_blancmange_staircase': (
      shader: 'shaders/number_theory/takagi_blancmange_staircase_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'fractal_interpolation_curves': (
      shader: 'shaders/number_theory/fractal_interpolation_curves_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
    'strange_nonchaotic_attractor': (
      shader: 'shaders/strange_attractors/strange_nonchaotic_gpu.frag',
      dimension: FractalDimension.twoD,
    ),
  };

  test('third-wave researched fractal additions are registered', () {
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
