import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const expected = {
    'mandelbrot_log_polar_tessellation': (formula: 0.0, motif: 0.0),
    'julia_log_polar_tessellation': (formula: 1.0, motif: 1.0),
    'burning_ship_log_polar_tessellation': (formula: 2.0, motif: 2.0),
    'tricorn_log_polar_tessellation': (formula: 3.0, motif: 3.0),
  };

  test('catalog exposes four distinct log-polar tessellation modules', () {
    final configs = {
      for (final config in escapeTimeCatalog)
        if (expected.containsKey(config.id)) config.id: config,
    };

    expect(configs.keys, unorderedEquals(expected.keys));
    for (final entry in expected.entries) {
      final config = configs[entry.key]!;
      expect(config.category, 'Image Tessellations');
      expect(config.animationCapability, FractalAnimationCapability.static);
      expect(
        config.shaderAsset,
        'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
      );
      expect(config.defaultBailout, inInclusiveRange(2, 8));
      final defaults = {
        for (final param in config.extraParams) param.id: param.defaultValue,
      };
      expect(defaults['formula'], entry.value.formula);
      expect(defaults['motif'], entry.value.motif);
      expect(
          defaults.keys,
          containsAll(const {
            'juliaReal',
            'juliaImag',
            'angularRepeats',
            'radialRepeats',
            'phaseOffset',
          }));
    }
  });

  test('shader implements static, sampler-free, stable log-polar mapping', () {
    final source = File(
      'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
    ).readAsStringSync();

    expect(source, contains('atan(lastBounded.y, lastBounded.x) / TAU'));
    expect(source, contains('0.5 * log(boundedMetric)'));
    expect(source, contains('if (!(metric <= bailoutSquared))'));
    expect(source, contains('proceduralMotif'));
    expect(source, isNot(contains('sampler2D')));
    expect(source, isNot(contains('texture(')));
    expect(source, isNot(contains('uTime *')));
  });

  test('registered shader asset is present in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec,
      contains(
        'shaders/escape_time_family/textured/'
        'log_polar_tessellation_gpu.frag',
      ),
    );
  });

  test('shader compiles and every curated default has pixel structure',
      () async {
    const size = 64;
    for (final id in expected.keys) {
      final config = escapeTimeCatalog.singleWhere((entry) => entry.id == id);
      final program = await ui.FragmentProgram.fromAsset(config.shaderAsset);
      final extras = config.extraParams
          .map((param) => (param.defaultValue as num).toDouble());
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
      expect(colors.length, greaterThan(24), reason: '$id is nearly uniform');
      expect(visiblePixels, greaterThan(size * size ~/ 50),
          reason: '$id is effectively all black');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('default output is time invariant', () async {
    const size = 48;
    final config = escapeTimeCatalog.singleWhere(
      (entry) => entry.id == 'mandelbrot_log_polar_tessellation',
    );
    final program = await ui.FragmentProgram.fromAsset(config.shaderAsset);
    final extras = config.extraParams
        .map((param) => (param.defaultValue as num).toDouble())
        .toList();

    Future<List<int>> renderAt(double time) async => renderTestShaderFrame(
          program: program,
          shaderAsset: config.shaderAsset,
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
            ...extras,
          ],
        );

    expect(await renderAt(0), await renderAt(9.5));
  });

  test('research package records source coverage and licensing boundary', () {
    const base = 'research/log-polar-fractal-tessellation';
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
    expect((provenance['queries'] as List<dynamic>).length,
        greaterThanOrEqualTo(20));
    expect(
      (provenance['search_stats'] as Map<String, dynamic>)['total_unique_dois'],
      greaterThan(0),
    );
    expect(
      (provenance['primary_lead'] as Map<String, dynamic>)['license'],
      'unknown',
    );
    expect(provenance['outputs'], contains('report.md'));
    expect(provenance['errors'], isNotEmpty);
  });
}
