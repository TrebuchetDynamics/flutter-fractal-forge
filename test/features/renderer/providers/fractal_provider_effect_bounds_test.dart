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
  });
}
