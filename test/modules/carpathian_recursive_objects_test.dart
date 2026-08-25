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
    'shaders/3d_and_hypercomplex/raymarched_volumes/carpathian_recursive_objects_gpu.frag';
const _ids = <String>[
  'ternary_cayley_lumen',
  'gyroid_echo_reliquary',
  'mobius_echo_nest',
  'fibonacci_cone_bloom',
  'chebyshev_nodal_lantern',
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

int _differingAlphaPixels(Uint8List a, Uint8List b) {
  var count = 0;
  for (var offset = 3; offset < a.length; offset += 4) {
    if ((a[offset] - b[offset]).abs() > 8) count++;
  }
  return count;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog exposes five fixed recursive-object identities', () {
    final configs = raymarched3DCatalog
        .where((config) => _ids.contains(config.id))
        .toList(growable: false);
    final registry = ModuleRegistry();

    expect(configs.map((config) => config.id), _ids);
    expect(
      configs.map((config) => config.defaultFractalType),
      orderedEquals([0, 1, 2, 3, 4]),
    );
    for (final config in configs) {
      final module = registry.byId(config.id);
      expect(config.shaderAsset, _shaderAsset, reason: config.id);
      expect(config.maxFractalType, 0, reason: '${config.id} selector exposed');
      expect(module.dimension, FractalDimension.threeD, reason: config.id);
      expect(
        module.animationCapability,
        FractalAnimationCapability.timeDriven,
        reason: config.id,
      );
      expect(
        module.parameters.map((parameter) => parameter.id),
        isNot(contains('fractalType')),
        reason: '${config.id} identity must not be user-switchable',
      );
      expect(config.minPower, lessThan(config.maxPower), reason: config.id);
      expect(config.minIterations, lessThan(config.maxIterations),
          reason: config.id);
    }
  });

  test('shared shader is analytic, sampler-free, and construction-complete',
      () {
    final source = File(_shaderAsset).readAsStringSync();

    expect(RegExp(r'uniform\s+sampler').hasMatch(source), isFalse);
    expect(source, isNot(contains('get_fft')));
    expect(source, contains('ternaryCayleyDistance'));
    expect(source, contains('gyroidReliquaryDistance'));
    expect(source, contains('mobiusEchoDistance'));
    expect(source, contains('fibonacciConeDistance'));
    expect(source, contains('chebyshevLanternDistance'));
    expect(source, contains('sphereInterval'));
    expect(source, contains('emission +='));
  });

  test('registered shader asset is present in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- $_shaderAsset'));
  });

  test('every default compiles into an isolated structured object', () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final defaults = <String, Uint8List>{};

    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      final bytes = await _render(program, config, size: size);
      defaults[id] = bytes;
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
      expect(visible, greaterThan(size * size ~/ 100), reason: id);
      expect(visible, lessThan(size * size * 4 ~/ 5), reason: id);
      expect(black, greaterThan(size * size ~/ 8), reason: id);
      expect(colors.length, greaterThan(32), reason: id);
    }

    for (var a = 0; a < _ids.length; a++) {
      for (var b = a + 1; b < _ids.length; b++) {
        expect(
          _differingPixels(defaults[_ids[a]]!, defaults[_ids[b]]!),
          greaterThan(size * size ~/ 10),
          reason: '${_ids[a]} and ${_ids[b]} are visually interchangeable',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('geometry remains distinct under one common presentation', () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    final masks = <String, Uint8List>{};
    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      masks[id] = await _render(
        program,
        config,
        size: size,
        zoom: 1,
        rotationX: 0,
        rotationY: 0,
        rotationZ: 0,
        colorScheme: 0,
        transparent: 1,
      );
    }
    for (var a = 0; a < _ids.length; a++) {
      for (var b = a + 1; b < _ids.length; b++) {
        expect(
          _differingAlphaPixels(masks[_ids[a]]!, masks[_ids[b]]!),
          greaterThan(size * size ~/ 20),
          reason: '${_ids[a]} and ${_ids[b]} share a common-view silhouette',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('maximum accepted zoom keeps finite visible output', () async {
    const size = 32;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      final bytes = await _render(program, config, size: size, zoom: 1e12);
      var colored = 0;
      for (var offset = 0; offset < bytes.length; offset += 4) {
        if (bytes[offset] > 0 ||
            bytes[offset + 1] > 0 ||
            bytes[offset + 2] > 0) {
          colored++;
        }
      }
      expect(colored, greaterThan(0), reason: '$id collapsed at maximum zoom');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('production-clock motion visibly advances every object', () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      final first = await _render(program, config, size: size);
      final second = await _render(
        program,
        config,
        size: size,
        time: _productionSecond,
      );
      expect(
        _differingPixels(first, second),
        greaterThan(size * size ~/ 100),
        reason: '$id does not visibly advance after one production second',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('all exposed rendering controls remain active for every identity',
      () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      final baseline = await _render(program, config, size: size);
      final variants = <String, Future<Uint8List>>{
        'power minimum': _render(
          program,
          config,
          size: size,
          power: config.minPower,
        ),
        'power maximum': _render(
          program,
          config,
          size: size,
          power: config.maxPower,
        ),
        'iteration minimum': _render(
          program,
          config,
          size: size,
          iterations: config.minIterations,
        ),
        'iteration maximum': _render(
          program,
          config,
          size: size,
          iterations: config.maxIterations,
        ),
        'step budget': _render(program, config, size: size, steps: 20),
        'bailout': _render(program, config, size: size, bailout: 1),
        'palette': _render(
          program,
          config,
          size: size,
          colorScheme: ((config.defaultColorScheme + 1) % 4).toDouble(),
        ),
        'rotation': _render(
          program,
          config,
          size: size,
          rotationX: config.defaultRotationX + 0.55,
        ),
      };
      for (final entry in variants.entries) {
        final changed = await entry.value;
        expect(
          _differingPixels(baseline, changed),
          greaterThan(size * size ~/ 250),
          reason: '$id ${entry.key} is inert',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 4)));

  test('transparent misses stay clear and premultiplied', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(_shaderAsset);
    for (final id in _ids) {
      final config = raymarched3DCatalog.singleWhere((entry) => entry.id == id);
      final bytes = await _render(
        program,
        config,
        size: size,
        transparent: 1,
      );
      var clear = 0;
      var visible = 0;
      for (var offset = 0; offset < bytes.length; offset += 4) {
        final alpha = bytes[offset + 3];
        if (alpha == 0) clear++;
        if (alpha > 96) visible++;
        expect(bytes[offset], lessThanOrEqualTo(alpha), reason: '$id red');
        expect(bytes[offset + 1], lessThanOrEqualTo(alpha),
            reason: '$id green');
        expect(bytes[offset + 2], lessThanOrEqualTo(alpha), reason: '$id blue');
      }
      expect(clear, greaterThan(size * size ~/ 8), reason: id);
      expect(visible, greaterThan(size * size ~/ 100), reason: id);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('research package records source coverage and asset boundaries', () {
    const base = 'research/milkdrop-carpathian-fractals';
    for (final name in const [
      'queries.txt',
      'results-deduped.jsonl',
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
    expect(provenance['asset_policy'], 'observation-only-original-code');
    expect(provenance['reference_renderer'], 'MilkDrop3');
    expect(
      (provenance['search_stats'] as Map<String, dynamic>)['total_unique_dois'],
      greaterThan(0),
    );
    expect(provenance['assets_imported'], isFalse);
    final corpusPolicy = provenance['corpus_policy'] as Map<String, dynamic>;
    expect(corpusPolicy['abstracts_included'], isFalse);
    expect(corpusPolicy['raw_api_payloads_included'], isFalse);
    expect(
      File('$base/results-deduped.jsonl').readAsStringSync(),
      isNot(contains('"Abstract"')),
    );
    expect(Directory('$base/raw').existsSync(), isFalse);

    final registry =
        File('docs/catalog/fractal_registry.yaml').readAsStringSync();
    for (final id in _ids) {
      expect(registry, contains('  - id: $id'), reason: '$id registry entry');
    }
  });
}
