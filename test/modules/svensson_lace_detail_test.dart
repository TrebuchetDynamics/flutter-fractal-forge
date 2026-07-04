import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test('Svensson Lace keeps visible fine detail at the reported view',
      () async {
    final frame = await renderCpuFrame(
      moduleId: 'f1044_svensson_lace',
      viewPan: Vector2(-0.09854253381490707, -0.04662623628973961),
      viewZoom: 0.5732117983131407,
      iterations: 360,
      bailout: 24.0,
      juliaC: Vector2.zero(),
      width: 96,
      height: 96,
      sampleCount: 1,
    );

    final metrics = _metrics(frame.rgba, frame.width, frame.height);
    expect(metrics.uniqueRgb, greaterThan(700));
    expect(metrics.edgeEnergy, greaterThan(8.0));
  });
}

({int uniqueRgb, double edgeEnergy}) _metrics(
    List<int> rgba, int width, int height) {
  final colors = <int>{};
  final lum = List<double>.filled(width * height, 0);
  for (var i = 0; i < width * height; i++) {
    final j = i * 4;
    final r = rgba[j];
    final g = rgba[j + 1];
    final b = rgba[j + 2];
    colors.add((r << 16) | (g << 8) | b);
    lum[i] = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  var edge = 0.0;
  var count = 0;
  for (var y = 1; y < height; y++) {
    for (var x = 1; x < width; x++) {
      final i = y * width + x;
      edge += (lum[i] - lum[i - 1]).abs() + (lum[i] - lum[i - width]).abs();
      count += 2;
    }
  }
  return (uniqueRgb: colors.length, edgeEnergy: edge / math.max(1, count));
}
