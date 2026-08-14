import 'dart:collection';
import 'dart:math' as math;

/// One allowed paired digit `(x, y)` in `Z_M²`.
final class CantorCell {
  const CantorCell(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is CantorCell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'CantorCell($x, $y)';
}

/// A proper, non-empty alphabet in `Z_M²`.
final class DiscreteCantorAlphabet {
  DiscreteCantorAlphabet({required this.base, required Set<CantorCell> cells})
      : cells = UnmodifiableSetView(Set<CantorCell>.of(cells)) {
    if (base < 2) {
      throw ArgumentError.value(base, 'base', 'must be at least 2');
    }
    if (cells.isEmpty) {
      throw ArgumentError.value(cells, 'cells', 'must not be empty');
    }
    for (final cell in cells) {
      if (cell.x < 0 || cell.x >= base || cell.y < 0 || cell.y >= base) {
        throw ArgumentError.value(
          cell,
          'cells',
          'coordinates must lie in 0..${base - 1}',
        );
      }
    }
    if (cells.length == base * base) {
      throw ArgumentError.value(cells, 'cells', 'must be a proper alphabet');
    }
  }

  factory DiscreteCantorAlphabet.product({
    required int base,
    required Set<int> xDigits,
    required Set<int> yDigits,
  }) =>
      DiscreteCantorAlphabet(
        base: base,
        cells: {
          for (final y in yDigits)
            for (final x in xDigits) CantorCell(x, y),
        },
      );

  factory DiscreteCantorAlphabet.sierpinski({required int base}) {
    if (base.isEven) {
      throw ArgumentError.value(base, 'base', 'must be odd');
    }
    final center = base ~/ 2;
    return DiscreteCantorAlphabet(
      base: base,
      cells: {
        for (var y = 0; y < base; y++)
          for (var x = 0; x < base; x++)
            if (x != center || y != center) CantorCell(x, y),
      },
    );
  }

  factory DiscreteCantorAlphabet.verticalLine({
    required int base,
    required int x,
  }) =>
      DiscreteCantorAlphabet(
        base: base,
        cells: {for (var y = 0; y < base; y++) CantorCell(x, y)},
      );

  factory DiscreteCantorAlphabet.horizontalLine({
    required int base,
    required int y,
  }) =>
      DiscreteCantorAlphabet(
        base: base,
        cells: {for (var x = 0; x < base; x++) CantorCell(x, y)},
      );

  final int base;
  final Set<CantorCell> cells;

  /// Hausdorff/similarity dimension `log_M |A|` of the symbolic alphabet.
  double get dimension => math.log(cells.length) / math.log(base);
}

/// Exponent supplied by the exact finite Hilbert–Schmidt cardinality bound.
double trivialHilbertSchmidtExponent(
  DiscreteCantorAlphabet spatial,
  DiscreteCantorAlphabet spectral,
) =>
    math.max(0, 1 - (spatial.dimension + spectral.dimension) / 2);
