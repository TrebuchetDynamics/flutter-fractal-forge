import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fftea dependency spike', () {
    for (final size in <int>[9, 27, 81, 128]) {
      test('reconstructs and preserves energy at length $size', () {
        final input = Float64x2List(size);
        for (var i = 0; i < size; i++) {
          input[i] = Float64x2(
            math.sin(i * 0.37) + 0.25 * math.cos(i * 0.11),
            math.cos(i * 0.23) - 0.15 * math.sin(i * 0.41),
          );
        }
        final original = Float64x2List.fromList(input);
        final originalEnergy = _energy(input);

        final fft = FFT(size);
        fft.inPlaceFft(input);
        final transformedEnergy = _energy(input) / size;
        fft.inPlaceInverseFft(input);

        expect(
          transformedEnergy,
          closeTo(originalEnergy, math.max(1e-9, originalEnergy * 1e-10)),
        );
        for (var i = 0; i < size; i++) {
          expect(input[i].x, closeTo(original[i].x, 1e-9));
          expect(input[i].y, closeTo(original[i].y, 1e-9));
        }
      });
    }
  });
}

double _energy(Float64x2List values) {
  var result = 0.0;
  for (final value in values) {
    result += value.x * value.x + value.y * value.y;
  }
  return result;
}
