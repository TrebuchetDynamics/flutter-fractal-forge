import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final registry = ModuleRegistry();
  final repo = CatalogRepository.fromRegistry(registry);
  FractalMathematics math(String id) =>
      repo.byCatalogId('core.$id').mathematics;

  test('semantic source classification overrides renderer builder defaults',
      () {
    for (final pair in {
      'newton_z3': 'Root finding',
      'halley': 'Root finding',
      'hypercomplex_newton': 'Root finding',
      'henon': 'Maps, flows and attractors',
      'highlife': 'Cellular automata and growth',
      'ammann_beenker': 'Tilings, substitutions and L-systems',
      'apollonian_gasket': 'IFS and geometric constructions',
      'quaternion_julia_2d': 'Complex dynamics',
      'julia': 'Complex dynamics',
    }.entries) {
      expect(repo.byCatalogId('core.${pair.key}').category, pair.value);
      expect(math(pair.key).family, pair.value);
    }
    final unknown = buildEscapeTimeModule(const EscapeTimeConfig(
      id: 'newton_julia_lookalike',
      name: 'Julia Newton',
      shaderAsset: 'shaders/unreviewed/julia_gpu.frag',
    ));
    final metadata =
        FractalMathematics.forModule(unknown, category: 'Escape-Time');
    expect(metadata.family, 'Unclassified');
    expect(metadata.qualification, 'Unverified identity');
    expect(metadata.groupId, unknown.id);
    expect(metadata.formula({}), startsWith('Unverified formula'));
    final reused = buildEscapeTimeModule(const EscapeTimeConfig(
      id: 'unreviewed_shader_reuse',
      name: 'Unreviewed',
      shaderAsset: 'shaders/escape_time_family/core/julia_gpu.frag',
    ));
    expect(FractalMathematics.forModule(reused).groupId, reused.id);
  });

  test('Julia defaults and partial edits describe current c, not fixed name',
      () {
    expect(math('julia').formula({}), contains('(-0.8, 0.156)'));
    expect(
        math('julia').formula({'juliaCReal': 0.2}), contains('(0.2, 0.156)'));
    expect(math('julia').view, 'Dynamical plane');
    expect(math('f0166_chebyshev_julia').groupId, math('julia').groupId);
  });

  test('Phoenix uses shader integer selector and fixed core exponent', () {
    expect(math('f0132_phoenix_d_3').formula({'phoenixPower': 4.6}),
        contains('z(n)^5'));
    expect(math('f0132_phoenix_d_3').formula({'phoenixPower': 99}),
        contains('z(n)^8'));
    expect(math('phoenix').formula({'phoenixPower': 7}), contains('z(n)^2'));
    expect(math('phoenix').relationship, contains('memory term'));
    expect(math('phoenix').groupId, isNot(math('julia').groupId));
  });

  test('Multibrot separates polynomial, branch and rational cases and locks',
      () {
    expect(math('multibrot3').formula({'power': 4}),
        contains('integer-degree polynomial'));
    expect(math('multibrot3').formula({'power': 3.5}),
        contains('branch-selected real power'));
    expect(math('multibrot3').formula({'power': -3}),
        contains('rational-map variant, not inverse iteration'));
    expect(math('multibrot3').formula({'power': -3}), contains('z(0) = c'));
    expect(math('multibrot3').formula({'power': 0}), contains('z(n)^3'));
    expect(math('multibrot3').formula({'power': 100}), contains('z(n)^24'));
    expect(math('f0097_multibrot_d_3_5').formula({'power': 12}),
        contains('z(n)^3.5'));
  });

  test('conjugate and absolute-value recurrences retain effective powers', () {
    expect(math('tricorn').formula({}), contains('quadratic Tricorn'));
    expect(math('f0106_tricorn_d_9').formula({'power': 3.5}),
        contains('conj(z(n))^3.5'));
    expect(math('f0113_burning_ship_d_7').formula({'power': 99}),
        contains(')^16.0'));
    expect(math('burning_ship').relationship,
        contains('componentwise absolute value'));
    expect(math('tricorn').groupId, isNot(math('burning_ship').groupId));
  });

  test('expression selector mirrors truncation, clamps and source branches',
      () {
    expect(math('f0498_sin_z_c').formula({'variant': 14.9}),
        contains('z*exp(-z^2)+c'));
    expect(
        math('f0498_sin_z_c').formula({'variant': 99}), contains('exp(z)+z+c'));
    final mobius = math('f0498_sin_z_c').formula({'variant': 9});
    expect(mobius, contains('(exp(0.7*i)*z+1)/(z+exp(-0.7*i))'));
    expect(mobius, contains('z(0) = c'));
    expect(math('f0499_cos_z_c').formula({'variant': 4}),
        contains('z+cos(z)/sin(z)+c'));
    expect(math('f0499_cos_z_c').formula({'variant': 4}),
        contains('input components clamped to +/-12'));
  });

  test('Life-like mask rule reflects current edits including empty survival',
      () {
    expect(math('life_like_b008_s000').formula({}), contains('B3/S;'));
    expect(
        math('life_like_b008_s000')
            .formula({'birthMask': 9, 'survivalMask': 17}),
        contains('B03/S04;'));
    expect(math('life_like_b008_s000').qualification,
        'Rule-inspired procedural visualization');
    expect(math('life_like_b008_s000').view, 'Procedural rule view');
  });

  test(
      'orbit traps group recurrence without claiming identical catalog entries',
      () {
    expect(math('f1162_orbit_trap_multi_lines_cross').groupId,
        math('mandelbrot').groupId);
    expect(math('mandelbrot_orbit_trap').method, 'Orbit-trap coloring');
    expect(math('mandelbrot_orbit_trap').formula({'trapMode': 7}),
        contains('mode 7 changes measurement/coloring'));
    expect(math('mandelbrot_orbit_trap').relationship,
        contains('Coloring/measurement'));
  });

  test('root methods remain distinct and color is not convergence evidence',
      () {
    expect(math('newton_z3').formula({'relaxation': 9}), contains('2.0*f/f\''));
    expect(math('newton_z3').qualification,
        contains('color does not prove convergence'));
    expect(math('halley').method, 'Halley');
    expect(
        math('halley').formula({}), contains('relaxation uniform not bound'));
    expect(math('householder').groupId, isNot(math('newton_z3').groupId));
  });

  test('algebra, view, inspired qualification and relationship are separate',
      () {
    expect(math('henon').view, contains('not orbit density'));
    expect(math('henon').formula({}), contains('1 - 1.4*x(n)^2'));
    expect(math('quaternion_julia_2d').algebra, 'Quaternion');
    expect(math('quaternion_julia_2d').view, contains('2D'));
    expect(math('ammann_beenker').qualification, startsWith('Tiling-inspired'));
    expect(math('apollonian_gasket').qualification,
        startsWith('Packing-inspired'));
    expect(math('apollonian_gasket').formula({}),
        startsWith('Unverified formula'));
  });
}
