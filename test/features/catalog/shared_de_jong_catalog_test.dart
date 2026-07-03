import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_de_jong_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'shared_coefficient_catalog_expectations.dart';

void main() {
  test('registers reviewed Peter de Jong coefficient-map identities', () {
    expectSharedCoefficientCatalog(
      entries: sharedDeJongCatalogEntries,
      expectedLength: 22,
      shaderAsset: 'shaders/strange_attractors/peter_de_jong_gpu.frag',
    );
  });

  test('keeps generic Peter de Jong configured with coefficient params', () {
    final module = ModuleRegistry().byId('peter_de_jong');

    expect(module.defaultPreset.params['a'], 1.4);
    expect(module.defaultPreset.params['b'], -2.3);
    expect(module.defaultPreset.params['c'], 2.4);
    expect(module.defaultPreset.params['d'], -2.1);
  });

  test('bounds reported de Jong Crescent bad random coefficients', () {
    final module = ModuleRegistry().byId('f0373_de_jong_crescent');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(paramsById['a']!.min, closeTo(-1.84, 1e-9));
    expect(paramsById['a']!.max, closeTo(-0.64, 1e-9));
    expect(1.51, greaterThan(paramsById['a']!.max));
    expect(paramsById['b']!.min, closeTo(-1.85, 1e-9));
    expect(-5.54, lessThan(paramsById['b']!.min));
    expect(paramsById['d']!.max, closeTo(-0.51, 1e-9));
  });

  test('de Jong Double thumbnail fallback has visible detail', () async {
    final module = ModuleRegistry().byId('f0381_de_jong_double');
    final preset = module.defaultPreset;

    expect(hasNativeCpuFormula(module.id), isTrue);

    final frame = await renderCpuFrame(
      moduleId: module.id,
      viewPan: Vector2(0.001297623268328607, -0.12550707161426544),
      viewZoom: 0.1883412127063718,
      iterations: (preset.params['iterations'] as num).round(),
      bailout: (preset.params['bailout'] as num).toDouble(),
      juliaC: Vector2(-0.8, 0.156),
      width: 96,
      height: 96,
      sampleCount: 1,
    );

    final metrics = _metrics(frame.rgba);
    expect(metrics.uniqueRgb, greaterThan(256));
    expect(metrics.luminanceStdDev, greaterThan(20));
  });
}

({int uniqueRgb, double luminanceStdDev}) _metrics(List<int> rgba) {
  final colors = <int>{};
  var sum = 0.0;
  var sum2 = 0.0;
  var count = 0;

  for (var i = 0; i < rgba.length; i += 4) {
    final r = rgba[i];
    final g = rgba[i + 1];
    final b = rgba[i + 2];
    colors.add((r << 16) | (g << 8) | b);
    final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    sum += lum;
    sum2 += lum * lum;
    count++;
  }

  final mean = sum / count;
  return (
    uniqueRgb: colors.length,
    luminanceStdDev: math.sqrt(math.max(0.0, sum2 / count - mean * mean)),
  );
}
