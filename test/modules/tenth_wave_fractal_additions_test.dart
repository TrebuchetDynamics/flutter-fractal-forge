import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

const _expected = <String, String>{
  'cubic_connectedness_locus':
      'shaders/escape_time_family/polynomial_maps/cubic_connectedness_locus_gpu.frag',
  'newton_parameter_plane':
      'shaders/root_finding/newton_parameter_plane_gpu.frag',
  'polylogarithm_julia':
      'shaders/escape_time_family/transcendental_maps/polylogarithm_julia_gpu.frag',
  'q_exponential_julia':
      'shaders/escape_time_family/transcendental_maps/q_exponential_julia_gpu.frag',
  'klein_j_invariant': 'shaders/number_theory/klein_j_invariant_gpu.frag',
  'jacobi_theta_field': 'shaders/number_theory/jacobi_theta_field_gpu.frag',
  'eisenstein_series_field':
      'shaders/number_theory/eisenstein_series_field_gpu.frag',
  'gaussian_prime_lattice':
      'shaders/number_theory/gaussian_prime_lattice_gpu.frag',
  'thomae_popcorn_field': 'shaders/number_theory/thomae_popcorn_field_gpu.frag',
  'arnold_tongues': 'shaders/lyapunov_and_stability/arnold_tongues_gpu.frag',
  'kicked_harper_map':
      'shaders/lyapunov_and_stability/kicked_harper_map_gpu.frag',
  'henon_heiles_escape_basin':
      'shaders/lyapunov_and_stability/henon_heiles_escape_basin_gpu.frag',
  'talbot_fractal_carpet':
      'shaders/number_theory/talbot_fractal_carpet_gpu.frag',
  'paperfolding_curve_atlas':
      'shaders/ifs_and_geometric/paperfolding_curve_atlas_gpu.frag',
  'de_rham_curve_family':
      'shaders/ifs_and_geometric/de_rham_curve_family_gpu.frag',
  'substitution_diffraction_field':
      'shaders/number_theory/substitution_diffraction_field_gpu.frag',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tenth-wave modules have stable IDs and declared shader assets', () {
    final registry = ModuleRegistry();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final entry in _expected.entries) {
      final module = registry.byId(entry.key);
      expect(module.shaderAsset, entry.value, reason: entry.key);
      expect(File(entry.value).existsSync(), isTrue, reason: entry.value);
      expect(pubspec, contains('    - ${entry.value}'), reason: entry.value);
      expect(module.defaultPreset.moduleId, entry.key);
    }
  });

  test('tenth-wave formulas are distinct rather than parameter aliases', () {
    const markers = <String, String>{
      'cubic_connectedness_locus': 'z^3-3a^2 z+b',
      'newton_parameter_plane': 'each pixel is the coefficient c',
      'polylogarithm_julia': 'Li_s(z)',
      'q_exponential_julia': '[n]_q',
      'klein_j_invariant': 'j(tau)=E4(tau)^3/Delta(tau)',
      'jacobi_theta_field': 'theta2',
      'eisenstein_series_field': 'E4=1+240',
      'gaussian_prime_lattice': 'Gaussian primes',
      'thomae_popcorn_field': 'f(p/q)=1/q',
      'arnold_tongues': 'Arnold circle map',
      'kicked_harper_map': "p'=p+K sin(q)",
      'henon_heiles_escape_basin': 'Hénon-Heiles Hamiltonian',
      'talbot_fractal_carpet': 'Berry-Klein Talbot carpet',
      'paperfolding_curve_atlas': 'paperfolding curve',
      'de_rham_curve_family': 'de Rham-type self-affine',
      'substitution_diffraction_field': 'Thue-Morse',
    };

    for (final entry in markers.entries) {
      expect(
        File(_expected[entry.key]!).readAsStringSync(),
        contains(entry.value),
        reason: entry.key,
      );
    }
  });

  test('tenth-wave shaders compile as Flutter runtime effects', () async {
    for (final asset in _expected.values) {
      expect(await ui.FragmentProgram.fromAsset(asset), isNotNull,
          reason: asset);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('tenth-wave default views produce measurable pixel structure', () async {
    const size = 64;
    for (final id in _expected.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final program = await ui.FragmentProgram.fromAsset(config.shaderAsset);
      final extras = config.extraParams.map((param) {
        final value = param.defaultValue;
        return (value as num).toDouble();
      });
      final pixels = await renderTestShaderFrame(
        program: program,
        shaderAsset: config.shaderAsset,
        width: size,
        height: size,
        uniforms: [
          0,
          size.toDouble(),
          size.toDouble(),
          config.defaultCenterX ?? 0,
          config.defaultCenterY ?? 0,
          config.defaultZoom,
          config.defaultIterations,
          config.defaultBailout,
          config.defaultColorScheme.toDouble(),
          0,
          ...extras,
        ],
      );

      final colors = <int>{};
      var nonBlack = 0;
      for (var offset = 0; offset < pixels.length; offset += 4) {
        final rgb = (pixels[offset] << 16) |
            (pixels[offset + 1] << 8) |
            pixels[offset + 2];
        colors.add(rgb);
        if (pixels[offset] > 8 ||
            pixels[offset + 1] > 8 ||
            pixels[offset + 2] > 8) {
          nonBlack++;
        }
      }
      expect(colors.length, greaterThan(8), reason: '$id is nearly uniform');
      expect(nonBlack, greaterThan(size * size ~/ 100),
          reason: '$id is effectively all black');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('tenth-wave research has a valid provenance package', () {
    const base = 'research/fractal-types-tenth-wave';
    for (final name in const [
      'queries.txt',
      'coverage-stats.txt',
      'source-inventory.md',
      'report.md',
      'provenance.json',
    ]) {
      expect(File('$base/$name').existsSync(), isTrue, reason: name);
    }

    final provenance = jsonDecode(
      File('$base/provenance.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(provenance['depth'], 'comprehensive');
    expect(provenance['queries'], isA<List<dynamic>>());
    expect((provenance['queries'] as List).length, greaterThanOrEqualTo(20));
    expect(provenance['outputs'], contains('report.md'));
    expect(provenance['errors'], isNotEmpty);
  });
}
