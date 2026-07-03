import 'dart:typed_data';

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('PrecisionLadderPolicy', () {
    const policy = PrecisionLadderPolicy();

    test('routes deep zoom through public ladder paths', () {
      expect(
        policy
            .decide(
              moduleId: 'mandelbrot',
              dimension: FractalDimension.twoD,
              zoom: 1e12,
            )
            .renderPath,
        PrecisionLadderRenderPath.cpu,
      );
      expect(
        policy
            .decide(
              moduleId: 'some_unknown',
              dimension: FractalDimension.twoD,
              zoom: 5e6,
            )
            .renderPath,
        PrecisionLadderRenderPath.gpuFloat,
      );
      expect(
        policy
            .decide(
              moduleId: 'some_unknown',
              dimension: FractalDimension.twoD,
              zoom: 1e7,
            )
            .renderPath,
        PrecisionLadderRenderPath.gpuFloat,
      );
      expect(
        policy
            .decide(
              moduleId: 'householder',
              dimension: FractalDimension.twoD,
              zoom: 1e7,
            )
            .renderPath,
        PrecisionLadderRenderPath.cpu,
      );
    });

    test('auto-scales GPU iterations with zoom depth', () {
      expect(policy.scaledGpuIterations(baseIterations: 120, zoom: 1.0), 120);

      final mid = policy.scaledGpuIterations(baseIterations: 120, zoom: 1e6);
      final deep = policy.scaledGpuIterations(baseIterations: 120, zoom: 1e12);

      expect(mid, greaterThan(120));
      expect(deep, greaterThan(mid));

      // Clamp behavior.
      expect(
          policy.scaledGpuIterations(baseIterations: 5000, zoom: 1e30), 2000);
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
