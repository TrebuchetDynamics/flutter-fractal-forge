import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/renderer_ticker_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RendererTickerPolicy', () {
    test('does not tick an idle static module', () {
      expect(
        RendererTickerPolicy.shouldTick(
          animationEnabled: true,
          moduleUsesTime: false,
          fluidEffectActive: false,
          paletteTransitionActive: false,
          morphTransitionActive: false,
          celebrationActive: false,
        ),
        isFalse,
      );
    });

    test('ticks for each explicit continuous-rendering reason', () {
      bool shouldTick({
        bool moduleUsesTime = false,
        bool fluidEffectActive = false,
        bool paletteTransitionActive = false,
        bool morphTransitionActive = false,
        bool celebrationActive = false,
      }) =>
          RendererTickerPolicy.shouldTick(
            animationEnabled: true,
            moduleUsesTime: moduleUsesTime,
            fluidEffectActive: fluidEffectActive,
            paletteTransitionActive: paletteTransitionActive,
            morphTransitionActive: morphTransitionActive,
            celebrationActive: celebrationActive,
          );

      expect(shouldTick(moduleUsesTime: true), isTrue);
      expect(shouldTick(fluidEffectActive: true), isTrue);
      expect(shouldTick(paletteTransitionActive: true), isTrue);
      expect(shouldTick(morphTransitionActive: true), isTrue);
      expect(shouldTick(celebrationActive: true), isTrue);
    });

    test('master animation switch disables every ticker reason', () {
      expect(
        RendererTickerPolicy.shouldTick(
          animationEnabled: false,
          moduleUsesTime: true,
          fluidEffectActive: true,
          paletteTransitionActive: true,
          morphTransitionActive: true,
          celebrationActive: true,
        ),
        isFalse,
      );
    });
  });

  group('catalog animation metadata', () {
    test('marks validated time-driven modules explicitly', () {
      final registry = ModuleRegistry();

      for (final id in [
        'fractal_flame',
        'lichtenberg_growth',
        'gray_scott_rd',
        'mandelbulb_time_modulated',
      ]) {
        expect(
          registry.byId(id).animationCapability,
          FractalAnimationCapability.timeDriven,
          reason: id,
        );
      }
    });

    test('keeps ordinary modules static by default', () {
      expect(
        ModuleRegistry().byId('mandelbrot').animationCapability,
        FractalAnimationCapability.static,
      );
    });
  });
}
