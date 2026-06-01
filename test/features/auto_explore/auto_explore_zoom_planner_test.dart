import 'package:flutter_fractals/features/auto_explore/auto_explore_zoom_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoExploreCorrectionDecision', () {
    test('maps visible zoom changes to the next leg direction', () {
      expect(
        AutoExploreCorrectionDecision.fromZooms(
          currentZoom: 10.002,
          previousZoom: 10.0,
        ).resolve(currentZoomingIn: false),
        isTrue,
      );
      expect(
        AutoExploreCorrectionDecision.fromZooms(
          currentZoom: 9.998,
          previousZoom: 10.0,
        ).resolve(currentZoomingIn: true),
        isFalse,
      );
    });

    test('preserves current direction inside the correction deadband', () {
      final decision = AutoExploreCorrectionDecision.fromZooms(
        currentZoom: 10.0005,
        previousZoom: 10.0,
      );

      expect(decision.changedDirection, isFalse);
      expect(decision.resolve(currentZoomingIn: true), isTrue);
      expect(decision.resolve(currentZoomingIn: false), isFalse);
    });

    test('normalizes malformed correction epsilon', () {
      final decision = AutoExploreCorrectionDecision.fromZooms(
        currentZoom: 10.0005,
        previousZoom: 10.0,
        relativeEpsilon: double.nan,
      );

      expect(decision.changedDirection, isFalse);
      expect(AutoExploreRelativeEpsilon.normalize(-0.1), 1e-4);
      expect(AutoExploreRelativeEpsilon.normalize(double.infinity), 1e-4);
    });

    test('normalizes correction epsilon before it hides zoom-out intent', () {
      final decision = AutoExploreCorrectionDecision.fromZooms(
        currentZoom: 5.0,
        previousZoom: 10.0,
        relativeEpsilon: 1.5,
      );

      expect(AutoExploreRelativeEpsilon.normalize(1.5), 1e-4);
      expect(decision.changedDirection, isTrue);
      expect(decision.resolve(currentZoomingIn: true), isFalse);
    });

    test('preserves direction when correction zoom samples are unusable', () {
      for (final sample in [
        (currentZoom: double.nan, previousZoom: 10.0),
        (currentZoom: double.infinity, previousZoom: 10.0),
        (currentZoom: 10.0, previousZoom: double.nan),
        (currentZoom: 10.0, previousZoom: double.infinity),
        (currentZoom: 10.0, previousZoom: 0.0),
      ]) {
        final decision = AutoExploreCorrectionDecision.fromZooms(
          currentZoom: sample.currentZoom,
          previousZoom: sample.previousZoom,
        );

        expect(
          decision.changedDirection,
          isFalse,
          reason:
              'current=${sample.currentZoom}, previous=${sample.previousZoom}',
        );
        expect(decision.resolve(currentZoomingIn: true), isTrue);
        expect(decision.resolve(currentZoomingIn: false), isFalse);
      }
    });

    test('replays user zoom adoption fallback order', () {
      const bounds = AutoExploreZoomBounds(minZoom: 0.2, maxZoom: 100.0);

      final interactionAdoption = AutoExploreZoomAdoption.fromSamples(
        bounds: bounds,
        currentZoom: 20.0,
        referenceZoom: 30.0,
        lastCorrectionZoom: 10.0,
        wasZoomingIn: true,
      );
      final correctionAdoption = AutoExploreZoomAdoption.fromSamples(
        bounds: bounds,
        currentZoom: 8.0,
        referenceZoom: null,
        lastCorrectionZoom: 10.0,
        wasZoomingIn: true,
      );
      final noHistoryAdoption = AutoExploreZoomAdoption.fromSamples(
        bounds: bounds,
        currentZoom: double.nan,
        referenceZoom: null,
        lastCorrectionZoom: null,
        wasZoomingIn: false,
      );

      expect(interactionAdoption.previousZoom, 30.0);
      expect(interactionAdoption.zoomingIn, isFalse);
      expect(correctionAdoption.previousZoom, 10.0);
      expect(correctionAdoption.zoomingIn, isFalse);
      expect(noHistoryAdoption.currentZoom, bounds.minZoom);
      expect(noHistoryAdoption.previousZoom, bounds.minZoom);
      expect(noHistoryAdoption.zoomingIn, isFalse);
      expect(noHistoryAdoption.correctionDecision.changedDirection, isFalse);
    });
  });

  group('AutoExploreZoomSpanScale', () {
    test('makes the cinematic duration span threshold explicit', () {
      expect(AutoExploreZoomSpanScale.normalized(double.nan), 0.0);
      expect(AutoExploreZoomSpanScale.normalized(-1.0), 0.0);
      expect(AutoExploreZoomSpanScale.normalized(0.8), 0.5);
      expect(AutoExploreZoomSpanScale.normalized(1.6), 1.0);
      expect(AutoExploreZoomSpanScale.normalized(3.2), 1.0);
    });
  });

  group('AutoExploreZoomPlanner', () {
    const planner = AutoExploreZoomPlanner(config: AutoExploreConfig());

    test('keeps peak zoom under module precision headroom', () {
      // Unknown modules use the default 1e7 precision threshold, so headroom is
      // 9.2e6. A base zoom near that edge used to let the 1.25x minimum peak
      // overrun the module-aware hard max.
      const moduleId = 'unknown_orbit_module';
      const baseZoom = 9.0e6;

      final hardMax = planner.hardMaxZoomFor(moduleId);
      final peakZoom = planner.computePeakZoom(
        baseZoom: baseZoom,
        moduleId: moduleId,
      );

      final candidates = planner.peakZoomCandidates(
        baseZoom: baseZoom,
        moduleId: moduleId,
      );

      expect(hardMax, 9.2e6);
      expect(candidates.precisionCappedDesiredZoom, hardMax);
      expect(candidates.precisionLimited, isTrue);
      expect(peakZoom, hardMax);
      expect(peakZoom, lessThanOrEqualTo(hardMax));
    });

    test('does not promote invalid precision headroom to max zoom', () {
      const planner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(precisionHeadroom: double.nan),
      );

      expect(planner.hardMaxZoomFor('unknown_orbit_module'), 1e7);
      expect(
        planner.computePeakZoom(
          baseZoom: 9.0e6,
          moduleId: 'unknown_orbit_module',
        ),
        lessThanOrEqualTo(1e7),
      );
    });

    test('plans zoom-in and zoom-out targets from the same cycle base', () {
      const baseZoom = 10.0;

      final zoomInPlan = planner.planNextTarget(
        currentZoom: 12.0,
        cycleBaseZoom: baseZoom,
        zoomingIn: true,
        moduleId: 'mandelbrot',
      );
      final zoomOutPlan = planner.planNextTarget(
        currentZoom: 12.0,
        cycleBaseZoom: baseZoom,
        zoomingIn: false,
        moduleId: 'mandelbrot',
      );

      expect(zoomInPlan.currentZoom, 12.0);
      expect(zoomInPlan.baseZoom, baseZoom);
      expect(zoomInPlan.peakZoom, 1200.0);
      expect(zoomInPlan.floorZoom, AutoExploreConfig().minZoom);
      expect(zoomInPlan.targetZoom, 1200.0);
      expect(zoomOutPlan.targetZoom, AutoExploreConfig().minZoom);
      expect(
        planner.nextTargetZoom(
          currentZoom: 12.0,
          cycleBaseZoom: baseZoom,
          zoomingIn: true,
          moduleId: 'mandelbrot',
        ),
        zoomInPlan.targetZoom,
      );
    });

    test('exposes sanitized target planning inputs', () {
      final missingBaseInputs = planner.planInputs(
        currentZoom: double.nan,
        cycleBaseZoom: null,
      );
      final malformedBaseInputs = planner.planInputs(
        currentZoom: 10.0,
        cycleBaseZoom: double.nan,
      );

      expect(missingBaseInputs.currentZoom, AutoExploreConfig().minZoom);
      expect(missingBaseInputs.baseZoom, missingBaseInputs.currentZoom);
      expect(malformedBaseInputs.currentZoom, 10.0);
      expect(malformedBaseInputs.baseZoom, AutoExploreConfig().minZoom);
    });

    test('makes collapsed target plans explicit', () {
      const collapsedPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: 1.0, maxZoom: 1.0),
      );

      final plan = collapsedPlanner.planNextTarget(
        currentZoom: 42.0,
        cycleBaseZoom: null,
        zoomingIn: true,
        moduleId: 'unknown_orbit_module',
      );

      expect(plan.currentZoom, 1.0);
      expect(plan.baseZoom, 1.0);
      expect(plan.peakZoom, 1.0);
      expect(plan.floorZoom, 1.0);
      expect(plan.isCollapsed, isTrue);
      expect(plan.targetRange.targetZoom(zoomingIn: false), 1.0);
      expect(plan.targetZoom, 1.0);
    });

    test('collapsed target plans do not return a base above resolved range',
        () {
      const precisionCollapsedPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: 1e11, maxZoom: 1e12),
      );

      final plan = precisionCollapsedPlanner.planNextTarget(
        currentZoom: 1e12,
        cycleBaseZoom: 1e12,
        zoomingIn: true,
        moduleId: 'unknown_orbit_module',
      );

      expect(plan.baseZoom, 1e12);
      expect(plan.peakZoom, 1e11);
      expect(plan.floorZoom, 1e11);
      expect(plan.isCollapsed, isTrue);
      expect(plan.targetZoom, 1e11);
      expect(
        precisionCollapsedPlanner.nextTargetZoom(
          currentZoom: 1e12,
          cycleBaseZoom: 1e12,
          zoomingIn: true,
          moduleId: 'unknown_orbit_module',
        ),
        1e11,
      );
    });

    test('orders target ranges after precision caps lower the peak', () {
      final plan = planner.planNextTarget(
        currentZoom: 1e12,
        cycleBaseZoom: 1e12,
        zoomingIn: false,
        moduleId: 'unknown_orbit_module',
      );

      expect(plan.peakZoom, 9.2e6);
      expect(plan.floorZoom, plan.peakZoom);
      expect(plan.isCollapsed, isTrue);
      expect(plan.targetZoom, 9.2e6);
      expect(plan.targetRange.floorZoom, lessThanOrEqualTo(plan.peakZoom));
    });

    test('scales leg duration by zoom span and speed', () {
      const config = AutoExploreConfig(
        travelDuration: Duration(milliseconds: 1000),
        maxDurationScale: 4.0,
      );
      const fastPlanner = AutoExploreZoomPlanner(config: config);

      expect(
        fastPlanner.durationForZoomLeg(
          startZoom: 1.0,
          endZoom: 1.0,
          speed: 2.0,
        ),
        const Duration(milliseconds: 500),
      );
      expect(
        fastPlanner.durationForZoomLeg(
          startZoom: 1.0,
          endZoom: 1e6,
          speed: 2.0,
        ),
        const Duration(milliseconds: 2000),
      );
    });

    test('exposes replayable animation timing for service zoom legs', () {
      const config = AutoExploreConfig(
        travelDuration: Duration(milliseconds: 1000),
        maxDurationScale: 4.0,
      );
      const planner = AutoExploreZoomPlanner(config: config);

      final plan = planner.animationPlanForZoomLeg(
        startZoom: double.nan,
        endZoom: 1e6,
        speed: 2.0,
      );

      expect(plan.startZoom, AutoExploreConfig().minZoom);
      expect(plan.endZoom, 1e6);
      expect(plan.duration, const Duration(milliseconds: 2000));
      expect(plan.frameInterval, const Duration(milliseconds: 16));
      expect(plan.totalFrames, 125);
      expect(plan.frameTiming.totalFrames, plan.totalFrames);
      expect(plan.interpolate(double.nan), plan.startZoom);
      expect(plan.interpolate(1.0), plan.endZoom);
    });

    test('counts sub-millisecond frame intervals without division by zero', () {
      final timing = AutoExploreFrameTiming(
        duration: const Duration(milliseconds: 2),
        frameInterval: const Duration(microseconds: 500),
      );

      expect(timing.totalFrames, 4);
    });

    test('normalizes invalid speed candidates before duration scaling', () {
      const config = AutoExploreConfig(
        travelDuration: Duration(milliseconds: 1000),
        maxDurationScale: 4.0,
      );
      const planner = AutoExploreZoomPlanner(config: config);

      expect(AutoExploreSpeed.normalize(0.0), AutoExploreSpeed.min);
      expect(AutoExploreSpeed.normalize(double.nan), AutoExploreSpeed.neutral);
      expect(
        AutoExploreSpeed.normalize(double.infinity),
        AutoExploreSpeed.neutral,
      );
      expect(
        AutoExploreSpeed.normalize(double.negativeInfinity),
        AutoExploreSpeed.neutral,
      );

      expect(
        planner.durationForZoomLeg(
          startZoom: 1.0,
          endZoom: 1.0,
          speed: 0.0,
        ),
        const Duration(milliseconds: 2000),
      );
      expect(
        planner.durationForZoomLeg(
          startZoom: 1.0,
          endZoom: 1.0,
          speed: double.nan,
        ),
        const Duration(milliseconds: 1000),
      );
      expect(
        planner.durationForZoomLeg(
          startZoom: 1.0,
          endZoom: 1.0,
          speed: double.infinity,
        ),
        const Duration(milliseconds: 1000),
      );
    });

    test('does not treat NaN zoom as maximum zoom', () {
      const planner = AutoExploreZoomPlanner(config: AutoExploreConfig());

      expect(planner.clampZoom(double.nan), AutoExploreConfig().minZoom);
      expect(
        planner.nextTargetZoom(
          currentZoom: double.nan,
          cycleBaseZoom: null,
          zoomingIn: true,
          moduleId: 'mandelbrot',
        ),
        24.0,
      );
    });

    test('normalizes malformed zoom bounds before clamping candidates', () {
      const reversedPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: 100.0, maxZoom: 1.0),
      );
      const invalidPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: double.nan, maxZoom: -1.0),
      );

      expect(reversedPlanner.clampZoom(0.5), 1.0);
      expect(reversedPlanner.clampZoom(200.0), 100.0);
      expect(invalidPlanner.clampZoom(double.nan), 0.2);
      expect(invalidPlanner.clampZoom(double.infinity), 1e12);
    });

    test('uses normalized zoom bounds for precision hard max planning', () {
      const reversedPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: 100.0, maxZoom: 1.0),
      );
      const invalidPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(minZoom: double.nan, maxZoom: -1.0),
      );

      expect(reversedPlanner.hardMaxZoomFor('unknown_orbit_module'), 100.0);
      expect(invalidPlanner.hardMaxZoomFor('unknown_orbit_module'), 9.2e6);
      expect(
        reversedPlanner.nextTargetZoom(
          currentZoom: 10.0,
          cycleBaseZoom: null,
          zoomingIn: true,
          moduleId: 'unknown_orbit_module',
        ),
        100.0,
      );
    });

    test('sanitizes invalid zoom endpoints before duration math', () {
      const config = AutoExploreConfig(
        travelDuration: Duration(milliseconds: 1000),
        maxDurationScale: 4.0,
      );
      const planner = AutoExploreZoomPlanner(config: config);

      expect(
        planner.durationForZoomLeg(
          startZoom: double.nan,
          endZoom: 1.0,
          speed: 1.0,
        ),
        const Duration(milliseconds: 2311),
      );
      expect(
        planner.durationForZoomLeg(
          startZoom: double.infinity,
          endZoom: 1.0,
          speed: 1.0,
        ),
        const Duration(milliseconds: 4000),
      );
    });

    test('keeps interpolation finite for huge but valid zoom bounds', () {
      const planner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(maxZoom: 1e308),
      );

      expect(planner.interpolateZoom(0.2, 1e308, 0.0), 0.2);
      expect(planner.interpolateZoom(0.2, 1e308, 1.0), 1e308);
      expect(
        planner.interpolateZoom(0.2, 1e308, 0.5),
        predicate<double>((value) => value.isFinite, 'finite zoom'),
      );
      expect(planner.interpolateZoom(0.2, 1e308, double.nan), 0.2);
    });

    test('scales duration for huge but finite zoom spans', () {
      const planner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          maxZoom: 1e308,
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: 4.0,
        ),
      );

      expect(
        planner.durationForZoomLeg(
          startZoom: 0.2,
          endZoom: 1e308,
          speed: 1.0,
        ),
        const Duration(milliseconds: 4000),
      );
    });

    test('exposes peak target candidates for replayable span decisions', () {
      final candidates = planner.peakZoomCandidates(
        baseZoom: 10.0,
        moduleId: 'mandelbrot',
      );
      final plan = planner.planNextTarget(
        currentZoom: 10.0,
        cycleBaseZoom: 10.0,
        zoomingIn: true,
        moduleId: 'mandelbrot',
      );

      expect(candidates.baseZoom, 10.0);
      expect(candidates.minProgressZoom, 12.5);
      expect(candidates.configuredPeakZoom, 1200.0);
      expect(
        candidates.spanLimitedPeakZoom,
        moreOrLessEquals(15848.9319, epsilon: 1e-4),
      );
      expect(candidates.hardMaxZoom, 9.2e11);
      expect(candidates.desiredPeakZoom, 1200.0);
      expect(candidates.precisionCappedDesiredZoom, 1200.0);
      expect(candidates.minimumProgressCappedBySpan, isFalse);
      expect(candidates.precisionLimited, isFalse);
      expect(candidates.resolvedPeakZoom, 1200.0);
      expect(plan.peakCandidates.baseZoom, candidates.baseZoom);
      expect(plan.peakCandidates.resolvedPeakZoom, candidates.resolvedPeakZoom);
      expect(plan.peakZoom, plan.peakCandidates.resolvedPeakZoom);
      expect(plan.respectsPrecisionHardMax, isTrue);
    });

    test('does not let minimum peak nudge exceed max leg span', () {
      const zeroSpanPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(maxLegSpanDecades: 0.0),
      );

      final candidates = zeroSpanPlanner.peakZoomCandidates(
        baseZoom: 10.0,
        moduleId: 'mandelbrot',
      );

      expect(candidates.minProgressZoom, 12.5);
      expect(candidates.spanLimitedPeakZoom, 10.0);
      expect(candidates.cappedMinimumProgressZoom, 10.0);
      expect(candidates.minimumProgressCappedBySpan, isTrue);
      expect(candidates.precisionLimited, isFalse);
      expect(candidates.resolvedPeakZoom, 10.0);
      expect(
        zeroSpanPlanner.computePeakZoom(
          baseZoom: 10.0,
          moduleId: 'mandelbrot',
        ),
        10.0,
      );
    });

    test('normalizes invalid cycle shape before target planning', () {
      const zeroMultiplierPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(cycleMaxMultiplier: 0.0),
      );
      const nanMultiplierPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(cycleMaxMultiplier: double.nan),
      );
      const infiniteMultiplierPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(cycleMaxMultiplier: double.infinity),
      );
      const nanSpanPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(maxLegSpanDecades: double.nan),
      );

      expect(
        zeroMultiplierPlanner.nextTargetZoom(
          currentZoom: 10.0,
          cycleBaseZoom: 10.0,
          zoomingIn: false,
          moduleId: 'mandelbrot',
        ),
        AutoExploreConfig().minZoom,
      );
      for (final planner in [
        nanMultiplierPlanner,
        infiniteMultiplierPlanner,
        nanSpanPlanner,
      ]) {
        expect(
          planner.computePeakZoom(baseZoom: 10.0, moduleId: 'mandelbrot'),
          1200.0,
        );
      }

      expect(
        AutoExploreCycleShape.fromConfig(
          const AutoExploreConfig(cycleMaxMultiplier: 0.0),
        ).cycleMaxMultiplier,
        AutoExploreConfig().cycleMaxMultiplier,
      );
    });

    test('caps oversized base durations before scaling milliseconds', () {
      final milliseconds = AutoExploreLegDuration.milliseconds(
        baseDuration: const Duration(milliseconds: 9223372036855),
        scale: 1.0,
        speed: 1.0,
      );

      expect(milliseconds, 9223372036854);
    });

    test('sanitizes invalid duration scale before rounding milliseconds', () {
      const nanScalePlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: double.nan,
        ),
      );
      const infiniteScalePlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: double.infinity,
        ),
      );
      const belowNeutralScalePlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: 0.0,
        ),
      );
      const overflowingFiniteScalePlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: 1e308,
        ),
      );
      const finiteButDurationOverflowingPlanner = AutoExploreZoomPlanner(
        config: AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1000),
          maxDurationScale: 1e16,
        ),
      );

      for (final planner in [
        nanScalePlanner,
        infiniteScalePlanner,
        belowNeutralScalePlanner,
        overflowingFiniteScalePlanner,
        finiteButDurationOverflowingPlanner,
      ]) {
        expect(
          planner.durationForZoomLeg(
            startZoom: 1.0,
            endZoom: 1e6,
            speed: 1.0,
          ),
          const Duration(milliseconds: 1000),
        );
      }
    });
  });
}
