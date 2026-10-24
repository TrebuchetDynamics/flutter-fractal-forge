/// The six sequence families pinned by the Number Walls specification.
enum NumberWallSequence {
  signedPagoda,
  rook,
  thueMorse,
  rudinShapiro,
  fibonacci,
  squares;

  /// Exact integer sequence value at [n]. No modular reduction is performed.
  BigInt valueAt(int n) {
    switch (this) {
      case NumberWallSequence.rook:
        if (n == 0) return BigInt.zero;
        return BigInt.from(n < 0 ? 1 - rookValue(-n) : rookValue(n));
      case NumberWallSequence.signedPagoda:
        return NumberWallSequence.rook.valueAt(n + 1) -
            NumberWallSequence.rook.valueAt(n - 1);
      case NumberWallSequence.thueMorse:
        if (n < 0) throw ArgumentError.value(n, 'n', 'Must be nonnegative');
        var value = n;
        var parity = 0;
        while (value != 0) {
          parity ^= value & 1;
          value >>= 1;
        }
        return BigInt.from(parity);
      case NumberWallSequence.rudinShapiro:
        if (n < 0) throw ArgumentError.value(n, 'n', 'Must be nonnegative');
        var value = n;
        var pairs = 0;
        while (value > 1) {
          if ((value & 3) == 3) pairs++;
          value >>= 1;
        }
        return BigInt.from(pairs & 1);
      case NumberWallSequence.fibonacci:
        if (n < 0) throw ArgumentError.value(n, 'n', 'Must be nonnegative');
        return _fibonacci(n).$1;
      case NumberWallSequence.squares:
        final value = BigInt.from(n);
        return value * value;
    }
  }

  static int rookValue(int n) {
    if (n == 0) return 0;
    var odd = n;
    while ((odd & 1) == 0) {
      odd >>= 1;
    }
    return (odd ~/ 2) & 1;
  }

  BigInt residueAt(int n, BigInt prime) {
    if (prime < BigInt.two) throw ArgumentError.value(prime, 'prime');
    if (this == NumberWallSequence.fibonacci) {
      if (n < 0) throw ArgumentError.value(n, 'n', 'Must be nonnegative');
      return _fibonacciMod(n, prime).$1;
    }
    return valueAt(n).modulo(prime);
  }

  static (BigInt, BigInt) _fibonacciMod(int n, BigInt modulus) {
    if (n == 0) return (BigInt.zero, BigInt.one.modulo(modulus));
    final (a, b) = _fibonacciMod(n >> 1, modulus);
    final c = (a * ((b * BigInt.two - a).modulo(modulus))).modulo(modulus);
    final d = (a * a + b * b).modulo(modulus);
    return n.isEven ? (c, d) : (d, (c + d).modulo(modulus));
  }

  static (BigInt, BigInt) _fibonacci(int n) {
    if (n == 0) return (BigInt.zero, BigInt.one);
    final (a, b) = _fibonacci(n >> 1);
    final c = a * ((b << 1) - a);
    final d = a * a + b * b;
    return n.isEven ? (c, d) : (d, c + d);
  }
}

enum NumberWallPrimeStatus {
  verifiedPrime,
  composite,
  invalid,
  unverified,
  cancelled,
}

class NumberWallPrimeCheck {
  const NumberWallPrimeCheck(this.status, {this.prime, this.divisions = 0});

  final NumberWallPrimeStatus status;
  final BigInt? prime;
  final int divisions;
}

/// Exact decimal parsing and cancellable trial division; no probable-prime
/// result is ever promoted to verified.
class NumberWallPrimeValidator {
  static const maxDecimalDigits = 256;
  static const defaultMaxTrialDivisions = 100000;
  static const _smallPrimes = [
    2,
    3,
    5,
    7,
    11,
    13,
    17,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
  ];

  static Future<NumberWallPrimeCheck> validate(
    String input, {
    bool Function()? isCancelled,
    Future<void> Function()? yieldChunk,
    int maxTrialDivisions = defaultMaxTrialDivisions,
  }) async {
    final digits = input;
    if (digits.isEmpty ||
        digits.length > maxDecimalDigits ||
        !RegExp(r'^[0-9]+$').hasMatch(digits)) {
      return const NumberWallPrimeCheck(NumberWallPrimeStatus.invalid);
    }
    final value = BigInt.tryParse(digits);
    if (value == null || value < BigInt.two) {
      return const NumberWallPrimeCheck(NumberWallPrimeStatus.invalid);
    }
    for (final prime in _smallPrimes) {
      if (isCancelled?.call() ?? false) {
        return const NumberWallPrimeCheck(NumberWallPrimeStatus.cancelled);
      }
      final p = BigInt.from(prime);
      if (value == p) {
        return NumberWallPrimeCheck(NumberWallPrimeStatus.verifiedPrime,
            prime: value);
      }
      if (value % p == BigInt.zero) {
        return const NumberWallPrimeCheck(NumberWallPrimeStatus.composite);
      }
    }
    var divisions = 0;
    final root = _integerSqrt(value);
    var candidate = 53;
    while (BigInt.from(candidate) <= root) {
      if (isCancelled?.call() ?? false) {
        return NumberWallPrimeCheck(NumberWallPrimeStatus.cancelled,
            divisions: divisions);
      }
      if (divisions >= maxTrialDivisions) {
        return NumberWallPrimeCheck(NumberWallPrimeStatus.unverified,
            divisions: divisions);
      }
      if (value % BigInt.from(candidate) == BigInt.zero) {
        return NumberWallPrimeCheck(NumberWallPrimeStatus.composite,
            divisions: divisions + 1);
      }
      divisions++;
      candidate += 2;
      if (divisions % 1024 == 0) {
        await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
      }
    }
    if (isCancelled?.call() ?? false) {
      return NumberWallPrimeCheck(NumberWallPrimeStatus.cancelled,
          divisions: divisions);
    }
    return NumberWallPrimeCheck(NumberWallPrimeStatus.verifiedPrime,
        prime: value, divisions: divisions);
  }

  static BigInt _integerSqrt(BigInt value) {
    if (value < BigInt.two) return value;
    var x = BigInt.one << ((value.bitLength + 1) >> 1);
    while (true) {
      final next = (x + value ~/ x) >> 1;
      if (next >= x) return x;
      x = next;
    }
  }
}

class NumberWallCell {
  const NumberWallCell._();

  static BigInt determinant(
    NumberWallSequence sequence,
    int row,
    int column,
    BigInt prime,
  ) {
    if (row < 0) throw ArgumentError.value(row, 'row');
    if (prime < BigInt.two) throw ArgumentError.value(prime, 'prime');
    final matrix = [
      for (var i = 0; i <= row; i++)
        [
          for (var j = 0; j <= row; j++)
            sequence.residueAt(column + j - i, prime),
        ],
    ];
    return determinantMatrixMod(matrix, prime);
  }

  /// Pivoted Gaussian elimination over the field modulo [prime].
  static BigInt determinantMatrixMod(List<List<BigInt>> matrix, BigInt prime) {
    if (prime < BigInt.two) throw ArgumentError.value(prime, 'prime');
    final n = matrix.length;
    if (matrix.any((row) => row.length != n)) {
      throw ArgumentError('Expected a square matrix');
    }
    if (n == 0) return BigInt.one;
    final a = matrix
        .map((row) => row.map((value) => value.modulo(prime)).toList())
        .toList();
    var determinant = BigInt.one;
    for (var column = 0; column < n; column++) {
      var pivot = column;
      while (pivot < n && a[pivot][column] == BigInt.zero) {
        pivot++;
      }
      if (pivot == n) return BigInt.zero;
      if (pivot != column) {
        final row = a[pivot];
        a[pivot] = a[column];
        a[column] = row;
        determinant = -determinant;
      }
      final pivotValue = a[column][column];
      determinant = (determinant * pivotValue).modulo(prime);
      final inverse = _inverse(pivotValue, prime);
      for (var row = column + 1; row < n; row++) {
        if (a[row][column] == BigInt.zero) continue;
        final factor = (a[row][column] * inverse).modulo(prime);
        for (var j = column; j < n; j++) {
          a[row][j] = (a[row][j] - factor * a[column][j]).modulo(prime);
        }
      }
    }
    return determinant.modulo(prime);
  }

  static Future<BigInt?> determinantMatrixModAsync(
    List<List<BigInt>> matrix,
    BigInt prime, {
    bool Function()? isCancelled,
    Future<void> Function()? yieldChunk,
  }) async {
    if (prime < BigInt.two) throw ArgumentError.value(prime, 'prime');
    final n = matrix.length;
    if (matrix.any((row) => row.length != n)) {
      throw ArgumentError('Expected a square matrix');
    }
    // Generated sequence support already contains canonical field residues.
    // Preserve those immutable BigInts instead of repeating costly division
    // for every matrix entry; arbitrary signed inputs still reduce exactly.
    final a = matrix
        .map((row) => row
            .map((value) => !value.isNegative && value < prime
                ? value
                : value.modulo(prime))
            .toList())
        .toList();
    var determinant = BigInt.one;
    var probes = 0;
    final clock = Stopwatch()..start();
    Future<bool> checkpoint() async {
      if (isCancelled?.call() ?? false) return true;
      if (probes >= 1024 || clock.elapsedMilliseconds >= 8) {
        await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
        probes = 0;
        clock.reset();
        return isCancelled?.call() ?? false;
      }
      return false;
    }

    for (var column = 0; column < n; column++) {
      if (isCancelled?.call() ?? false) return null;
      var pivot = column;
      while (pivot < n && a[pivot][column] == BigInt.zero) {
        pivot++;
      }
      if (pivot == n) return BigInt.zero;
      if (pivot != column) {
        final row = a[pivot];
        a[pivot] = a[column];
        a[column] = row;
        determinant = -determinant;
      }
      final pivotValue = a[column][column];
      determinant = (determinant * pivotValue).modulo(prime);
      final inverse = _inverse(pivotValue, prime);
      for (var row = column + 1; row < n; row++) {
        if (a[row][column] != BigInt.zero) {
          final factor = (a[row][column] * inverse).modulo(prime);
          for (var j = column; j < n; j++) {
            a[row][j] = (a[row][j] - factor * a[column][j]).modulo(prime);
            probes++;
            // Keep scalar field operations synchronous inside each bounded
            // batch. Awaiting a completed Future per multiplication makes the
            // default wall spend most of its time scheduling microtasks.
            if ((probes >= 1024 || clock.elapsedMilliseconds >= 8) &&
                await checkpoint()) return null;
          }
        }
      }
    }
    if (isCancelled?.call() ?? false) return null;
    return determinant.modulo(prime);
  }

  /// Uses the Desnanot–Jacobi cross rule only when its denominator is a unit;
  /// otherwise it computes the determinant directly.
  static BigInt crossOrDeterminant({
    required NumberWallSequence sequence,
    required int row,
    required int column,
    required BigInt prime,
    required BigInt northWest,
    required BigInt west,
    required BigInt east,
    required BigInt denominator,
  }) {
    final d = denominator.modulo(prime);
    if (d != BigInt.zero) {
      final numerator = (northWest * northWest - west * east).modulo(prime);
      return (numerator * _inverse(d, prime)).modulo(prime);
    }
    return determinant(sequence, row, column, prime);
  }

  static BigInt _inverse(BigInt value, BigInt modulus) {
    var oldR = value;
    var r = modulus;
    var oldS = BigInt.one;
    var s = BigInt.zero;
    while (r != BigInt.zero) {
      final quotient = oldR ~/ r;
      (oldR, r) = (r, oldR - quotient * r);
      (oldS, s) = (s, oldS - quotient * s);
    }
    if (oldR != BigInt.one) throw ArgumentError('Modulus is not prime');
    return oldS.modulo(modulus);
  }
}

class NumberWallGrid {
  NumberWallGrid._({
    required this.sequence,
    required this.prime,
    required this.rowCount,
    required this.columnStart,
    required this.columnCount,
    required this.support,
    required List<List<BigInt>> values,
  }) : values = List.unmodifiable(values.map(List<BigInt>.unmodifiable));

  final NumberWallSequence sequence;
  final BigInt prime;
  final int rowCount;
  final int columnStart;
  final int columnCount;
  final ({int start, int end}) support;
  final List<List<BigInt>> values;

  static ({int start, int end}) requiredSupport({
    required int rowCount,
    required int columnStart,
    required int columnCount,
    required NumberWallSequence sequence,
  }) {
    if (rowCount < 1 || columnCount < 1) {
      throw ArgumentError('Grid dimensions must be positive');
    }
    final halo =
        rowCount - 1 + (sequence == NumberWallSequence.signedPagoda ? 1 : 0);
    return (
      start: columnStart - halo,
      end: columnStart + columnCount - 1 + halo
    );
  }

  static Future<NumberWallGrid?> generate({
    required NumberWallSequence sequence,
    required BigInt prime,
    required int rowCount,
    required int columnStart,
    required int columnCount,
    bool Function()? isCancelled,
    Future<void> Function()? yieldChunk,
  }) async {
    if (prime < BigInt.two) throw ArgumentError.value(prime, 'prime');
    if (rowCount < 1 || rowCount > 64 || columnCount < 1 || columnCount > 256) {
      throw ArgumentError('Grid dimensions exceed the supported bounds');
    }
    if (columnStart < rowCount - 1 || columnStart > 1000000) {
      throw ArgumentError.value(
          columnStart, 'columnStart', 'Must be in rowCount-1..1000000');
    }
    final support = requiredSupport(
      rowCount: rowCount,
      columnStart: columnStart,
      columnCount: columnCount,
      sequence: sequence,
    );
    var probes = 0;
    final sequenceValues = <int, BigInt>{};
    for (var n = support.start; n <= support.end; n++) {
      if (isCancelled?.call() ?? false) return null;
      sequenceValues[n] = sequence.residueAt(n, prime);
      if (++probes == 1024) {
        await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
        probes = 0;
      }
    }
    final rows = <List<BigInt>>[];
    for (var row = 0; row < rowCount; row++) {
      final cells = <BigInt>[];
      for (var offset = 0; offset < columnCount; offset++) {
        if (isCancelled?.call() ?? false) return null;
        final column = columnStart + offset;
        final matrix = [
          for (var i = 0; i <= row; i++)
            [for (var j = 0; j <= row; j++) sequenceValues[column + j - i]!],
        ];
        final determinant = await NumberWallCell.determinantMatrixModAsync(
          matrix,
          prime,
          isCancelled: isCancelled,
          yieldChunk: yieldChunk,
        );
        if (determinant == null) return null;
        cells.add(determinant);
      }
      rows.add(cells);
      await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
    }
    if (isCancelled?.call() ?? false) return null;
    return NumberWallGrid._(
      sequence: sequence,
      prime: prime,
      rowCount: rowCount,
      columnStart: columnStart,
      columnCount: columnCount,
      support: support,
      values: rows,
    );
  }
}

extension on BigInt {
  BigInt modulo(BigInt modulus) {
    final remainder = this % modulus;
    return remainder < BigInt.zero ? remainder + modulus : remainder;
  }
}
