import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/models/fourier_grid.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_transform_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FourierTransformService', () {
    test('transforms an impulse to a unitary constant spectrum', () {
      final service = FourierTransformService();
      final input = FourierGrid.real(
        width: 3,
        height: 2,
        values: Float64List.fromList(<double>[1, 0, 0, 0, 0, 0]),
      );

      final spectrum = service.forward(input);

      final expected = 1 / math.sqrt(6);
      for (var index = 0; index < spectrum.length; index++) {
        expect(spectrum.realAt(index), closeTo(expected, 1e-12));
        expect(spectrum.imaginaryAt(index), closeTo(0, 1e-12));
      }
    });

    test('inverse reconstructs an odd rectangular complex grid', () {
      final service = FourierTransformService();
      final packed = Float64List(9 * 27 * 2);
      for (var index = 0; index < 9 * 27; index++) {
        packed[index * 2] = (index % 11 - 5) / 7;
        packed[index * 2 + 1] = (index % 7 - 3) / 9;
      }
      final input = FourierGrid.complex(
        width: 9,
        height: 27,
        values: packed,
      );

      final reconstructed = service.inverse(service.forward(input));

      for (var index = 0; index < input.length; index++) {
        expect(
            reconstructed.realAt(index), closeTo(input.realAt(index), 1e-10));
        expect(
          reconstructed.imaginaryAt(index),
          closeTo(input.imaginaryAt(index), 1e-10),
        );
      }
    });

    test('fftShift centers zero frequency for odd rectangular grids', () {
      final service = FourierTransformService();
      final input = FourierGrid.real(
        width: 3,
        height: 3,
        values: Float64List.fromList(<double>[
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ]),
      );

      final shifted = service.fftShift(input);

      expect(
        List<double>.generate(shifted.length, shifted.realAt),
        <double>[8, 6, 7, 2, 0, 1, 5, 3, 4],
      );
    });

    test('transforms a constant field to only the DC bin', () {
      final service = FourierTransformService();
      final input = FourierGrid.real(
        width: 3,
        height: 2,
        values: Float64List.fromList(List<double>.filled(6, 2)),
      );

      final spectrum = service.forward(input);

      expect(spectrum.realAt(0), closeTo(2 * math.sqrt(6), 1e-12));
      for (var index = 1; index < spectrum.length; index++) {
        expect(spectrum.realAt(index), closeTo(0, 1e-12));
        expect(spectrum.imaginaryAt(index), closeTo(0, 1e-12));
      }
    });

    test('places horizontal and vertical sinusoid peaks on their axes', () {
      final service = FourierTransformService();
      const width = 9;
      const height = 27;
      final horizontal = Float64List(width * height);
      final vertical = Float64List(width * height);
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          horizontal[y * width + x] = math.cos(2 * math.pi * x / width);
          vertical[y * width + x] = math.cos(2 * math.pi * 2 * y / height);
        }
      }

      final horizontalSpectrum = service.forward(
        FourierGrid.real(width: width, height: height, values: horizontal),
      );
      final verticalSpectrum = service.forward(
        FourierGrid.real(width: width, height: height, values: vertical),
      );

      expect(_peakIndices(horizontalSpectrum), <int>[1, width - 1]);
      expect(
        _peakIndices(verticalSpectrum),
        <int>[2 * width, (height - 2) * width],
      );
    });

    test('preserves complex energy under the unitary transform', () {
      final service = FourierTransformService();
      final packed = Float64List(7 * 5 * 2);
      for (var index = 0; index < 35; index++) {
        packed[index * 2] = math.sin(index * 0.37);
        packed[index * 2 + 1] = math.cos(index * 0.19);
      }
      final input = FourierGrid.complex(width: 7, height: 5, values: packed);

      final spectrum = service.forward(input);

      expect(_energy(spectrum), closeTo(_energy(input), 1e-10));
    });

    test('rejects invalid dimensions, lengths, values, and excessive grids',
        () {
      expect(
        () => FourierGrid.real(width: 0, height: 1, values: Float64List(0)),
        throwsArgumentError,
      );
      expect(
        () => FourierGrid.real(width: 2, height: 2, values: Float64List(3)),
        throwsArgumentError,
      );
      expect(
        () => FourierGrid.real(
          width: 1,
          height: 1,
          values: Float64List.fromList(<double>[double.nan]),
        ),
        throwsArgumentError,
      );
      expect(
        () => FourierGrid.complex(
          width: FourierGrid.maximumElementCount + 1,
          height: 1,
          values: Float64List(0),
        ),
        throwsArgumentError,
      );
    });
  });
}

List<int> _peakIndices(FourierGrid grid) {
  var maximum = 0.0;
  final magnitudes = List<double>.generate(grid.length, (index) {
    final real = grid.realAt(index);
    final imaginary = grid.imaginaryAt(index);
    final magnitude = real * real + imaginary * imaginary;
    maximum = math.max(maximum, magnitude);
    return magnitude;
  });
  return <int>[
    for (var index = 0; index < magnitudes.length; index++)
      if (magnitudes[index] >= maximum * (1 - 1e-10)) index,
  ];
}

double _energy(FourierGrid grid) {
  var energy = 0.0;
  for (var index = 0; index < grid.length; index++) {
    final real = grid.realAt(index);
    final imaginary = grid.imaginaryAt(index);
    energy += real * real + imaginary * imaginary;
  }
  return energy;
}
