import 'dart:math' as math;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_session_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStatsService extends ExplorationStatsService {
  final List<double> zoomDistances = [];
  final List<String> fractalsExplored = [];
  Duration? lastExploreTime;

  @override
  void addZoomDistance(double distance) => zoomDistances.add(distance);

  @override
  void addExploreTime(Duration duration) => lastExploreTime = duration;

  @override
  void recordFractalExplored(String moduleId) => fractalsExplored.add(moduleId);
}

void main() {
  late ModuleRegistry registry;
  late FractalController controller;

  setUp(() {
    registry = ModuleRegistry();
    controller = FractalController(registry);
  });

  tearDown(() {
    controller.dispose();
  });

  group('ViewerSessionTracker.attach', () {
    test('lastModuleId is null before attach', () {
      final tracker = ViewerSessionTracker();
      expect(tracker.lastModuleId, isNull);
    });

    test('sets lastModuleId to the controller module', () {
      final tracker = ViewerSessionTracker();
      tracker.attach(controller);
      expect(tracker.lastModuleId, controller.module.id);
    });

    test('records initial module as explored', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);
      expect(stats.fractalsExplored, [controller.module.id]);
    });

    test('second attach records the new module', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);

      final controller2 = FractalController(registry);
      try {
        tracker.attach(controller2);
        expect(tracker.lastModuleId, controller2.module.id);
        expect(stats.fractalsExplored.length, 2);
      } finally {
        controller2.dispose();
      }
    });
  });

  group('ViewerSessionTracker.onControllerChanged', () {
    test('records zoom distance when zoom changes', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);

      controller.updateZoom(controller.view.zoom * 4);
      tracker.onControllerChanged(controller);

      expect(stats.zoomDistances.length, 1);
      expect(stats.zoomDistances.first, greaterThan(0));
    });

    test('does not record zoom distance when zoom is unchanged', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);

      tracker.onControllerChanged(controller); // no zoom change

      expect(stats.zoomDistances, isEmpty);
    });

    test('zoom distance formula is abs(log(new/old))', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);

      final oldZoom = controller.view.zoom;
      controller.updateZoom(oldZoom * 4);
      final newZoom = controller.view.zoom;
      tracker.onControllerChanged(controller);

      final expected = (math.log(newZoom / oldZoom)).abs();
      expect(stats.zoomDistances.first, closeTo(expected, 1e-10));
    });

    test('records new module when module changes', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);
      stats.fractalsExplored.clear();

      controller.selectModule(registry.modules[1], animate: false);
      tracker.onControllerChanged(controller);

      expect(stats.fractalsExplored, [registry.modules[1].id]);
    });

    test('updates lastModuleId when module changes', () {
      final tracker = ViewerSessionTracker();
      tracker.attach(controller);

      controller.selectModule(registry.modules[1], animate: false);
      tracker.onControllerChanged(controller);

      expect(tracker.lastModuleId, registry.modules[1].id);
    });

    test('does not record module when module is unchanged', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);
      stats.fractalsExplored.clear();

      tracker.onControllerChanged(controller);

      expect(stats.fractalsExplored, isEmpty);
    });
  });

  group('ViewerSessionTracker.end', () {
    test('no-op before attach — does not throw', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.end();
      expect(stats.lastExploreTime, isNull);
    });

    test('records a non-negative elapsed time after attach', () {
      final stats = _FakeStatsService();
      final tracker = ViewerSessionTracker(statsService: stats);
      tracker.attach(controller);
      tracker.end();
      expect(stats.lastExploreTime, isNotNull);
      expect(stats.lastExploreTime!.inMicroseconds, greaterThanOrEqualTo(0));
    });
  });
}
