import 'dart:math' as math;

import 'package:flutter_fractals/features/viewer/audio/fourier_music_features.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FourierMusicFeatureMapper', () {
    test('maps normalized spectrum measurements to bounded musical controls',
        () {
      const input = FourierMusicSpectrumFrame(
        lowPowerRatio: 0.6,
        midPowerRatio: 0.3,
        highPowerRatio: 0.1,
        centroid: 0.75,
        entropy: 0.8,
        flatness: 0.4,
        orientation: math.pi / 4,
        anisotropy: 0.5,
        spectralFlux: 0.25,
      );

      final features = const FourierMusicFeatureMapper().map(input);

      expect(features.isSilent, isFalse);
      expect(features.bassWeight, closeTo(0.6, 1e-12));
      expect(features.padOpenness, closeTo(0.3, 1e-12));
      expect(features.highTexture, closeTo(0.1, 1e-12));
      expect(features.leadRegister, closeTo(0.75, 1e-12));
      expect(features.rhythmicComplexity, closeTo(0.6, 1e-12));
      expect(features.stereoBias, closeTo(0, 1e-12));
      expect(features.transitionStrength, closeTo(0.25, 1e-12));

      for (final value in features.normalizedValues) {
        expect(value.isFinite, isTrue);
        expect(value, inInclusiveRange(0.0, 1.0));
      }
      expect(features.stereoBias, inInclusiveRange(-1.0, 1.0));
    });
    test('uses a three-frame median before EWMA smoothing', () {
      const mapper = FourierMusicFeatureMapper();
      final smoother = FourierMusicFeatureSmoother(ewmaAlpha: 0.5);

      FourierMusicFeatures frame(double bass) => mapper.map(
            FourierMusicSpectrumFrame(
              lowPowerRatio: bass,
              midPowerRatio: 1 - bass,
              highPowerRatio: 0,
              centroid: 0.5,
              entropy: 0.5,
              flatness: 0.5,
              orientation: 0,
              anisotropy: 0.5,
              spectralFlux: 0.5,
            ),
          );

      expect(smoother.update(frame(0.2)).bassWeight, closeTo(0.2, 1e-12));
      expect(smoother.update(frame(1)).bassWeight, closeTo(0.4, 1e-12));
      final afterGlitch = smoother.update(frame(0.2));

      // Median([0.2, 1.0, 0.2]) = 0.2, then EWMA(0.4, 0.2) = 0.3.
      expect(afterGlitch.bassWeight, closeTo(0.3, 1e-12));
    });
    test('smooths axial orientation across the zero-pi seam', () {
      const mapper = FourierMusicFeatureMapper();
      final smoother = FourierMusicFeatureSmoother(ewmaAlpha: 0.5);

      FourierMusicFeatures oriented(double angle) => mapper.map(
            FourierMusicSpectrumFrame(
              lowPowerRatio: 1,
              midPowerRatio: 0,
              highPowerRatio: 0,
              centroid: 0.5,
              entropy: 0.5,
              flatness: 0.5,
              orientation: angle,
              anisotropy: 1,
              spectralFlux: 0,
            ),
          );

      smoother.update(oriented(math.pi - 0.02));
      smoother.update(oriented(0.02));
      final result = smoother.update(oriented(math.pi - 0.01));
      final distanceFromSeam = math.min(
        result.orientation,
        math.pi - result.orientation,
      );

      expect(distanceFromSeam, lessThan(0.03));
      expect(result.stereoBias, greaterThan(0.99));
    });
    test('applies hysteresis and commits categories only on bar boundaries',
        () {
      const mapper = FourierMusicFeatureMapper();
      final decisions = FourierMusicDecisionController(hysteresis: 0.05);

      FourierMusicFeatures frame(double value) => mapper.map(
            FourierMusicSpectrumFrame(
              lowPowerRatio: 0.34,
              midPowerRatio: 0.33,
              highPowerRatio: 0.33,
              centroid: value,
              entropy: value,
              flatness: value,
              orientation: 0,
              anisotropy: 0,
              spectralFlux: 0,
            ),
          );

      final initial = decisions.update(frame(0.5), isBarBoundary: true);
      expect(initial.rhythmDensity, FourierMusicRhythmDensity.steady);
      expect(initial.registerBand, FourierMusicRegisterBand.middle);

      final insideHysteresis = decisions.update(
        frame(0.72),
        isBarBoundary: true,
      );
      expect(insideHysteresis.rhythmDensity, FourierMusicRhythmDensity.steady);
      expect(insideHysteresis.registerBand, FourierMusicRegisterBand.middle);

      final betweenBars = decisions.update(frame(0.8), isBarBoundary: false);
      expect(betweenBars.rhythmDensity, FourierMusicRhythmDensity.steady);
      expect(betweenBars.registerBand, FourierMusicRegisterBand.middle);

      final nextBar = decisions.update(frame(0.8), isBarBoundary: true);
      expect(nextBar.rhythmDensity, FourierMusicRhythmDensity.busy);
      expect(nextBar.registerBand, FourierMusicRegisterBand.high);
    });
    test('holds default categories until the first bar boundary', () {
      final features = const FourierMusicFeatureMapper().map(
        const FourierMusicSpectrumFrame(
          lowPowerRatio: 0,
          midPowerRatio: 0,
          highPowerRatio: 1,
          centroid: 1,
          entropy: 1,
          flatness: 1,
          orientation: 0,
          anisotropy: 0,
          spectralFlux: 0,
        ),
      );

      final result = FourierMusicDecisionController().update(
        features,
        isBarBoundary: false,
      );

      expect(result.rhythmDensity, FourierMusicRhythmDensity.steady);
      expect(result.registerBand, FourierMusicRegisterBand.middle);
    });

    test('returns silence for invalid, non-finite, and empty spectra', () {
      const mapper = FourierMusicFeatureMapper();

      FourierMusicSpectrumFrame frame({
        double low = 0,
        bool isValid = true,
      }) =>
          FourierMusicSpectrumFrame(
            lowPowerRatio: low,
            midPowerRatio: 0,
            highPowerRatio: 0,
            centroid: 0.5,
            entropy: 0.5,
            flatness: 0.5,
            orientation: 0,
            anisotropy: 0.5,
            spectralFlux: 0.5,
            isValid: isValid,
          );

      for (final input in <FourierMusicSpectrumFrame>[
        frame(low: 1, isValid: false),
        frame(low: double.nan),
        frame(),
      ]) {
        final result = mapper.map(input);
        expect(result.isSilent, isTrue);
        expect(result.normalizedValues, everyElement(0.0));
        expect(result.stereoBias, 0);
      }
    });

    test('clamps hostile finite measurements before mapping', () {
      final result = const FourierMusicFeatureMapper().map(
        const FourierMusicSpectrumFrame(
          lowPowerRatio: -100,
          midPowerRatio: 20,
          highPowerRatio: 4,
          centroid: 100,
          entropy: -2,
          flatness: 8,
          orientation: -1000,
          anisotropy: 50,
          spectralFlux: -4,
        ),
      );

      expect(result.isSilent, isFalse);
      expect(result.normalizedValues, everyElement(inInclusiveRange(0.0, 1.0)));
      for (final value in result.normalizedValues) {
        expect(value.isFinite, isTrue);
      }
      expect(result.stereoBias, inInclusiveRange(-1.0, 1.0));
      expect(result.stereoBias.isFinite, isTrue);
      expect(result.orientation, inInclusiveRange(0.0, math.pi));
    });
  });
}
