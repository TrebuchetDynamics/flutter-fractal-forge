import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('DeepZoomPrecisionPolicy', () {
    const policy = DeepZoomPrecisionPolicy();

    test('uses per-fractal thresholds for CPU fallback', () {
      expect(policy.thresholdFor('mandelbrot'), 1e5);
      expect(policy.thresholdFor('julia'), 5e4);
      expect(policy.thresholdFor('celtic'), 5e4);
      expect(policy.thresholdFor('buffalo'), 5e4);
    });

    test('provides default threshold for unlisted fractals', () {
      expect(policy.thresholdFor('some_unknown'), 2e5);
    });

    test('fallback toggles at threshold', () {
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 179.9),
        isFalse,
      );
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 1e5),
        isTrue,
      );
      // Unlisted fractals use default threshold (2e5)
      expect(
        policy.shouldUseCpuFallback(moduleId: 'tricorn', zoom: 10000),
        isFalse,
      );
      expect(
        policy.shouldUseCpuFallback(moduleId: 'tricorn', zoom: 5e4),
        isTrue,
      );
    });
  });

  group('CPU deep-zoom quality', () {
    test('supersampling reduces grain by at least 10%', () async {
      const width = 120;
      const height = 120;

      final base = await renderCpuFrame(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.743643887, 0.131825904),
        viewZoom: 320.0,
        iterations: 320,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: width,
        height: height,
        sampleCount: 1,
      );

      final improved = await renderCpuFrame(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.743643887, 0.131825904),
        viewZoom: 320.0,
        iterations: 320,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: width,
        height: height,
        sampleCount: 4,
      );

      final baseGrain = computeGrainScore(base.rgba, width, height);
      final improvedGrain = computeGrainScore(improved.rgba, width, height);

      expect(improvedGrain, lessThan(baseGrain * 0.90));
    });

    test('supports celtic and buffalo formulas in CPU path', () async {
      final celtic = await renderCpuFrame(
        moduleId: 'celtic',
        viewPan: Vector2(-0.45, 0.22),
        viewZoom: 90.0,
        iterations: 280,
        bailout: 4.0,
        juliaC: Vector2.zero(),
        width: 64,
        height: 64,
      );

      final buffalo = await renderCpuFrame(
        moduleId: 'buffalo',
        viewPan: Vector2(-0.35, 0.3),
        viewZoom: 90.0,
        iterations: 280,
        bailout: 4.0,
        juliaC: Vector2.zero(),
        width: 64,
        height: 64,
      );

      expect(celtic.rgba.length, 64 * 64 * 4);
      expect(buffalo.rgba.length, 64 * 64 * 4);

      bool hasVariation(Uint8List rgba) {
        final first = rgba[0];
        for (final v in rgba) {
          if (v != first) return true;
        }
        return false;
      }

      expect(hasVariation(celtic.rgba), isTrue);
      expect(hasVariation(buffalo.rgba), isTrue);
    });
  });
}
