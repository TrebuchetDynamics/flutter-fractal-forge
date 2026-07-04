import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test('eisenstein reported initial view shows lattice structure', () async {
    final module = ModuleRegistry().byId('eisenstein');

    expect(module.id, 'eisenstein');

    final frame = await renderCpuFrame(
      moduleId: 'eisenstein',
      viewPan: Vector2.zero(),
      viewZoom: 1.0,
      iterations: 170,
      bailout: 4.0,
      juliaC: Vector2(-0.8, 0.156),
      width: 96,
      height: 96,
      sampleCount: 1,
    );

    final metrics = _metrics(frame.rgba);
    expect(metrics.nonBlackRatio, greaterThan(0.10));
    expect(metrics.uniqueRgb, greaterThan(24));
    expect(metrics.luminanceStdDev, greaterThan(4));
  });
}

({int uniqueRgb, double luminanceStdDev, double nonBlackRatio}) _metrics(
    List<int> rgba) {
  final colors = <int>{};
  var sum = 0.0;
  var sum2 = 0.0;
  var count = 0;
  var nonBlack = 0;

  for (var i = 0; i < rgba.length; i += 4) {
    final r = rgba[i];
    final g = rgba[i + 1];
    final b = rgba[i + 2];
    colors.add((r << 16) | (g << 8) | b);
    if (r > 8 || g > 8 || b > 8) nonBlack++;
    final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    sum += lum;
    sum2 += lum * lum;
    count++;
  }

  final mean = sum / count;
  return (
    uniqueRgb: colors.length,
    luminanceStdDev: math.sqrt(math.max(0.0, sum2 / count - mean * mean)),
    nonBlackRatio: nonBlack / count,
  );
}
