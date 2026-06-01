import 'package:flutter_fractals/features/auto_explore/auto_explore_zoom_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

      expect(
        planner.nextTargetZoom(
          currentZoom: 12.0,
          cycleBaseZoom: baseZoom,
          zoomingIn: true,
          moduleId: 'mandelbrot',
        ),
        1200.0,
      );
      expect(
        planner.nextTargetZoom(
          currentZoom: 12.0,
          cycleBaseZoom: baseZoom,
          zoomingIn: false,
          moduleId: 'mandelbrot',
        ),
        AutoExploreConfig().minZoom,
      );
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
  });
}
