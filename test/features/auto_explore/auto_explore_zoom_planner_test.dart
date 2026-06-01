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
  });
}
