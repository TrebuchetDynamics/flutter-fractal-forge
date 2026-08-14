import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter_fractals/features/fourier/models/fourier_grid.dart';

/// Deterministic unitary two-dimensional discrete Fourier transforms.
final class FourierTransformService {
  final Map<int, FFT> _plans = <int, FFT>{};

  FourierGrid forward(FourierGrid input) => _transform(input, inverse: false);

  FourierGrid inverse(FourierGrid input) => _transform(input, inverse: true);

  /// Returns a display-oriented copy with the zero-frequency bin centered.
  FourierGrid fftShift(FourierGrid input) {
    final source = input.toPackedFloat64List();
    final shifted = Float64List(source.length);
    final sourceOffsetX = (input.width + 1) ~/ 2;
    final sourceOffsetY = (input.height + 1) ~/ 2;
    for (var y = 0; y < input.height; y++) {
      final sourceY = (y + sourceOffsetY) % input.height;
      for (var x = 0; x < input.width; x++) {
        final sourceX = (x + sourceOffsetX) % input.width;
        final targetIndex = (y * input.width + x) * 2;
        final sourceIndex = (sourceY * input.width + sourceX) * 2;
        shifted[targetIndex] = source[sourceIndex];
        shifted[targetIndex + 1] = source[sourceIndex + 1];
      }
    }
    return FourierGrid.complex(
      width: input.width,
      height: input.height,
      values: shifted,
    );
  }

  FourierGrid _transform(FourierGrid input, {required bool inverse}) {
    final packed = input.toPackedFloat64List();
    final rows = _plans.putIfAbsent(input.width, () => FFT(input.width));
    final columns = _plans.putIfAbsent(input.height, () => FFT(input.height));

    final row = Float64x2List(input.width);
    for (var y = 0; y < input.height; y++) {
      for (var x = 0; x < input.width; x++) {
        final packedIndex = (y * input.width + x) * 2;
        row[x] = Float64x2(
          packed[packedIndex],
          packed[packedIndex + 1],
        );
      }
      if (inverse) {
        rows.inPlaceInverseFft(row);
      } else {
        rows.inPlaceFft(row);
      }
      for (var x = 0; x < input.width; x++) {
        final packedIndex = (y * input.width + x) * 2;
        packed[packedIndex] = row[x].x;
        packed[packedIndex + 1] = row[x].y;
      }
    }

    final column = Float64x2List(input.height);
    for (var x = 0; x < input.width; x++) {
      for (var y = 0; y < input.height; y++) {
        final packedIndex = (y * input.width + x) * 2;
        column[y] = Float64x2(
          packed[packedIndex],
          packed[packedIndex + 1],
        );
      }
      if (inverse) {
        columns.inPlaceInverseFft(column);
      } else {
        columns.inPlaceFft(column);
      }
      for (var y = 0; y < input.height; y++) {
        final packedIndex = (y * input.width + x) * 2;
        packed[packedIndex] = column[y].x;
        packed[packedIndex + 1] = column[y].y;
      }
    }

    final unitaryScale = inverse
        ? math.sqrt(input.length.toDouble())
        : 1 / math.sqrt(input.length.toDouble());
    for (var index = 0; index < packed.length; index++) {
      packed[index] *= unitaryScale;
    }

    return FourierGrid.complex(
      width: input.width,
      height: input.height,
      values: packed,
    );
  }
}
