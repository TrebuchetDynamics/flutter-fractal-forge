import 'package:flutter_fractals/core/controllers/fractal_kaleidoscope_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalKaleidoscopeModulePolicy', () {
    test('forces only dedicated kaleidoscope catalog modules', () {
      expect(
        FractalKaleidoscopeModulePolicy.isForcedModuleId('kaleidoscope_basic'),
        isTrue,
      );
      expect(
        FractalKaleidoscopeModulePolicy.isForcedModuleId(
          'kaleidoscope_fractal',
        ),
        isTrue,
      );

      expect(
        FractalKaleidoscopeModulePolicy.isForcedModuleId(
          'flame-horseshoe-kaleidoscope',
        ),
        isFalse,
      );
      expect(
        FractalKaleidoscopeModulePolicy.isForcedModuleId(
          'f0148_kaleidoscope_julia',
        ),
        isFalse,
      );
    });

    test('leaves embedded-kaleidoscope fractal modules untouched', () {
      const current = FractalKaleidoscopeState(
        enabled: false,
        sectors: 6,
        mirror: true,
        rotation: 0.25,
        mirrorMode: 1,
      );

      final transition = FractalKaleidoscopeModulePolicy.transitionForModule(
        moduleId: 'flame-horseshoe-kaleidoscope',
        current: current,
        restoreAfterForcedModule: null,
      );

      expect(transition.effective.enabled, isFalse);
      expect(transition.effective.sectors, 6);
      expect(transition.effective.rotation, 0.25);
      expect(transition.effective.mirrorMode, 1);
      expect(transition.restoreAfterForcedModule, isNull);
    });
  });
}
