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

  _registerAnimationLeakRegression();
}

void _registerAnimationLeakRegression() {
  group('AutoExploreService animation interruption', () {
    test('interrupting a zoom leg resolves the in-flight animation future',
        () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        // Long enough that the leg is still animating when we interrupt it.
        config: const AutoExploreConfig(
          travelDuration: Duration(seconds: 2),
        ),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      // Let the scheduled leg start its periodic animation.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      expect(service.debugHasPendingAnimation, isTrue,
          reason: 'a zoom-leg animation should be in flight after start');

      // Interrupting motion cancels the periodic timer. The in-flight future
      // must be resolved (not left hanging), so no suspended async frame leaks.
      service.onUserInteractionStart();
      expect(service.debugHasPendingAnimation, isFalse,
          reason: 'interruption must resolve the animation future');

      // Service stays usable: ending the gesture resumes auto-explore.
      service.onUserInteractionEnd();
      expect(service.isExploring, isTrue);
    });

    test('pausing mid-leg resolves the animation future', () async {
      final controller = FractalController(ModuleRegistry());
      controller.resetView();
      controller.updateZoom(1.0);

      final service = AutoExploreService(
        controller: controller,
        config: const AutoExploreConfig(travelDuration: Duration(seconds: 2)),
      );
      addTearDown(service.dispose);
      addTearDown(controller.dispose);

      service.start();
      await Future<void>.delayed(const Duration(milliseconds: 16));
      expect(service.debugHasPendingAnimation, isTrue);

      service.pause();
      expect(service.debugHasPendingAnimation, isFalse);
      expect(service.isPaused, isTrue);
    });
  });
}
