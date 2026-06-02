import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoExploreService', () {
    test('dispose cancels without sending a playback update', () {
      final controller = FractalController(ModuleRegistry());
      final service = AutoExploreService(controller: controller);
      addTearDown(controller.dispose);

      var notifications = 0;
      service.addListener(() => notifications++);

      service.dispose();

      expect(notifications, 0);
    });

    test('ignores one-shot corrections during continuous user interaction',
        () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        config: const AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1),
        ),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      await Future<void>.delayed(Duration.zero);
      service.onUserInteractionStart();

      expect(service.pausedByUserCorrection, isTrue);

      controller.updateZoom(2.0);
      service.onUserCorrection();

      expect(service.pausedByUserCorrection, isTrue);
      expect(service.isPaused, isFalse);

      service.onUserInteractionEnd();

      expect(service.pausedByUserCorrection, isFalse);
    });

    test('toggle resumes from temporary user yield instead of pausing',
        () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        config: const AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1),
        ),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      await Future<void>.delayed(Duration.zero);
      service.onUserInteractionStart();

      expect(service.pausedByUserCorrection, isTrue);
      expect(service.isPaused, isFalse);

      service.toggle();

      expect(service.isExploring, isTrue);
      expect(service.isPaused, isFalse);
      expect(service.pausedByUserCorrection, isFalse);
    });

    test('resume replans from a zoom changed while paused', () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        config: const AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1),
        ),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      await Future<void>.delayed(Duration.zero);
      service.pause();

      controller.updateZoom(10.0);
      service.resume();

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.view.zoom, 1200.0);
    });

    test('ignores unmatched continuous interaction end callbacks', () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        config: const AutoExploreConfig(
          travelDuration: Duration(milliseconds: 1),
        ),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.view.zoom, 120.0);

      service.onUserInteractionEnd();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.view.zoom, AutoExploreConfig.defaultMinZoom);
    });
  });
}
