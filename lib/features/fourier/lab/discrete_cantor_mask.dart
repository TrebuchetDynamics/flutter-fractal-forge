import 'dart:collection';

import 'discrete_cantor_alphabet.dart';

/// Exact level-k discrete Cantor set generated from paired base-M digits.
final class DiscreteCantorMask {
  DiscreteCantorMask._({
    required this.alphabet,
    required this.recursion,
    required this.sideLength,
    required List<bool> values,
    required List<CantorCell> activeCoordinates,
  })  : values = UnmodifiableListView(values),
        activeCoordinates = UnmodifiableListView(activeCoordinates);

  factory DiscreteCantorMask.generate(
    DiscreteCantorAlphabet alphabet, {
    required int recursion,
    int maximumGridCells = 10000000,
  }) {
    if (recursion < 1) {
      throw ArgumentError.value(recursion, 'recursion', 'must be positive');
    }
    final sideLength = _integerPower(alphabet.base, recursion);
    final gridCells = sideLength * sideLength;
    if (gridCells > maximumGridCells) {
      throw StateError(
        'The requested $sideLength×$sideLength grid has $gridCells cells, '
        'exceeding the safe limit of $maximumGridCells.',
      );
    }

    final values = List<bool>.filled(gridCells, false);
    final active = <CantorCell>[];
    for (var y = 0; y < sideLength; y++) {
      for (var x = 0; x < sideLength; x++) {
        if (_hasAllowedDigits(alphabet, x, y, recursion)) {
          values[y * sideLength + x] = true;
          active.add(CantorCell(x, y));
        }
      }
    }
    return DiscreteCantorMask._(
      alphabet: alphabet,
      recursion: recursion,
      sideLength: sideLength,
      values: values,
      activeCoordinates: active,
    );
  }

  final DiscreteCantorAlphabet alphabet;
  final int recursion;
  final int sideLength;
  final List<bool> values;
  final List<CantorCell> activeCoordinates;

  int get cardinality => activeCoordinates.length;

  bool contains(int x, int y) {
    if (x < 0 || x >= sideLength || y < 0 || y >= sideLength) return false;
    return values[y * sideLength + x];
  }
}

bool _hasAllowedDigits(
  DiscreteCantorAlphabet alphabet,
  int x,
  int y,
  int recursion,
) {
  for (var digit = 0; digit < recursion; digit++) {
    if (!alphabet.cells
        .contains(CantorCell(x % alphabet.base, y % alphabet.base))) {
      return false;
    }
    x ~/= alphabet.base;
    y ~/= alphabet.base;
  }
  return true;
}

int _integerPower(int base, int exponent) {
  var value = 1;
  for (var index = 0; index < exponent; index++) {
    value *= base;
  }
  return value;
}
