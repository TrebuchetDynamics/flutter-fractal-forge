import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('DeepZoomPrecisionPolicy', () {
    const policy = DeepZoomPrecisionPolicy();

    test('uses per-fractal thresholds for CPU fallback', () {
      // Mandelbrot: df2 shader covers [5e6, 1e14), CPU above 1e14.
      expect(policy.thresholdFor('mandelbrot'), 1e14);
      // Perturbation fractals: perturb shader covers [5e6, 1e30),
      // so CPU fallback only triggers at 1e30.
      expect(policy.thresholdFor('julia'), 1e30);
      expect(policy.thresholdFor('celtic'), 1e30);
      expect(policy.thresholdFor('buffalo'), 1e30);
      expect(policy.thresholdFor('burning_ship'), 1e30);
      expect(policy.thresholdFor('tricorn'), 1e30);
      expect(policy.thresholdFor('phoenix'), 1e30);
    });

    test('provides default threshold for unlisted fractals', () {
      // Raised from 2e5 to 1e8: simple fractals tolerate higher GPU zoom.
      expect(policy.thresholdFor('some_unknown'), 1e8);
    });

    test('fallback toggles at threshold', () {
      // GPU stays active for Mandelbrot until df2 upper bound.
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 1e7),
        isFalse,
      );
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 1e14),
        isTrue,
      );
      // Unlisted fractals use default threshold (1e8)
      // 'some_unknown' is not in the per-module map, so it gets _defaultThreshold.
      expect(
        policy.shouldUseCpuFallback(moduleId: 'some_unknown', zoom: 5e7),
        isFalse,
      );
      expect(
        policy.shouldUseCpuFallback(moduleId: 'some_unknown', zoom: 1e8),
        isTrue,
      );
    });

    test('auto-scales GPU iterations with zoom depth', () {
      expect(policy.scaledGpuIterations(baseIterations: 120, zoom: 1.0), 120);

      final mid = policy.scaledGpuIterations(baseIterations: 120, zoom: 1e6);
      final deep = policy.scaledGpuIterations(baseIterations: 120, zoom: 1e12);

      expect(mid, greaterThan(120));
      expect(deep, greaterThan(mid));
      expect(deep, lessThanOrEqualTo(DeepZoomPrecisionPolicy.gpuMaxIterations));

      // Clamp behavior.
      expect(
        policy.scaledGpuIterations(baseIterations: 5000, zoom: 1e30),
        DeepZoomPrecisionPolicy.gpuMaxIterations,
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
