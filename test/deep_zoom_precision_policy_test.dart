import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';

void main() {
  const policy = DeepZoomPrecisionPolicy();

  group('DeepZoomPrecisionPolicy.thresholdsFor', () {
    test('exposes contiguous Mandelbrot df2 to CPU fallback boundaries', () {
      final thresholds = policy.thresholdsFor('mandelbrot');

      expect(thresholds.supportsDoubleFloat, isTrue);
      expect(thresholds.doubleFloatLowerZoom, 5e6);
      expect(thresholds.doubleFloatUpperZoom, thresholds.cpuFallbackZoom);
      expect(thresholds.shouldUseDoubleFloat(1e11), isTrue);
      expect(
        thresholds.shouldUseDoubleFloat(thresholds.cpuFallbackZoom),
        isFalse,
      );
      expect(
        thresholds.shouldUseCpuFallback(thresholds.cpuFallbackZoom),
        isTrue,
      );
    });

    test('exposes default thresholds without a double-float range', () {
      final thresholds = policy.thresholdsFor('unknown_fractal');

      expect(thresholds.cpuFallbackZoom, 1e7);
      expect(thresholds.supportsDoubleFloat, isFalse);
      expect(thresholds.shouldUseDoubleFloat(1e10), isFalse);
    });
  });

  group('DeepZoomPrecisionPolicy.decisionFor', () {
    test('exposes CPU and double-float routing from one threshold snapshot',
        () {
      final decision = policy.decisionFor(moduleId: 'mandelbrot', zoom: 1e10);

      expect(decision.moduleId, 'mandelbrot');
      expect(decision.zoom, 1e10);
      expect(decision.cpuFallbackZoom, 1e12);
      expect(decision.shouldUseDoubleFloat, isTrue);
      expect(decision.shouldUseCpuFallback, isFalse);
      expect(decision.thresholds, same(policy.thresholdsFor('mandelbrot')));
    });

    test('keeps invalid zoom samples below precision routing thresholds', () {
      for (final zoom in [double.nan, double.negativeInfinity]) {
        final decision = policy.decisionFor(
          moduleId: 'mandelbrot',
          zoom: zoom,
        );

        expect(decision.shouldUseDoubleFloat, isFalse, reason: '$zoom');
        expect(decision.shouldUseCpuFallback, isFalse, reason: '$zoom');
      }
    });
  });

  group('DeepZoomPrecisionPolicy.shouldUseCpuFallback', () {
    test('returns false for mandelbrot at zoom 1e6', () {
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 1e6),
        isFalse,
      );
    });

    test('returns true for mandelbrot at zoom 1e15', () {
      expect(
        policy.shouldUseCpuFallback(moduleId: 'mandelbrot', zoom: 1e15),
        isTrue,
      );
    });

    test('uses default threshold for unknown module', () {
      // Default threshold is 1e7; zoom just below should be false.
      expect(
        policy.shouldUseCpuFallback(moduleId: 'unknown_fractal', zoom: 9.9e6),
        isFalse,
      );
      // At or above default threshold (1e7) should be true.
      expect(
        policy.shouldUseCpuFallback(moduleId: 'unknown_fractal', zoom: 1e7),
        isTrue,
      );
    });

    test('routes Weierstrass p to CPU before float32 deep-zoom collapse', () {
      expect(
        policy.shouldUseCpuFallback(moduleId: 'weierstrass_p', zoom: 413329),
        isTrue,
      );
    });
  });

  group('DeepZoomPrecisionPolicy.shouldUseDoubleFloat', () {
    test('returns true for mandelbrot in df2 range', () {
      // df2 range: [5e6, 1e12)
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 5e6),
        isTrue,
      );
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 1e10),
        isTrue,
      );
    });

    test('returns false for non-mandelbrot modules', () {
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'julia', zoom: 1e10),
        isFalse,
      );
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'burning_ship', zoom: 1e10),
        isFalse,
      );
    });

    test('returns false below df2 lower threshold', () {
      // Below 5e6 the standard float32 shader is sufficient.
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 1e5),
        isFalse,
      );
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 4.9e6),
        isFalse,
      );
    });

    test('returns false at or above df2 upper threshold', () {
      // At 1e12 CPU fallback takes over; df2 should not be active.
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 1e12),
        isFalse,
      );
    });
  });

  group('DeepZoomPrecisionPolicy.scaledGpuIterations', () {
    test('returns base at zoom 1', () {
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: 1.0),
        equals(256),
      );
    });

    test('returns base at zoom below 1', () {
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: 0.5),
        equals(256),
      );
    });

    test('increases with zoom depth', () {
      final atZoom1 =
          policy.scaledGpuIterations(baseIterations: 256, zoom: 1.0);
      final atZoom1e6 =
          policy.scaledGpuIterations(baseIterations: 256, zoom: 1e6);
      expect(atZoom1e6, greaterThan(atZoom1));
    });

    test('clamps to gpuMaxIterations', () {
      // Very high base + very high zoom should be clamped.
      final result = policy.scaledGpuIterations(
        baseIterations: DeepZoomPrecisionPolicy.gpuMaxIterations,
        zoom: 1e30,
      );
      expect(result, equals(DeepZoomPrecisionPolicy.gpuMaxIterations));
    });

    test('clamps low base to minimum of 4', () {
      final result = policy.scaledGpuIterations(baseIterations: 1, zoom: 1.0);
      expect(result, equals(4));
    });

    test('treats non-finite zoom values as bounded inputs', () {
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: double.nan),
        equals(256),
      );
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: double.infinity),
        equals(DeepZoomPrecisionPolicy.gpuMaxIterations),
      );
      expect(
        policy.scaledGpuIterations(
          baseIterations: 256,
          zoom: double.negativeInfinity,
        ),
        equals(256),
      );
    });
  });

  group('DeepZoomHysteresisState', () {
    test('exposes replayable streak transitions', () {
      const initial = DeepZoomHysteresisState.initial();

      final first = initial.next(
        nextModuleId: 'julia',
        overThreshold: true,
        activationFrames: 2,
      );
      final second = first.next(
        nextModuleId: 'julia',
        overThreshold: true,
        activationFrames: 2,
      );
      final resetByZoomOut = second.next(
        nextModuleId: 'julia',
        overThreshold: false,
        activationFrames: 2,
      );
      final resetByModule = first.next(
        nextModuleId: 'mandelbrot',
        overThreshold: true,
        activationFrames: 2,
      );

      expect(first.moduleId, 'julia');
      expect(first.aboveThresholdCount, 1);
      expect(first.cpuActive, isFalse);
      expect(second.aboveThresholdCount, 2);
      expect(second.cpuActive, isTrue);
      expect(resetByZoomOut.aboveThresholdCount, 0);
      expect(resetByZoomOut.cpuActive, isFalse);
      expect(resetByModule.moduleId, 'mandelbrot');
      expect(resetByModule.aboveThresholdCount, 1);
      expect(resetByModule.cpuActive, isFalse);
    });
  });

  group('DeepZoomHysteresis', () {
    test('does not activate CPU until hysteresisFrames consecutive frames', () {
      final hysteresis = DeepZoomHysteresis(policy: policy);
      // mandelbrot CPU threshold is 1e12; zoom 2e12 is above it.
      const moduleId = 'mandelbrot';
      const highZoom = 2e12;
      final frames = policy.hysteresisFrames;

      // All frames before the last should still return false.
      for (var i = 0; i < frames - 1; i++) {
        expect(
          hysteresis.update(moduleId: moduleId, zoom: highZoom),
          isFalse,
          reason: 'frame $i should not activate CPU yet',
        );
      }

      // The hysteresisFrames-th frame should activate.
      expect(
        hysteresis.update(moduleId: moduleId, zoom: highZoom),
        isTrue,
      );
    });

    test('drops back to GPU immediately when zoom falls below threshold', () {
      final hysteresis = DeepZoomHysteresis(policy: policy);
      const moduleId = 'mandelbrot';
      const highZoom = 2e14;
      const lowZoom = 1.0;
      final frames = policy.hysteresisFrames;

      // Trigger CPU mode.
      for (var i = 0; i < frames; i++) {
        hysteresis.update(moduleId: moduleId, zoom: highZoom);
      }

      // A single below-threshold update drops back to GPU.
      expect(
        hysteresis.update(moduleId: moduleId, zoom: lowZoom),
        isFalse,
      );
    });

    test('does not carry above-threshold count across module changes', () {
      final hysteresis = DeepZoomHysteresis(policy: policy);

      expect(
        hysteresis.update(moduleId: 'julia', zoom: 2e9),
        isFalse,
        reason: 'first Julia deep-zoom frame should only prime hysteresis',
      );

      expect(
        hysteresis.update(moduleId: 'mandelbrot', zoom: 2e14),
        isFalse,
        reason: 'first Mandelbrot deep-zoom frame must not inherit Julia count',
      );

      expect(
        hysteresis.update(moduleId: 'mandelbrot', zoom: 2e14),
        isTrue,
        reason: 'second consecutive Mandelbrot deep-zoom frame activates CPU',
      );
    });

    test('reset clears state so hysteresis counter restarts', () {
      final hysteresis = DeepZoomHysteresis(policy: policy);
      const moduleId = 'mandelbrot';
      const highZoom = 2e14;
      final frames = policy.hysteresisFrames;

      // Build up to just before activation.
      for (var i = 0; i < frames - 1; i++) {
        hysteresis.update(moduleId: moduleId, zoom: highZoom);
      }

      hysteresis.reset();

      // After reset, the counter is zero; a single update should not activate.
      expect(
        hysteresis.update(moduleId: moduleId, zoom: highZoom),
        isFalse,
      );
    });
  });
}
