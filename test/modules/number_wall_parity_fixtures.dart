import 'package:flutter_fractals/core/models/number_wall_model.dart';

const numberWallParityExpectedFingerprint = '196b53dc';

/// Independent determinant and edge-case fixtures shared by native and browser
/// parity runners. A mismatch throws explicitly, including in optimized JS.
NumberWallParityReport runNumberWallParityFixtures() {
  var count = 0;
  var fingerprint = 2166136261;

  void record(String identity, BigInt actual, BigInt expected) {
    if (actual != expected) {
      throw StateError('$identity: expected $expected, got $actual');
    }
    final fixture = '$identity|$actual|$expected;';
    for (final codeUnit in fixture.codeUnits) {
      fingerprint = (fingerprint * 31 + codeUnit) % 1000000007;
    }
    count++;
  }

  const prefixes = <NumberWallSequence, List<int>>{
    NumberWallSequence.rook: [0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1],
    NumberWallSequence.signedPagoda: [
      -1,
      0,
      1,
      0,
      -1,
      1,
      1,
      -1,
      -1,
      0,
      1,
      1,
      -1,
      0,
      1,
      -1
    ],
    NumberWallSequence.thueMorse: [0, 1, 1, 0, 1, 0, 0, 1],
    NumberWallSequence.rudinShapiro: [0, 0, 0, 1, 0, 0, 1, 0],
    NumberWallSequence.fibonacci: [0, 1, 1, 2, 3, 5, 8, 13],
    NumberWallSequence.squares: [0, 1, 4, 9, 16, 25, 36, 49],
  };
  for (final entry in prefixes.entries) {
    for (var index = 0; index < entry.value.length; index++) {
      final expected = BigInt.from(entry.value[index]);
      record(
        'prefix:${entry.key.name}:$index',
        entry.key.valueAt(index),
        expected,
      );
    }
  }

  for (final sequence in NumberWallSequence.values) {
    for (final prime in [2, 3, 5, 7, 11, 13]) {
      for (var row = 0; row <= 4; row++) {
        for (var column = row; column < row + 5; column++) {
          final matrix = [
            for (var i = 0; i <= row; i++)
              [
                for (var j = 0; j <= row; j++) sequence.valueAt(column + j - i),
              ],
          ];
          final modulus = BigInt.from(prime);
          final expected = _bareissDeterminant(matrix).modulo(modulus);
          final actual = NumberWallCell.determinant(
            sequence,
            row,
            column,
            modulus,
          );
          record(
            'det:${sequence.name}:$prime:$row:$column',
            actual,
            expected,
          );
        }
      }
    }
  }

  final five = BigInt.from(5);
  record(
    'matrix:row-swap',
    NumberWallCell.determinantMatrixMod([
      [BigInt.zero, BigInt.one],
      [BigInt.one, BigInt.zero],
    ], five),
    BigInt.from(4),
  );
  record(
    'matrix:singular',
    NumberWallCell.determinantMatrixMod([
      [BigInt.one, BigInt.from(2)],
      [BigInt.from(2), BigInt.from(4)],
    ], five),
    BigInt.zero,
  );
  record(
    'window:zero',
    NumberWallCell.determinant(
      NumberWallSequence.fibonacci,
      2,
      2,
      BigInt.two,
    ),
    BigInt.zero,
  );
  final fallbackExpected = NumberWallCell.determinant(
    NumberWallSequence.squares,
    2,
    4,
    five,
  );
  record(
    'cross:zero-denominator-fallback',
    NumberWallCell.crossOrDeterminant(
      sequence: NumberWallSequence.squares,
      row: 2,
      column: 4,
      prime: five,
      northWest: BigInt.one,
      west: BigInt.one,
      east: BigInt.one,
      denominator: BigInt.zero,
    ),
    fallbackExpected,
  );

  final hankel = [
    [BigInt.zero, -BigInt.one, BigInt.one],
    [BigInt.one, BigInt.zero, -BigInt.one],
    [BigInt.zero, BigInt.one, BigInt.zero],
  ];
  record(
    'hankel:published-sign',
    NumberWallCell.determinantMatrixMod(hankel, five),
    BigInt.one,
  );
  record(
    'hankel:reversed-sign',
    NumberWallCell.determinantMatrixMod(hankel.reversed.toList(), five),
    BigInt.from(4),
  );
  record(
    'cross:nonzero-denominator',
    NumberWallCell.crossOrDeterminant(
      sequence: NumberWallSequence.squares,
      row: 2,
      column: 4,
      prime: five,
      northWest: BigInt.one,
      west: BigInt.from(2),
      east: BigInt.from(4),
      denominator: BigInt.one,
    ),
    fallbackExpected,
  );

  return NumberWallParityReport(
      count, fingerprint.toRadixString(16).padLeft(8, '0'));
}

class NumberWallParityReport {
  const NumberWallParityReport(this.fixtureCount, this.fingerprint);

  final int fixtureCount;
  final String fingerprint;
}

BigInt _bareissDeterminant(List<List<BigInt>> input) {
  final matrix = input.map((row) => row.toList()).toList();
  var sign = BigInt.one;
  var previous = BigInt.one;
  for (var pivotIndex = 0; pivotIndex < matrix.length - 1; pivotIndex++) {
    if (matrix[pivotIndex][pivotIndex] == BigInt.zero) {
      var swapIndex = -1;
      for (var row = pivotIndex + 1; row < matrix.length; row++) {
        if (matrix[row][pivotIndex] != BigInt.zero) {
          swapIndex = row;
          break;
        }
      }
      if (swapIndex < 0) return BigInt.zero;
      final row = matrix[pivotIndex];
      matrix[pivotIndex] = matrix[swapIndex];
      matrix[swapIndex] = row;
      sign = -sign;
    }
    final pivot = matrix[pivotIndex][pivotIndex];
    for (var row = pivotIndex + 1; row < matrix.length; row++) {
      for (var column = pivotIndex + 1; column < matrix.length; column++) {
        matrix[row][column] = (matrix[row][column] * pivot -
                matrix[row][pivotIndex] * matrix[pivotIndex][column]) ~/
            previous;
      }
    }
    for (var row = pivotIndex + 1; row < matrix.length; row++) {
      matrix[row][pivotIndex] = BigInt.zero;
    }
    previous = pivot;
  }
  return sign * matrix.last.last;
}

extension on BigInt {
  BigInt modulo(BigInt modulus) {
    final remainder = this % modulus;
    return remainder < BigInt.zero ? remainder + modulus : remainder;
  }
}
