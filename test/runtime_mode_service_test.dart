import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';

void main() {
  // Initialize the Flutter test binding so that _bindingLooksLikeTest() can
  // detect AutomatedTestWidgetsFlutterBinding and isAutomatedTest returns true.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RuntimeModeService', () {
    test('isAutomatedTest returns true in test environment', () {
      // After ensureInitialized(), the binding is AutomatedTestWidgetsFlutterBinding,
      // so _bindingLooksLikeTest() returns true and isAutomatedTest is true.
      expect(RuntimeModeService.isAutomatedTest, isTrue);
    });

    test('forceGpuRender defaults to false', () {
      // FORCE_GPU_RENDER is not set in unit tests, so this must be false.
      expect(RuntimeModeService.forceGpuRender, isFalse);
    });

    test('useRendererPlaceholderSurface returns true in test environment', () {
      // isAutomatedTest=true and forceGpuRender=false → placeholder surface used.
      expect(RuntimeModeService.useRendererPlaceholderSurface, isTrue);
    });

    test('isIntegrationTest returns false in unit test environment', () {
      // Unit tests use AutomatedTestWidgetsFlutterBinding, not
      // IntegrationTestWidgetsFlutterBinding.
      expect(RuntimeModeService.isIntegrationTest, isFalse);
    });

    test('useRendererPlaceholderSurface is consistent with isAutomatedTest when forceGpuRender is false', () {
      // When forceGpuRender is false, useRendererPlaceholderSurface == isAutomatedTest.
      if (!RuntimeModeService.forceGpuRender) {
        expect(
          RuntimeModeService.useRendererPlaceholderSurface,
          RuntimeModeService.isAutomatedTest,
        );
      }
    });
  });
}
