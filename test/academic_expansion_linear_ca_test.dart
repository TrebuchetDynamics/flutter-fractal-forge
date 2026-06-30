import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lattes map Julia set is registered with pole-guarded shader support',
      () {
    final module = ModuleRegistry().modules.singleWhere(
          (module) => module.id == 'lattes_map_julia',
        );
    final source = File(module.shaderAsset).readAsStringSync();

    expect(
      module.shaderAsset,
      'shaders/escape_time_family/transcendental_maps/lattes_map_julia_gpu.frag',
    );
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains(module.shaderAsset),
    );
    expect(source, contains('R(z) = ((z^2 + 1)^2) / (4 z (z^2 - 1))'));
    expect(source, contains('float poleDistance'));
    expect(source, contains('if (p < 1e-5)'));
    expect(hasNativeCpuFormula('lattes_map_julia'), isTrue);
  });

  test('Lattes map Julia shader compiles as a Flutter runtime effect',
      () async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/escape_time_family/transcendental_maps/lattes_map_julia_gpu.frag',
    );

    expect(program, isNotNull);
  });

  test('substitution tiling candidates are registered with shader support', () {
    final modulesById = {
      for (final module in ModuleRegistry().modules) module.id: module,
    };

    final arnoux = modulesById['arnoux_rauzy_fractal'];
    final dual = modulesById['dual_substitution_tiling'];

    expect(arnoux, isNotNull);
    expect(dual, isNotNull);
    expect(
      arnoux!.shaderAsset,
      'shaders/ifs_and_geometric/arnoux_rauzy_fractal_gpu.frag',
    );
    expect(
      dual!.shaderAsset,
      'shaders/ifs_and_geometric/dual_substitution_tiling_gpu.frag',
    );
    expect(File(arnoux.shaderAsset).existsSync(), isTrue);
    expect(File(dual.shaderAsset).existsSync(), isTrue);
    expect(arnoux.defaultPreset.params['depth'], 12.0);
    expect(dual.defaultPreset.params['depth'], 8.0);
    expect(hasNativeCpuFormula('arnoux_rauzy_fractal'), isTrue);
    expect(hasNativeCpuFormula('dual_substitution_tiling'), isTrue);
  });

  test('substitution tiling shaders compile as Flutter runtime effects',
      () async {
    for (final asset in [
      'shaders/ifs_and_geometric/arnoux_rauzy_fractal_gpu.frag',
      'shaders/ifs_and_geometric/dual_substitution_tiling_gpu.frag',
    ]) {
      final program = await ui.FragmentProgram.fromAsset(asset);
      expect(program, isNotNull, reason: asset);
    }
  });

  test('substitution helpers preserve expected symbolic expansion', () {
    expect(arnouxRauzySubstitute('123', 1), '12131');
    expect(arnouxRauzySubstitute('123', 2), '12232');
    expect(arnouxRauzySubstitute('123', 3), '13233');
    expect(dualSubstitutionStep([0, 1, 2]), [0, 1, 2, 0, 1, 2, 0]);
  });

  test('Klausmeier vegetation is registered with shader and CPU support', () {
    final module = ModuleRegistry().modules.singleWhere(
          (module) => module.id == 'klausmeier_vegetation',
        );
    final source = File(module.shaderAsset).readAsStringSync();

    expect(
      module.shaderAsset,
      'shaders/cellular_and_stochastic/klausmeier_vegetation_gpu.frag',
    );
    expect(
        File('pubspec.yaml').readAsStringSync(), contains(module.shaderAsset));
    expect(source, contains('du/dt = u^2 w - B u + D_u'));
    expect(source, contains('uRainfall'));
    expect(source, contains('uAdvection'));
    expect(module.defaultPreset.params['rainfall'], 2.0);
    expect(module.defaultPreset.params['mortality'], 0.45);
    expect(hasNativeCpuFormula('klausmeier_vegetation'), isTrue);
  });

  test('Klausmeier shader compiles as a Flutter runtime effect', () async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/cellular_and_stochastic/klausmeier_vegetation_gpu.frag',
    );

    expect(program, isNotNull);
  });

  test('Klausmeier CPU cell step stays finite for the researched defaults', () {
    final next = klausmeierCellStep(
      plant: 0.2,
      water: 2.0,
      lapPlant: 0.1,
      lapWater: -0.1,
      rainfall: 2.0,
      mortality: 0.45,
      plantDiffusion: 1.0,
      waterDiffusion: 10.0,
      advectionGradient: 0.2,
      dt: 0.018,
    );

    expect(next.plant.isFinite, isTrue);
    expect(next.water.isFinite, isTrue);
    expect(next.plant, greaterThan(0));
    expect(next.water, greaterThan(0));
  });

  test('excitable cellular automata are registered with shader support', () {
    final modulesById = {
      for (final module in ModuleRegistry().modules) module.id: module,
    };

    final cyclic = modulesById['cyclic_cellular_automaton'];
    final greenberg = modulesById['greenberg_hastings_ca'];

    expect(cyclic, isNotNull);
    expect(greenberg, isNotNull);
    expect(
      cyclic!.shaderAsset,
      'shaders/cellular_and_stochastic/cyclic_cellular_automaton_gpu.frag',
    );
    expect(
      greenberg!.shaderAsset,
      'shaders/cellular_and_stochastic/greenberg_hastings_ca_gpu.frag',
    );
    expect(File(cyclic.shaderAsset).existsSync(), isTrue);
    expect(File(greenberg.shaderAsset).existsSync(), isTrue);
    expect(cyclic.defaultPreset.params['states'], 8.0);
    expect(greenberg.defaultPreset.params['refractoryPeriod'], 8.0);
    expect(hasNativeCpuFormula('cyclic_cellular_automaton'), isTrue);
    expect(hasNativeCpuFormula('greenberg_hastings_ca'), isTrue);
  });

  test('excitable CA shaders compile as Flutter runtime effects', () async {
    for (final asset in [
      'shaders/cellular_and_stochastic/cyclic_cellular_automaton_gpu.frag',
      'shaders/cellular_and_stochastic/greenberg_hastings_ca_gpu.frag',
    ]) {
      final program = await ui.FragmentProgram.fromAsset(asset);
      expect(program, isNotNull, reason: asset);
    }
  });

  test('excitable CA CPU steps follow their published local rules', () {
    expect(
      cyclicCaStep(
        [
          [0, 1, 0],
          [0, 0, 0],
          [0, 0, 0],
        ],
        states: 3,
        threshold: 1,
      )[1][1],
      1,
    );

    final gh = greenbergHastingsStep(
      [
        [0, 1, 0],
        [0, 0, 2],
        [0, 0, 3],
      ],
      threshold: 1,
      refractoryPeriod: 2,
    );
    expect(gh[1][1], 1); // resting center sees an excited neighbour
    expect(gh[0][1], 2); // excited becomes refractory
    expect(gh[1][2], 3); // refractory advances
    expect(gh[2][2], 0); // refractory period ends
  });

  test('Rule 90 and Rule 150 are registered as shader-backed catalog entries',
      () {
    final modulesById = {
      for (final module in ModuleRegistry().modules) module.id: module,
    };

    final rule90 = modulesById['rule90_linear_ca'];
    final rule150 = modulesById['rule150_linear_ca'];

    expect(rule90, isNotNull);
    expect(rule150, isNotNull);
    expect(rule90!.shaderAsset,
        'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag');
    expect(rule150!.shaderAsset, rule90.shaderAsset);
    expect(File(rule90.shaderAsset).existsSync(), isTrue);
    expect(rule90.defaultPreset.params['rule'], 90.0);
    expect(rule150.defaultPreset.params['rule'], 150.0);
    expect(hasNativeCpuFormula('rule90_linear_ca'), isTrue);
    expect(hasNativeCpuFormula('rule150_linear_ca'), isTrue);
  });

  test('shared elementary CA shader is parameterized by rule number', () {
    final source = File(
      'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag',
    ).readAsStringSync();

    expect(source, contains('uniform float uRule'));
    expect(source, contains('float idx = 4.0 * l + 2.0 * c + r'));
    expect(source, contains('elementaryRule'));
  });

  test('Rule 90 single-seed rows match Pascal mod 2 counts', () {
    final counts = [
      for (var gen = 0; gen < 8; gen++)
        elementaryCaSingleSeedRow(rule: 90, generation: gen)
            .where((cell) => cell == 1)
            .length,
    ];

    expect(counts, [1, 2, 2, 4, 2, 4, 4, 8]);
    expect(elementaryCaSingleSeedRow(rule: 150, generation: 1), [1, 1, 1]);
  });
}
