import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/services/fourier_image_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FourierImageAnalyzer preprocessing', () {
    test('linearizes straight RGBA and applies alpha exactly once', () {
      final analyzer = FourierImageAnalyzer();
      final rgba = Uint8List.fromList(<int>[
        255,
        0,
        0,
        0,
        128,
        128,
        128,
        255,
        255,
        255,
        255,
        128,
      ]);

      final result = analyzer.analyze(
        rgba: rgba,
        width: 3,
        height: 1,
        removeDc: false,
        applyHann: false,
        alphaRepresentation: RgbaAlphaRepresentation.straight,
      );

      expect(result.scalarField.realAt(0), 0);
      expect(result.scalarField.realAt(1), closeTo(0.2158605001, 1e-9));
      expect(result.scalarField.realAt(2), closeTo(128 / 255, 1e-12));
      expect(result.features.alphaCoverage, closeTo(2 / 3, 1e-12));
    });

    test('area downsamples while preserving aspect ratio', () {
      final analyzer = FourierImageAnalyzer();
      final rgba = _opaqueGray(<int>[
        0,
        0,
        255,
        255,
        0,
        0,
        255,
        255,
      ]);

      final result = analyzer.analyze(
        rgba: rgba,
        width: 4,
        height: 2,
        maxDimension: 2,
        removeDc: false,
        applyHann: false,
      );

      expect(result.scalarField.width, 2);
      expect(result.scalarField.height, 1);
      expect(result.scalarField.realAt(0), closeTo(0, 1e-12));
      expect(result.scalarField.realAt(1), closeTo(1, 1e-12));
    });

    test('removes the capture mean before transforming', () {
      final result = FourierImageAnalyzer().analyze(
        rgba: _opaqueGray(<int>[0, 255]),
        width: 2,
        height: 1,
        removeDc: true,
        applyHann: false,
      );

      expect(result.scalarField.realAt(0), closeTo(-0.5, 1e-12));
      expect(result.scalarField.realAt(1), closeTo(0.5, 1e-12));
      expect(result.spectrum.realAt(0), closeTo(0, 1e-12));
    });

    test('applies a separable Hann window', () {
      final result = FourierImageAnalyzer().analyze(
        rgba: _opaqueGray(List<int>.filled(9, 255)),
        width: 3,
        height: 3,
        removeDc: false,
        applyHann: true,
      );

      expect(
        List<double>.generate(
            result.scalarField.length, result.scalarField.realAt),
        <double>[0, 0, 0, 0, 1, 0, 0, 0, 0],
      );
    });
  });

  group('FourierImageAnalyzer spectrum features', () {
    test('classifies checkerboard power as high radial detail', () {
      final result = FourierImageAnalyzer().analyze(
        rgba: _checkerboard(8, 8),
        width: 8,
        height: 8,
        removeDc: true,
        applyHann: false,
      );

      expect(result.features.lowPowerRatio, closeTo(0, 1e-10));
      expect(result.features.midPowerRatio, closeTo(0, 1e-10));
      expect(result.features.highPowerRatio, closeTo(1, 1e-10));
      expect(result.features.centroid, closeTo(1, 1e-10));
      expect(result.features.rolloff85, closeTo(1, 1e-10));
    });

    test('reports unit entropy and flatness for an impulse spectrum', () {
      final pixels = List<int>.filled(64, 0)..[19] = 255;
      final result = FourierImageAnalyzer().analyze(
        rgba: _opaqueGray(pixels),
        width: 8,
        height: 8,
        removeDc: false,
        applyHann: false,
      );

      expect(result.features.entropy, closeTo(1, 1e-12));
      expect(result.features.flatness, closeTo(1, 1e-12));
    });

    test('reports axial orientation for stripe variation', () {
      final analyzer = FourierImageAnalyzer();
      final verticalStripes = analyzer.analyze(
        rgba: _opaqueGray(<int>[
          for (var y = 0; y < 16; y++)
            for (var x = 0; x < 16; x++) x.isEven ? 0 : 255,
        ]),
        width: 16,
        height: 16,
        removeDc: true,
        applyHann: false,
      );
      final horizontalStripes = analyzer.analyze(
        rgba: _opaqueGray(<int>[
          for (var y = 0; y < 16; y++)
            for (var x = 0; x < 16; x++) y.isEven ? 0 : 255,
        ]),
        width: 16,
        height: 16,
        removeDc: true,
        applyHann: false,
      );

      expect(verticalStripes.features.dominantOrientation, closeTo(0, 1e-10));
      expect(horizontalStripes.features.dominantOrientation,
          closeTo(math.pi / 2, 1e-10));
      expect(verticalStripes.features.orientationStrength, closeTo(1, 1e-10));
      expect(horizontalStripes.features.orientationStrength, closeTo(1, 1e-10));
    });

    test('spectral flux is zero for the same frame and positive for a change',
        () {
      final analyzer = FourierImageAnalyzer();
      final first = analyzer.analyze(
        rgba: _checkerboard(8, 8),
        width: 8,
        height: 8,
        removeDc: true,
        applyHann: false,
      );
      final same = analyzer.analyze(
        rgba: _checkerboard(8, 8),
        width: 8,
        height: 8,
        removeDc: true,
        applyHann: false,
        previousPower: first.power,
      );
      final changed = analyzer.analyze(
        rgba: _opaqueGray(
            List<int>.generate(64, (index) => index == 9 ? 255 : 0)),
        width: 8,
        height: 8,
        removeDc: true,
        applyHann: false,
        previousPower: first.power,
      );

      expect(same.features.spectralFlux, closeTo(0, 1e-12));
      expect(changed.features.spectralFlux, inInclusiveRange(0.01, 1));
    });
  });
}

Uint8List _opaqueGray(List<int> values) => Uint8List.fromList(<int>[
      for (final value in values) ...<int>[value, value, value, 255],
    ]);

Uint8List _checkerboard(int width, int height) => _opaqueGray(<int>[
      for (var y = 0; y < height; y++)
        for (var x = 0; x < width; x++) (x + y).isEven ? 0 : 255,
    ]);
