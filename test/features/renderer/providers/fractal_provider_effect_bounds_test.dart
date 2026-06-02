import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalController effect input bounds', () {
    test('preserves glow settings when replayed values are NaN', () {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);

      controller.setGlowSigma(2.5);
      controller.setGlowIntensity(0.6);

      controller.setGlowSigma(double.nan);
      controller.setGlowIntensity(double.nan);

      expect(controller.glowSigma, 2.5);
      expect(controller.glowIntensity, 0.6);
    });

    test('preserves kaleidoscope rotation when replayed values are non-finite',
        () {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);

      controller.setKaleidoscopeRotation(0.75);

      controller.setKaleidoscopeRotation(double.nan);
      expect(controller.kaleidoscopeRotation, 0.75);

      controller.setKaleidoscopeRotation(double.infinity);
      expect(controller.kaleidoscopeRotation, 0.75);
    });

    test('does not leak forced kaleidoscope defaults after module exit', () {
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      addTearDown(controller.dispose);

      final normalModule = registry.byId('mandelbrot');
      final kaleidoscopeModule = registry.byId('kaleidoscope_basic');

      controller.selectModule(normalModule, animate: false);
      controller.setKaleidoscopeEnabled(false);
      controller.setKaleidoscopeSectors(6);
      controller.setKaleidoscopeMirrorMode(1);

      controller.selectModule(kaleidoscopeModule, animate: false);

      expect(controller.kaleidoscopeEnabled, isTrue);
      expect(controller.kaleidoscopeSectors, 16);
      expect(controller.kaleidoscopeMirrorMode, 3);

      controller.selectModule(normalModule, animate: false);

      expect(controller.kaleidoscopeEnabled, isFalse);
      expect(controller.kaleidoscopeSectors, 6);
      expect(controller.kaleidoscopeMirrorMode, 1);
    });
  });
}
