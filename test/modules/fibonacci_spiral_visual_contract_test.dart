import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_viewport_mapping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  test(
      'fibonacci spiral stays visible as a golden logarithmic spiral when zoomed',
      () async {
    final width = 96;
    final height = 96;
    final pan = Vector2(0.00023851940932217985, 0.00033027754398062825);
    final zoom = 358.884281186916;

    final frame = await renderCpuFrame(
      moduleId: 'fibonacci_spiral',
      viewPan: pan,
      viewZoom: zoom,
      iterations: 500,
      bailout: 4.0,
      juliaC: Vector2.zero(),
      width: width,
      height: height,
      sampleCount: 1,
    );

    final viewport = CpuViewportMapping(
        viewPan: pan, viewZoom: zoom, width: width, height: height);
    var onSpiral = 0.0;
    var offSpiral = 0.0;
    var onCount = 0;
    var offCount = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final nx = viewport.normalizedSampleOffset(
            pixel: x, extent: width, sampleOffset: 0.5);
        final ny = viewport.normalizedSampleOffset(
            pixel: y, extent: height, sampleOffset: 0.5);
        final p = viewport.coordinate(nx: nx, ny: ny);
        final d = _goldenSpiralBand(p.$1, p.$2);
        final i = (y * width + x) * 4;
        final lum = 0.2126 * frame.rgba[i] +
            0.7152 * frame.rgba[i + 1] +
            0.0722 * frame.rgba[i + 2];
        if (d < 0.025) {
          onSpiral += lum;
          onCount++;
        } else if (d > 0.09 && d < 0.16) {
          offSpiral += lum;
          offCount++;
        }
      }
    }

    expect(onCount, greaterThan(16));
    expect(offCount, greaterThan(16));
    expect(onSpiral / onCount, greaterThan((offSpiral / offCount) * 1.25));
  });
}

double _goldenSpiralBand(double x, double y) {
  const logPhi = 0.48121182505960347;
  const pitch = logPhi / (math.pi * 0.5);
  const fullTurn = pitch * math.pi * 2.0;
  final r = math.sqrt(x * x + y * y) + 1e-9;
  final phase = (math.log(r) - pitch * math.atan2(y, x)) / fullTurn;
  return ((phase + 0.5) - (phase + 0.5).floor() - 0.5).abs() * fullTurn;
}
