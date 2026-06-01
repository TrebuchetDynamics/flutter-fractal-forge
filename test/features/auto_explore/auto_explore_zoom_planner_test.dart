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

      expect(hardMax, 9.2e6);
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
      expect(plan.targetZoom, 1.0);
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

    test('normalizes invalid speed candidates before duration scaling', () {
      const config = AutoExploreConfig(
        travelDuration: Duration(milliseconds: 1000),
        maxDurationScale: 4.0,
      );
      const planner = AutoExploreZoomPlanner(config: config);

      expect(AutoExploreSpeed.normalize(0.0), 0.5);
      expect(AutoExploreSpeed.normalize(double.nan), 1.0);

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
