import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoExploreService', () {
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
  });
}
