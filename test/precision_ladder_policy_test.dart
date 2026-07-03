import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = PrecisionLadderPolicy();

  group('PrecisionLadderPolicy.gpuRenderableCeilingZoom', () {
    test('uses the perturbation ceiling for perturbation-capable modules', () {
      // Perturbation extends the GPU range well past the stale float32
      // CPU-fallback threshold (1e9), so the ceiling must reflect that.
      expect(policy.gpuRenderableCeilingZoom('julia'), greaterThan(1e12));
      expect(
          policy.gpuRenderableCeilingZoom('burning_ship'), greaterThan(1e12));
    });

    test('uses the df2 / float32 threshold for non-perturbable modules', () {
      // mandelbrot keeps its df2-extended CPU-fallback threshold (1e12).
      expect(policy.gpuRenderableCeilingZoom('mandelbrot'), 1e12);
      // Unlisted modules keep the conservative GPU exploration cap (1e7), but
      // are not labeled CPU Precision without a native CPU formula.
      expect(policy.gpuRenderableCeilingZoom('some_unknown_module'), 1e7);
    });
  });

  group('PrecisionLadderPolicy.scaledGpuIterations', () {
    test('exposes realtime GPU iteration scaling through the ladder seam', () {
      expect(policy.scaledGpuIterations(baseIterations: 256, zoom: 1), 256);
      expect(policy.scaledGpuIterations(baseIterations: 256, zoom: 0.5), 256);
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: 1e6),
        greaterThan(256),
      );
      expect(policy.scaledGpuIterations(baseIterations: 1, zoom: 1), 4);
      expect(
        policy.scaledGpuIterations(baseIterations: 5000, zoom: 1e30),
        2000,
      );
      expect(
        policy.scaledGpuIterations(baseIterations: 256, zoom: double.nan),
        256,
      );
      expect(
        policy.scaledGpuIterations(
          baseIterations: 256,
          zoom: double.infinity,
        ),
        2000,
      );
      expect(
        policy.scaledGpuIterations(
          baseIterations: 256,
          zoom: double.negativeInfinity,
        ),
        256,
      );
    });
  });

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
      final low = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 4.9e6,
      );
      final df2 = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1e10,
      );
      final cpu = policy.decide(
        moduleId: 'mandelbrot',
        dimension: FractalDimension.twoD,
        zoom: 1e12,
      );

      expect(low.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(df2.renderPath, PrecisionLadderRenderPath.gpuDoubleFloat);
      expect(df2.tier, PrecisionLadderTier.extendedGpu);
      expect(df2.exactness, PrecisionLadderExactness.extendedGpuPreview);
      expect(df2.statusLabel, 'Deep GPU preview');
      expect(df2.debugRendererLabel, 'GPU-DF2');
      expect(cpu.renderPath, PrecisionLadderRenderPath.cpu);
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
        expect(decision.exactness, PrecisionLadderExactness.extendedGpuPreview);
        expect(decision.statusLabel, 'Deep GPU preview');
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
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
        cpuFallbackActive: false,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.cpuFallbackPending, isTrue);
      expect(decision.statusLabel, 'Precision pending');
      expect(decision.showPrecisionIndicator, isTrue);
    });

    test('does not label synthetic CPU fallback as CPU Precision', () {
      final decision = policy.decide(
        moduleId: 'unknown_fractal',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      expect(decision.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.exactness, PrecisionLadderExactness.approximate);
      expect(decision.statusLabel, 'GPU');
      expect(decision.showPrecisionIndicator, isFalse);
    });

    test('commits native non-extended deep zoom to CPU when fallback is active',
        () {
      final below = policy.decide(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 9.9e4,
      );
      final decision = policy.decide(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );

      expect(below.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(decision.renderPath, PrecisionLadderRenderPath.cpu);
      expect(decision.tier, PrecisionLadderTier.precisionRefine);
      expect(decision.exactness, PrecisionLadderExactness.cpuPrecision);
      expect(decision.statusLabel, 'CPU Precision');
    });
  });

  group('PrecisionLadderHysteresisState', () {
    test('exposes replayable streak transitions', () {
      const initial = PrecisionLadderHysteresisState.initial();

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
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );
      final secondCpu = hysteresis.update(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );

      expect(firstCpu.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(firstCpu.cpuFallbackPending, isTrue);
      expect(secondCpu.renderPath, PrecisionLadderRenderPath.cpu);
    });

    test('resets CPU activation when module changes', () {
      final hysteresis = PrecisionLadderHysteresis(policy: policy);

      hysteresis.update(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );
      hysteresis.update(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );

      final changed = hysteresis.update(
        moduleId: 'householder',
        dimension: FractalDimension.twoD,
        zoom: 1e9,
      );

      expect(changed.renderPath, PrecisionLadderRenderPath.gpuFloat);
      expect(changed.cpuFallbackPending, isTrue);
      expect(hysteresis.state.aboveThresholdCount, 1);
    });

    test('drops CPU activation below threshold and after reset', () {
      final hysteresis = PrecisionLadderHysteresis(policy: policy);

      hysteresis.update(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );
      expect(
        hysteresis
            .update(
              moduleId: 'weierstrass_p',
              dimension: FractalDimension.twoD,
              zoom: 1e6,
            )
            .renderPath,
        PrecisionLadderRenderPath.cpu,
      );
      expect(
        hysteresis
            .update(
              moduleId: 'weierstrass_p',
              dimension: FractalDimension.twoD,
              zoom: 1,
            )
            .renderPath,
        PrecisionLadderRenderPath.gpuFloat,
      );

      hysteresis.update(
        moduleId: 'weierstrass_p',
        dimension: FractalDimension.twoD,
        zoom: 1e6,
      );
      hysteresis.reset();
      expect(
        hysteresis
            .update(
              moduleId: 'weierstrass_p',
              dimension: FractalDimension.twoD,
              zoom: 1e6,
            )
            .renderPath,
        PrecisionLadderRenderPath.gpuFloat,
      );
    });
  });
}
