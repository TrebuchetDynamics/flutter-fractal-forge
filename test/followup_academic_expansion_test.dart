import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_test/flutter_test.dart';

const _expectedModules = <String, String>{
  'complex_henon_julia_slice':
      'shaders/escape_time_family/transcendental_maps/complex_henon_julia_slice_gpu.frag',
  'flow_lenia': 'shaders/cellular_and_stochastic/flow_lenia_gpu.frag',
  'bedford_mcmullen_carpet':
      'shaders/ifs_and_geometric/bedford_mcmullen_carpet_gpu.frag',
  'hofstadter_butterfly':
      'shaders/escape_time_family/geometry_and_ifs/hofstadter_butterfly_gpu.frag',
  'mimura_murray_predator_prey':
      'shaders/cellular_and_stochastic/mimura_murray_predator_prey_gpu.frag',
  'gerhardt_schuster_tyson_ca':
      'shaders/cellular_and_stochastic/gerhardt_schuster_tyson_ca_gpu.frag',
  'coupled_logistic_map_lattice':
      'shaders/cellular_and_stochastic/coupled_logistic_map_lattice_gpu.frag',
  'higher_order_root_basin_family':
      'shaders/root_finding/higher_order_root_basin_family_gpu.frag',
  'self_affine_finite_type':
      'shaders/ifs_and_geometric/self_affine_finite_type_gpu.frag',
  'stable_square_turing_model':
      'shaders/cellular_and_stochastic/stable_square_turing_model_gpu.frag',
  'implicit_affine_fractal_surface':
      'shaders/ifs_and_geometric/raymarched_3d/implicit_affine_fractal_surface_gpu.frag',
  'matrix_logistic_spectrum':
      'shaders/escape_time_family/transcendental_maps/matrix_logistic_spectrum_gpu.frag',
};

void main() {
  test('follow-up academic candidates are registered and shader-backed', () {
    final modulesById = {
      for (final module in ModuleRegistry().modules) module.id: module,
    };
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final entry in _expectedModules.entries) {
      final module = modulesById[entry.key];
      expect(module, isNotNull, reason: entry.key);
      expect(module!.shaderAsset, entry.value);
      expect(File(entry.value).existsSync(), isTrue, reason: entry.value);
      expect(pubspec, contains(entry.value), reason: entry.value);
      expect(module.defaultPreset.moduleId, entry.key);
      if (entry.key != 'hofstadter_butterfly') {
        expect(hasNativeCpuFormula(entry.key), isTrue, reason: entry.key);
      }
    }
  });

  test('follow-up shader sources expose the researched formulas/rules', () {
    expect(
      File(_expectedModules['complex_henon_julia_slice']!).readAsStringSync(),
      contains('H_{a,c}(z,w)=(z^2+c-a*w, z)'),
    );
    expect(
      File(_expectedModules['bedford_mcmullen_carpet']!).readAsStringSync(),
      contains('Bedford'),
    );
    expect(
      File(_expectedModules['coupled_logistic_map_lattice']!)
          .readAsStringSync(),
      contains('uCoupling'),
    );
    expect(
      File(_expectedModules['flow_lenia']!).readAsStringSync(),
      contains('mass-conservative flow'),
    );
  });

  test('follow-up shaders compile as Flutter runtime effects', () async {
    for (final asset in _expectedModules.values.toSet()) {
      final program = await ui.FragmentProgram.fromAsset(asset);
      expect(program, isNotNull, reason: asset);
    }
  }, timeout: const Timeout(Duration(seconds: 120)));

  test('CPU helpers lock core follow-up formulas', () {
    final henon = complexHenonStep(
      zx: 0.2,
      zy: -0.1,
      wx: 0.0,
      wy: 0.0,
      a: 0.3,
      cReal: -0.65,
      cImag: 0.35,
    );
    expect(henon.zx, closeTo(-0.62, 1e-12));
    expect(henon.zy, closeTo(0.31, 1e-12));
    expect(henon.wx, closeTo(0.2, 1e-12));
    expect(henon.wy, closeTo(-0.1, 1e-12));

    expect(bedfordMcMullenContains(0.1, 0.1, 2), isTrue);
    expect(bedfordMcMullenContains(0.5, 0.1, 1), isFalse);

    expect(
      coupledLogisticStep(
        left: 0.2,
        center: 0.5,
        right: 0.8,
        r: 3.9,
        coupling: 0.18,
      ),
      closeTo(0.91182, 1e-5),
    );

    expect(
      flowLeniaGrowth(potential: 0.15, center: 0.15, width: 0.015),
      closeTo(1.0, 1e-12),
    );
  });
}
