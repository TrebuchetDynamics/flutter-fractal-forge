import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';

void main() {
  const policy = DeepZoomPrecisionPolicy();

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
  });

  group('DeepZoomPrecisionPolicy.shouldUseDoubleFloat', () {
    test('returns true for mandelbrot in df2 range', () {
      // df2 range: [5e6, 1e14)
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
      // At 1e14 CPU fallback takes over; df2 should not be active.
      expect(
        policy.shouldUseDoubleFloat(moduleId: 'mandelbrot', zoom: 1e14),
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
  });

  group('DeepZoomHysteresis', () {
    test('does not activate CPU until hysteresisFrames consecutive frames', () {
      final hysteresis = DeepZoomHysteresis(policy: policy);
      // mandelbrot CPU threshold is 1e14; zoom 2e14 is above it.
      const moduleId = 'mandelbrot';
      const highZoom = 2e14;
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
