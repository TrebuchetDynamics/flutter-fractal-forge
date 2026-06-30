import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/policy/deep_zoom_precision_policy.dart';

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
}
