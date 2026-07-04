import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test('3d_fractal default thumbnail uses detailed normal-map preset',
      () async {
    final module = ModuleRegistry().byId('3d_fractal');
    final preset = module.defaultPreset;

    expect(preset.params['colorScheme'], 59);
    expect(hasNativeCpuFormula('3d_fractal'), isTrue);

    final frame = await renderCpuFrame(
      moduleId: module.id,
      viewPan: preset.view.pan,
      viewZoom: preset.view.zoom,
      iterations: (preset.params['iterations'] as num).round(),
      bailout: (preset.params['bailout'] as num).toDouble(),
      juliaC: Vector2(-0.8, 0.156),
      width: 96,
      height: 96,
      sampleCount: 1,
    );

    final metrics = _metrics(frame.rgba);
    expect(metrics.uniqueRgb, greaterThan(64));
    expect(metrics.luminanceStdDev, greaterThan(8));

    final iterations = await renderCpuIterationBuffer(
      moduleId: module.id,
      viewPan: preset.view.pan,
      viewZoom: preset.view.zoom,
      iterations: (preset.params['iterations'] as num).round(),
      bailout: (preset.params['bailout'] as num).toDouble(),
      juliaC: Vector2(-0.8, 0.156),
      width: 96,
      height: 96,
    );
    expect(iterations, isNotNull);
    expect(iterations!.toSet().length, greaterThan(8));
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
