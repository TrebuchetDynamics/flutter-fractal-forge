import 'package:flutter_fractals/core/controllers/input/fractal_effect_input_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalEffectInputBounds', () {
    test('preserves current bounded effect values when candidate is NaN', () {
      expect(
        FractalEffectInputBounds.normalizeGlowSigma(
          candidate: double.nan,
          current: 2.5,
        ),
        2.5,
      );
      expect(
        FractalEffectInputBounds.normalizeGlowIntensity(
          candidate: double.nan,
          current: 0.6,
        ),
        0.6,
      );
    });

    test('clamps finite and infinite bounded effect values', () {
      expect(
        FractalEffectInputBounds.normalizeGlowSigma(
          candidate: double.negativeInfinity,
          current: 2.5,
        ),
        FractalEffectInputBounds.minGlowSigma,
      );
      expect(
        FractalEffectInputBounds.normalizeGlowSigma(
          candidate: double.infinity,
          current: 2.5,
        ),
        FractalEffectInputBounds.maxGlowSigma,
      );
      expect(
        FractalEffectInputBounds.normalizeGlowIntensity(
          candidate: -0.5,
          current: 0.6,
        ),
        FractalEffectInputBounds.minGlowIntensity,
      );
      expect(
        FractalEffectInputBounds.normalizeGlowIntensity(
          candidate: 2.0,
          current: 0.6,
        ),
        FractalEffectInputBounds.maxGlowIntensity,
      );
    });

    test('preserves finite kaleidoscope rotation for non-finite candidates',
        () {
      expect(
        FractalEffectInputBounds.normalizeKaleidoscopeRotation(
          candidate: double.nan,
          current: 0.75,
        ),
        0.75,
      );
      expect(
        FractalEffectInputBounds.normalizeKaleidoscopeRotation(
          candidate: double.infinity,
          current: 0.75,
        ),
        0.75,
      );
    });
  });
}
