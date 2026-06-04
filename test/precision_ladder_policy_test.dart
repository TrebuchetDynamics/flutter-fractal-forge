import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = PrecisionLadderPolicy();

  group('PrecisionLadderPolicy', () {
    test('keeps ordinary 2D zoom on realtime GPU', () {
      final decision = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1.0,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.tier, PrecisionLadderTier.realtimeGpu);
      expect(decision.statusLabel, 'GPU');
      expect(decision.showPrecisionIndicator, isFalse);
    });

    test('routes Mandelbrot through double-float GPU before CPU', () {
      final decision = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1e10,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuDoubleFloat);
      expect(decision.tier, PrecisionLadderTier.extendedGpu);
      expect(decision.exactness, PrecisionLadderExactness.extendedGpuPreview);
      expect(decision.statusLabel, 'Deep GPU');
      expect(decision.debugRendererLabel, 'GPU-DF2');
    });

    test('routes perturbation-capable modules through extended GPU preview',
        () {
      for (final moduleId in ['julia', 'burning_ship', 'phoenix']) {
        final decision = policy.decide(
          moduleId: moduleId,
          dimension: FractalDimension.twoD,
          zoom: 1e10,
        );

        expect(
          decision.renderPath,
          PrecisionLadderRenderPath.gpuPerturbation,
          reason: moduleId,
        );
        expect(decision.tier, PrecisionLadderTier.extendedGpu);
        expect(decision.usesCpuRenderer, isFalse);
      }
    });

    test('keeps non-2D modules on GPU regardless of deep zoom threshold', () {
      final decision = policy.decide(
        moduleId: 'mandelbulb',
        dimension: FractalDimension.threeD,
        zoom: 1e40,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.usesCpuRenderer, isFalse);
    });

    test('can expose CPU fallback pending before hysteresis activates', () {
      final decision = policy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
        cpuFallbackActive: false,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.cpuFallbackPending, isTrue);
      expect(decision.statusLabel, 'Precision pending');
      expect(decision.showPrecisionIndicator, isTrue);
    });

    test('commits non-extended deep zoom to CPU when fallback is active', () {
      final decision = policy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.cpu);
      expect(decision.tier, PrecisionLadderTier.precisionRefine);
      expect(decision.exactness, PrecisionLadderExactness.cpuPrecision);
      expect(decision.statusLabel, 'Precision');
    });
  });

  group('PrecisionLadderHysteresis', () {
    test('delays CPU path but does not delay extended GPU preview', () {
      final hysteresis = PrecisionLadderHysteresis(policy: policy);

      final perturb = hysteresis.update(
        moduleId: 'julia',
        dimension: FractalDimension.twoD,
        zoom: 1e10,
      );

      expect(perturb.renderPath, PrecisionLadderRenderPath.gpuPerturbation);
      expect(hysteresis.state.aboveThresholdCount, 0);

      final firstCpu = hysteresis.update(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );
      final secondCpu = hysteresis.update(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      expect(firstCpu.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(firstCpu.cpuFallbackPending, isTrue);
      expect(secondCpu.renderPath, PrecisionLadderRenderPath.cpu);
    });

    test('resets CPU activation when module changes', () {
      final hysteresis = PrecisionLadderHysteresis(policy: policy);

      hysteresis.update(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );
      hysteresis.update(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      final changed = hysteresis.update(
        moduleId: 'another_unknown',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      expect(changed.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(changed.cpuFallbackPending, isTrue);
      expect(hysteresis.state.aboveThresholdCount, 1);
    });
  });
}
