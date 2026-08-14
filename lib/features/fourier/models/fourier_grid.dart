import 'dart:typed_data';

/// Immutable rectangular grid of packed complex Float64 values.
///
/// Values are stored row-major as `[real0, imaginary0, real1, imaginary1, ...]`.
final class FourierGrid {
  FourierGrid.complex({
    required this.width,
    required this.height,
    required Float64List values,
  }) : _values = Float64List.fromList(values) {
    _validateDimensions(width, height);
    if (values.length != width * height * 2) {
      throw ArgumentError.value(
        values.length,
        'values',
        'Expected ${width * height * 2} packed values.',
      );
    }
    _validateFinite(values);
  }

  factory FourierGrid.real({
    required int width,
    required int height,
    required Float64List values,
  }) {
    _validateDimensions(width, height);
    if (values.length != width * height) {
      throw ArgumentError.value(
        values.length,
        'values',
        'Expected ${width * height} real values.',
      );
    }
    _validateFinite(values);
    final packed = Float64List(values.length * 2);
    for (var index = 0; index < values.length; index++) {
      packed[index * 2] = values[index];
    }
    return FourierGrid.complex(
      width: width,
      height: height,
      values: packed,
    );
  }

  static const int maximumElementCount = 16 * 1024 * 1024;

  final int width;
  final int height;
  final Float64List _values;

  int get length => width * height;

  double realAt(int index) => _values[index * 2];

  double imaginaryAt(int index) => _values[index * 2 + 1];

  Float64List toPackedFloat64List() => Float64List.fromList(_values);

  static void _validateDimensions(int width, int height) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Fourier grid dimensions must be positive.');
    }
    if (width > maximumElementCount ~/ height) {
      throw ArgumentError(
        'Fourier grid exceeds the $maximumElementCount element limit.',
      );
    }
  }

  static void _validateFinite(List<double> values) {
    for (final value in values) {
      if (!value.isFinite) {
        throw ArgumentError.value(value, 'values', 'Values must be finite.');
      }
    }
  }
}
