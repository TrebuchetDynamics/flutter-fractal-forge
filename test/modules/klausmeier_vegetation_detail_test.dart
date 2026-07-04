import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test('klausmeier vegetation issue view keeps visible band detail', () async {
    const width = 96;
    const height = 96;

    final frame = await renderCpuFrame(
      moduleId: 'klausmeier_vegetation',
      viewPan: Vector2(-3.0, -1.8033372163772583),
      viewZoom: 0.018779301494684427,
      iterations: 64,
      bailout: 4.0,
      juliaC: Vector2.zero(),
      width: width,
      height: height,
      sampleCount: 1,
    );

    final lum = List<double>.filled(width * height, 0);
    var sum = 0.0;
    var sumSq = 0.0;
    for (var i = 0; i < lum.length; i++) {
      final j = i * 4;
      final l = 0.2126 * frame.rgba[j] +
          0.7152 * frame.rgba[j + 1] +
          0.0722 * frame.rgba[j + 2];
      lum[i] = l;
      sum += l;
      sumSq += l * l;
    }

    var neighborDelta = 0.0;
    var neighborCount = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 1; x < width; x++) {
        neighborDelta += (lum[y * width + x] - lum[y * width + x - 1]).abs();
        neighborCount++;
      }
    }

    final mean = sum / lum.length;
    final stdDev = math.sqrt(sumSq / lum.length - mean * mean);
    expect(stdDev, greaterThan(18));
    expect(neighborDelta / neighborCount, greaterThan(5));
  });
}
