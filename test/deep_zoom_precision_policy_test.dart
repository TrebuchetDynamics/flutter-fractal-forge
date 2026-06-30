import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = PrecisionLadderPolicy();

  group('PrecisionLadderPolicy deep-zoom routing', () {
    test('routes Mandelbrot through contiguous df2 then CPU fallback', () {
      final df2 = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1e11,
      );
      final cpu = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1e12,
      );

      expect(df2.renderPath, PrecisionLadderRenderPath.gpuDoubleFloat);
      expect(df2.usesCpuRenderer, isFalse);
      expect(cpu.renderPath, PrecisionLadderRenderPath.cpu);
      expect(policy.gpuRenderableCeilingZoom('mandelbrot'), 1e12);
    });

    test('routes default deep zoom to CPU without exposing thresholds', () {
      final below = policy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 9.9e6,
      );
      final cpu = policy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e7,
      );

      expect(below.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(cpu.renderPath, PrecisionLadderRenderPath.cpu);
      expect(policy.gpuRenderableCeilingZoom('unknown_fractal'), 1e7);
    });

    test('keeps invalid zoom samples below precision routing thresholds', () {
      for (final zoom in [double.nan, double.negativeInfinity]) {
        final decision = policy.decide(
          moduleId: 'mandelbrot',
          dimension: FractalDimension.twoD,
          zoom: zoom,
        );

        expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      }
    });
  });
}
