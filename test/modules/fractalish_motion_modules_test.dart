import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shaderAsset =
      'shaders/escape_time_family/experimental_named/procedural_motion/fractalish_motion_gpu.frag';
  const expectedMotifs = {
    'chromatic_arachnid_lattice': 0.0,
    'astral_sigil_loom': 1.0,
    'recursive_arcana_frames': 2.0,
    'tempest_aurora_tides': 3.0,
    'fourfold_motif_metamorphosis': 4.0,
  };
  const extraIds = [
    'motif',
    'symmetry',
    'detail',
    'warp',
    'motion',
    'phase',
    'paletteShift',
  ];

  test('catalog exposes five original fractalish motion modules', () {
    final configs = {
      for (final config in escapeTimeCatalog)
        if (expectedMotifs.containsKey(config.id)) config.id: config,
    };

    expect(configs.keys, unorderedEquals(expectedMotifs.keys));
    for (final entry in expectedMotifs.entries) {
      final config = configs[entry.key]!;
      expect(config.category, 'Fractalish Motion');
      expect(
        config.animationCapability,
        FractalAnimationCapability.timeDriven,
      );
      expect(config.shaderAsset, shaderAsset);
      expect(config.extraParams.map((param) => param.id), extraIds);
      expect(config.maxIterations, 54);
      final motif = config.extraParams.first;
      expect(motif.defaultValue, entry.value);
      expect(motif.min, entry.value);
      expect(motif.max, entry.value);
    }
  });

  test('shared shader is procedural, sampler-free, and smoothly keyframed', () {
    final source = File(shaderAsset).readAsStringSync();

    expect(source, contains('spiderWebColor'));
    expect(source, contains('arcaneSigilColor'));
    expect(source, contains('recursiveCardsColor'));
    expect(source, contains('auroraTempestColor'));
    expect(source, contains('blend * blend * (3.0 - 2.0 * blend)'));
    expect(source, contains('orbitTexture'));
    expect(source, isNot(contains('sampler2D')));
    expect(source, isNot(contains('texture(')));
  });

  test('registered shader asset is present in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains(shaderAsset));
  });

  test('shader compiles and every curated default has pixel structure',
      () async {
    const size = 64;
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);

    for (final id in expectedMotifs.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final extras = config.extraParams
          .map((param) => (param.defaultValue as num).toDouble());
      final pixels = await renderTestShaderFrame(
        program: program,
        shaderAsset: shaderAsset,
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
      var visiblePixels = 0;
      for (var offset = 0; offset < pixels.length; offset += 4) {
        colors.add(
          (pixels[offset] << 16) |
              (pixels[offset + 1] << 8) |
              pixels[offset + 2],
        );
        if (pixels[offset] > 8 ||
            pixels[offset + 1] > 8 ||
            pixels[offset + 2] > 8) {
          visiblePixels++;
        }
      }
      expect(colors.length, greaterThan(32), reason: '$id is nearly uniform');
      expect(
        visiblePixels,
        greaterThan(size * size ~/ 40),
        reason: '$id is effectively all black',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('production-clock animation advances and zero motion freezes', () async {
    const size = 48;
    const oneProductionSecond = 1000 / 86400;
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);

    for (final id in expectedMotifs.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final extras = config.extraParams
          .map((param) => (param.defaultValue as num).toDouble())
          .toList();

      Future<List<int>> renderAt(double time, List<double> values) =>
          renderTestShaderFrame(
            program: program,
            shaderAsset: shaderAsset,
            width: size,
            height: size,
            uniforms: [
              time,
              size.toDouble(),
              size.toDouble(),
              config.defaultCenterX ?? 0,
              config.defaultCenterY ?? 0,
              config.defaultZoom,
              config.defaultIterations,
              config.defaultBailout,
              config.defaultColorScheme.toDouble(),
              0,
              ...values,
            ],
          );

      final first = await renderAt(0, extras);
      expect(await renderAt(0, extras), first,
          reason: '$id must replay deterministically');
      expect(await renderAt(oneProductionSecond, extras), isNot(first),
          reason: '$id must visibly advance after one production second');

      final frozen = [...extras]..[4] = 0;
      expect(await renderAt(100, frozen), await renderAt(0, frozen),
          reason: '$id must stop when Motion Rate is zero');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('symmetry and warp controls affect every motif identity', () async {
    const size = 40;
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);

    for (final id in expectedMotifs.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final extras = config.extraParams
          .map((param) => (param.defaultValue as num).toDouble())
          .toList();

      Future<List<int>> render(List<double> values) => renderTestShaderFrame(
            program: program,
            shaderAsset: shaderAsset,
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
              ...values,
            ],
          );

      final baseline = await render(extras);
      final changedSymmetry = [...extras]..[1] += 1;
      final changedWarp = [...extras]..[3] += 0.4;
      expect(await render(changedSymmetry), isNot(baseline),
          reason: '$id symmetry is inert');
      expect(await render(changedWarp), isNot(baseline),
          reason: '$id warp is inert');
      if (id == 'chromatic_arachnid_lattice') {
        final threefold = [...extras]..[1] = 3;
        final fivefold = [...extras]..[1] = 5;
        expect(await render(threefold), isNot(await render(fivefold)),
            reason: '$id lower symmetry range is inert');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('metamorphosis phase wraps one complete four-motif cycle', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);
    final config = escapeTimeCatalog.singleWhere(
      (entry) => entry.id == 'fourfold_motif_metamorphosis',
    );
    final extras = config.extraParams
        .map((param) => (param.defaultValue as num).toDouble())
        .toList();

    Future<List<int>> renderPhase(double phase) {
      final phasedExtras = [...extras]..[5] = phase;
      return renderTestShaderFrame(
        program: program,
        shaderAsset: shaderAsset,
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
          ...phasedExtras,
        ],
      );
    }

    final start = await renderPhase(0);
    expect(await renderPhase(1), start);
    expect(await renderPhase(0.25), isNot(start));
    expect(await renderPhase(0.5), isNot(start));
    expect(await renderPhase(0.75), isNot(start));

    final beforeBoundary = await renderPhase(0.25 - 0.0001);
    final afterBoundary = await renderPhase(0.25 + 0.0001);
    var totalDifference = 0;
    for (var offset = 0; offset < beforeBoundary.length; offset += 4) {
      totalDifference += (beforeBoundary[offset] - afterBoundary[offset]).abs();
      totalDifference +=
          (beforeBoundary[offset + 1] - afterBoundary[offset + 1]).abs();
      totalDifference +=
          (beforeBoundary[offset + 2] - afterBoundary[offset + 2]).abs();
    }
    final meanDifference = totalDifference / (size * size * 3);
    expect(meanDifference, lessThan(1.0));
  });

  test('every transparent motif has clear premultiplied background', () async {
    const size = 48;
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);

    for (final id in expectedMotifs.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final pixels = await renderTestShaderFrame(
        program: program,
        shaderAsset: shaderAsset,
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
          1,
          ...config.extraParams.map(
            (param) => (param.defaultValue as num).toDouble(),
          ),
        ],
      );

      var clearPixels = 0;
      var visiblePixels = 0;
      for (var offset = 0; offset < pixels.length; offset += 4) {
        final alpha = pixels[offset + 3];
        if (alpha == 0) clearPixels++;
        if (alpha > 32) visiblePixels++;
        expect(pixels[offset], lessThanOrEqualTo(alpha));
        expect(pixels[offset + 1], lessThanOrEqualTo(alpha));
        expect(pixels[offset + 2], lessThanOrEqualTo(alpha));
      }
      expect(clearPixels, greaterThan(size * size ~/ 20), reason: id);
      expect(visiblePixels, greaterThan(size * size ~/ 20), reason: id);
    }
  });

  test('research package records comprehensive coverage and asset boundary',
      () {
    const base = 'research/deforum-fractalish-motion';
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
    expect(
      (provenance['queries'] as List<dynamic>).length,
      greaterThanOrEqualTo(20),
    );
    expect(
      (provenance['search_stats'] as Map<String, dynamic>)['total_unique_dois'],
      greaterThan(0),
    );
    expect(provenance['asset_policy'], 'original-procedural-only');
    expect(provenance['errors'], isNotEmpty);
  });
}
