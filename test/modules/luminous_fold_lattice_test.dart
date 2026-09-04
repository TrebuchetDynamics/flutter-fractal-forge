import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/raymarched_3d/builder.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

const _shaderAsset =
    'shaders/3d_and_hypercomplex/raymarched_volumes/luminous_fold_lattice_gpu.frag';
const _identity = 'luminous_fold_lattice';
const _presetIds = <String>[
  'luminous_fold_lattice-ember-vault',
  'luminous_fold_lattice-violet-cathedral',
  'luminous_fold_lattice-ice-lantern',
];
const _productionSecond = 1000.0 / 86400.0;

Future<Uint8List> _render(
  ui.FragmentProgram program,
  Raymarched3DConfig config, {
  int size = 64,
  double time = 0,
  double? power,
  double? iterations,
  double? steps,
  double? bailout,
  double? colorScheme,
  double? zoom,
  double? rotationX,
  double? rotationY,
  double? rotationZ,
  double transparent = 0,
}) {
  return renderTestShaderFrame(
    program: program,
    shaderAsset: _shaderAsset,
    width: size,
    height: size,
    uniforms: [
      time,
      size.toDouble(),
      size.toDouble(),
      0,
      0,
      zoom ?? config.defaultZoom,
      rotationX ?? config.defaultRotationX,
      rotationY ?? config.defaultRotationY,
      rotationZ ?? config.defaultRotationZ,
      power ?? config.defaultPower,
      iterations ?? config.defaultIterations,
      steps ?? config.defaultSteps,
      bailout ?? config.defaultBailout,
      colorScheme ?? config.defaultColorScheme.toDouble(),
      config.defaultFractalType.toDouble(),
      transparent,
    ],
  );
}

int _differingPixels(Uint8List a, Uint8List b) {
  var count = 0;
  for (var offset = 0; offset < a.length; offset += 4) {
    if (a[offset] != b[offset] ||
        a[offset + 1] != b[offset + 1] ||
        a[offset + 2] != b[offset + 2] ||
        a[offset + 3] != b[offset + 3]) {
      count++;
    }
  }
  return count;
}

Raymarched3DConfig get _config =>
    raymarched3DCatalog.singleWhere((entry) => entry.id == _identity);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog exposes one clean-room glowmarcher formula identity', () {
    final config = _config;
    final registry = ModuleRegistry();
    final module = registry.byId(_identity);

    expect(config.name, 'Luminous Fold Lattice');
    expect(config.shaderAsset, _shaderAsset);
    expect(config.maxFractalType, 0, reason: 'identity selector exposed');
    expect(config.defaultFractalType, 0);
    expect(module.dimension, FractalDimension.threeD);
    expect(
      module.animationCapability,
      FractalAnimationCapability.timeDriven,
    );
    expect(
      module.parameters.map((parameter) => parameter.id),
      isNot(contains('fractalType')),
      reason: 'identity must not be user-switchable',
    );
    expect(config.minPower, 1.45);
    expect(config.maxPower, 2.8);
    expect(config.minIterations, 2);
    expect(config.maxIterations, 9);
    expect(config.defaultSteps, 128);
    expect(config.defaultBailout, 6.0);
    expect(config.maxColorScheme, 3);

    final presetIds = module.builtInPresets.map((preset) => preset.id);
    for (final presetId in _presetIds) {
      expect(presetIds, contains(presetId), reason: 'missing preset $presetId');
    }
    expect(presetIds, contains('$_identity-classic'));
  });

  test('shader is analytic, sampler-free, and glowmarch-construction-complete',
      () {
    final source = File(_shaderAsset).readAsStringSync();

    expect(RegExp(r'uniform\s+sampler').hasMatch(source), isFalse);
    expect(source, contains('latticeDistance'));
    expect(source, contains('roundedOctahedron'));
    expect(source, contains('sphereInterval'));
    expect(source, contains('emission +='));
    expect(source, contains('inverseScale'));
    expect(source, contains('clean-room'));
    expect(source, contains('1.0 - exp(-color'));
  });

  test('registered shader asset is present in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- $_shaderAsset'));
  });

  test('default view renders a structured luminous object with black space',
      () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final bytes = await _render(program, _config, size: size);

    var visible = 0;
    var black = 0;
    final colors = <int>{};
    for (var offset = 0; offset < bytes.length; offset += 4) {
      final red = bytes[offset];
      final green = bytes[offset + 1];
      final blue = bytes[offset + 2];
      final brightness = red > green
          ? (red > blue ? red : blue)
          : (green > blue ? green : blue);
      if (brightness > 18) visible++;
      if (brightness < 4) black++;
      colors.add((red >> 3) << 10 | (green >> 3) << 5 | (blue >> 3));
    }
    expect(visible, greaterThan(size * size ~/ 100));
    expect(visible, lessThan(size * size * 4 ~/ 5));
    expect(black, greaterThan(size * size ~/ 8));
    expect(colors.length, greaterThan(32));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('maximum accepted zoom keeps finite visible output', () async {
    const size = 32;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final bytes = await _render(program, _config, size: size, zoom: 1e12);
    var colored = 0;
    for (var offset = 0; offset < bytes.length; offset += 4) {
      if (bytes[offset] > 0 || bytes[offset + 1] > 0 || bytes[offset + 2] > 0) {
        colored++;
      }
    }
    expect(colored, greaterThan(0), reason: 'collapsed at maximum zoom');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('production-clock motion visibly advances the lattice', () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final first = await _render(program, _config, size: size);
    final second = await _render(
      program,
      _config,
      size: size,
      time: _productionSecond,
    );
    expect(
      _differingPixels(first, second),
      greaterThan(size * size ~/ 100),
      reason: 'does not visibly advance after one production second',
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('all exposed rendering controls remain active', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final baseline = await _render(program, _config, size: size);
    final variants = <String, Future<Uint8List>>{
      'power minimum':
          _render(program, _config, size: size, power: _config.minPower),
      'power maximum':
          _render(program, _config, size: size, power: _config.maxPower),
      'iteration minimum': _render(program, _config,
          size: size, iterations: _config.minIterations),
      'iteration maximum': _render(program, _config,
          size: size, iterations: _config.maxIterations),
      'step budget': _render(program, _config, size: size, steps: 20),
      'bailout': _render(program, _config, size: size, bailout: 1),
      'palette': _render(
        program,
        _config,
        size: size,
        colorScheme: ((_config.defaultColorScheme + 1) % 4).toDouble(),
      ),
      'rotation': _render(
        program,
        _config,
        size: size,
        rotationX: _config.defaultRotationX + 0.55,
      ),
    };
    for (final entry in variants.entries) {
      final changed = await entry.value;
      expect(
        _differingPixels(baseline, changed),
        greaterThan(size * size ~/ 250),
        reason: '${entry.key} is inert',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('curated presets render distinct luminous structures', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final module = ModuleRegistry().byId(_identity);
    final baseline = await _render(program, _config, size: size);
    final renders = <Uint8List>[];
    for (final presetId in _presetIds) {
      final preset =
          module.builtInPresets.singleWhere((entry) => entry.id == presetId);
      final params = preset.params;
      final view = preset.view;
      renders.add(
        await _render(
          program,
          _config,
          size: size,
          power: (params['power'] as num).toDouble(),
          iterations: (params['iterations'] as num).toDouble(),
          steps: (params['steps'] as num).toDouble(),
          bailout: (params['bailout'] as num).toDouble(),
          colorScheme: (params['colorScheme'] as num).toDouble(),
          zoom: view.zoom,
          rotationX: view.rotation.x,
          rotationY: view.rotation.y,
          rotationZ: view.rotation.z,
        ),
      );
    }
    for (final rendered in renders) {
      expect(
        _differingPixels(baseline, rendered),
        greaterThan(size * size ~/ 100),
        reason: 'preset is visually indistinct from the default view',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('transparent misses stay clear and premultiplied', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final bytes = await _render(program, _config, size: size, transparent: 1);
    var clear = 0;
    var visible = 0;
    for (var offset = 0; offset < bytes.length; offset += 4) {
      final alpha = bytes[offset + 3];
      if (alpha == 0) clear++;
      if (alpha > 96) visible++;
      expect(bytes[offset], lessThanOrEqualTo(alpha), reason: 'red');
      expect(bytes[offset + 1], lessThanOrEqualTo(alpha), reason: 'green');
      expect(bytes[offset + 2], lessThanOrEqualTo(alpha), reason: 'blue');
    }
    expect(clear, greaterThan(size * size ~/ 8));
    expect(visible, greaterThan(size * size ~/ 100));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('research package records the visual lead and clean-room policy', () {
    const base = 'research/shadertoy-scySRd-glowmarcher';
    for (final name in const [
      'source-inventory.md',
      'report.md',
      'provenance.json',
      'evidence-gaps.json',
    ]) {
      expect(File('$base/$name').existsSync(), isTrue, reason: name);
    }
    final provenance = jsonDecode(
      File('$base/provenance.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(provenance['asset_policy'], 'observation-only-original-code');
    expect(provenance['assets_imported'], isFalse);
    final visualLead = provenance['public_visual_lead'] as Map<String, dynamic>;
    expect(visualLead['author'], 'mrange');
    expect(visualLead['url'], 'https://www.shadertoy.com/view/scySRd');
    expect(visualLead['license'], 'unknown');
    expect(visualLead['observation_only'], isTrue);
    expect(
      File('$base/evidence-gaps.json').readAsStringSync(),
      contains('unavailable'),
    );

    final registry =
        File('docs/catalog/fractal_registry.yaml').readAsStringSync();
    expect(registry, contains('  - id: $_identity'));
  });
}
