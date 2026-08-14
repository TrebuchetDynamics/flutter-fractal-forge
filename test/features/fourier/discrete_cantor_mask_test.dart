import 'dart:math' as math;

import 'package:flutter_fractals/features/fourier/lab/discrete_cantor_alphabet.dart';
import 'package:flutter_fractals/features/fourier/lab/discrete_cantor_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiscreteCantorMask', () {
    test('uses paired base-M digits for exact membership', () {
      final alphabet = DiscreteCantorAlphabet(
        base: 3,
        cells: {
          CantorCell(0, 0),
          CantorCell(0, 2),
          CantorCell(2, 0),
          CantorCell(2, 2),
        },
      );

      final mask = DiscreteCantorMask.generate(alphabet, recursion: 2);

      expect(mask.sideLength, 9);
      expect(mask.cardinality, 16);
      expect(mask.contains(2, 6), isTrue); // digits (2,0), (0,2)
      expect(mask.contains(1, 6), isFalse); // digit (1,0) is absent
      expect(mask.values.where((value) => value).length, 16);
    });

    test('cardinality is |alphabet|^k for bases 2, 3, and 5', () {
      for (final base in [2, 3, 5]) {
        final alphabet = DiscreteCantorAlphabet(
          base: base,
          cells: {const CantorCell(0, 0), const CantorCell(1, 1)},
        );
        for (var recursion = 1; recursion <= 4; recursion++) {
          final mask = DiscreteCantorMask.generate(
            alphabet,
            recursion: recursion,
          );
          expect(mask.cardinality, math.pow(2, recursion).toInt());
          expect(mask.sideLength, math.pow(base, recursion).toInt());
        }
      }
    });

    test('generates Sierpinski and axis-line alphabets exactly', () {
      final sierpinski = DiscreteCantorAlphabet.sierpinski(base: 3);
      final vertical = DiscreteCantorAlphabet.verticalLine(base: 3, x: 1);
      final horizontal = DiscreteCantorAlphabet.horizontalLine(base: 3, y: 2);

      expect(DiscreteCantorMask.generate(sierpinski, recursion: 2).cardinality,
          64);
      final verticalMask = DiscreteCantorMask.generate(vertical, recursion: 2);
      final horizontalMask =
          DiscreteCantorMask.generate(horizontal, recursion: 2);
      expect(verticalMask.cardinality, 9);
      expect(horizontalMask.cardinality, 9);
      expect(
          verticalMask.activeCoordinates, everyElement((cell) => cell.x == 4));
      expect(horizontalMask.activeCoordinates,
          everyElement((cell) => cell.y == 8));
    });

    test('reports dimension and Hilbert-Schmidt exponent baseline', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );
      final line = DiscreteCantorAlphabet.verticalLine(base: 3, x: 0);

      expect(dust.dimension, closeTo(math.log(4) / math.log(3), 1e-12));
      expect(
        trivialHilbertSchmidtExponent(dust, line),
        closeTo(
          math.max(0, 1 - (dust.dimension + line.dimension) / 2),
          1e-12,
        ),
      );
    });

    test('rejects empty, full, out-of-range, and unsafe states', () {
      expect(
        () => DiscreteCantorAlphabet(base: 3, cells: const {}),
        throwsArgumentError,
      );
      expect(
        () => DiscreteCantorAlphabet(
          base: 2,
          cells: {
            for (var y = 0; y < 2; y++)
              for (var x = 0; x < 2; x++) CantorCell(x, y),
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => DiscreteCantorAlphabet(
          base: 3,
          cells: {CantorCell(3, 0)},
        ),
        throwsArgumentError,
      );
      final alphabet = DiscreteCantorAlphabet(
        base: 5,
        cells: {CantorCell(0, 0)},
      );
      expect(
        () => DiscreteCantorMask.generate(
          alphabet,
          recursion: 4,
          maximumGridCells: 1000,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
