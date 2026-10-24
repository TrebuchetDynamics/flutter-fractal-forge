import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';

import 'number_wall_parity_fixtures.dart';

void main() {
  group('number-wall sequences', () {
    test('matches the pinned Rook and signed Pagoda prefixes', () {
      expect(
        List.generate(16, (n) => NumberWallSequence.rook.valueAt(n)),
        [0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1]
            .map(BigInt.from)
            .toList(),
      );
      expect(
        List.generate(16, (n) => NumberWallSequence.signedPagoda.valueAt(n)),
        [-1, 0, 1, 0, -1, 1, 1, -1, -1, 0, 1, 1, -1, 0, 1, -1]
            .map(BigInt.from)
            .toList(),
      );
    });

    test('defines all six sequences exactly at initial indices', () {
      expect(List.generate(8, (n) => NumberWallSequence.thueMorse.valueAt(n)),
          [0, 1, 1, 0, 1, 0, 0, 1].map(BigInt.from).toList());
      expect(
          List.generate(8, (n) => NumberWallSequence.rudinShapiro.valueAt(n)),
          [0, 0, 0, 1, 0, 0, 1, 0].map(BigInt.from).toList());
      expect(List.generate(8, (n) => NumberWallSequence.fibonacci.valueAt(n)),
          [0, 1, 1, 2, 3, 5, 8, 13].map(BigInt.from).toList());
      expect(List.generate(8, (n) => NumberWallSequence.squares.valueAt(n)),
          [0, 1, 4, 9, 16, 25, 36, 49].map(BigInt.from).toList());
      expect(
        () => NumberWallSequence.fibonacci.valueAt(-1),
        throwsArgumentError,
      );
    });
  });

  group('exact modular determinants', () {
    test(
        'matches independent integer determinant fixtures across the shared corpus',
        () {
      final report = runNumberWallParityFixtures();
      expect(report.fixtureCount, 971);
      expect(report.fingerprint, numberWallParityExpectedFingerprint);
    });

    test(
        'handles row swaps, singular matrices, zeros, and a zero cross denominator',
        () {
      expect(
        NumberWallCell.determinantMatrixMod([
          [BigInt.zero, BigInt.one],
          [BigInt.one, BigInt.zero]
        ], BigInt.from(5)),
        BigInt.from(4),
      );
      expect(
          NumberWallCell.determinantMatrixMod(
            [
              [BigInt.one, BigInt.from(2)],
              [BigInt.from(2), BigInt.from(4)]
            ],
            BigInt.from(5),
          ),
          BigInt.zero);
      expect(
          NumberWallCell.determinant(
              NumberWallSequence.fibonacci, 2, 2, BigInt.from(2)),
          BigInt.zero);
      expect(
          NumberWallCell.crossOrDeterminant(
            sequence: NumberWallSequence.squares,
            row: 2,
            column: 4,
            prime: BigInt.from(5),
            northWest: BigInt.one,
            west: BigInt.one,
            east: BigInt.one,
            denominator: BigInt.zero,
          ),
          NumberWallCell.determinant(
              NumberWallSequence.squares, 2, 4, BigInt.from(5)));
    });

    test('uses published Toeplitz determinant signs for odd primes', () async {
      final matrix = [
        [BigInt.zero, -BigInt.one, BigInt.one],
        [BigInt.one, BigInt.zero, -BigInt.one],
        [BigInt.zero, BigInt.one, BigInt.zero],
      ];
      expect(NumberWallCell.determinantMatrixMod(matrix, BigInt.from(5)),
          BigInt.one);
      for (final lift in [-5, 0, 5]) {
        final lifted = [
          for (final row in matrix)
            [for (final value in row) value + BigInt.from(lift)]
        ];
        expect(
            await NumberWallCell.determinantMatrixModAsync(
                lifted, BigInt.from(5)),
            BigInt.one,
            reason: 'canonical, negative and oversized entries agree modulo5');
      }
      expect(
        NumberWallCell.determinantMatrixMod(
          matrix.reversed.toList(),
          BigInt.from(5),
        ),
        BigInt.from(4),
      );
      expect(
        NumberWallCell.crossOrDeterminant(
          sequence: NumberWallSequence.squares,
          row: 2,
          column: 4,
          prime: BigInt.from(5),
          northWest: BigInt.one,
          west: BigInt.from(2),
          east: BigInt.from(4),
          denominator: BigInt.one,
        ),
        NumberWallCell.determinant(
            NumberWallSequence.squares, 2, 4, BigInt.from(5)),
      );
    });
  });

  group('prime validation', () {
    test('accepts exact custom primes and rejects malformed/composite inputs',
        () async {
      final prime = await NumberWallPrimeValidator.validate('97');
      expect(prime.status, NumberWallPrimeStatus.verifiedPrime);
      expect(prime.prime, BigInt.from(97));
      for (final input in ['0', '1', '-7', ' 7', '7x']) {
        expect((await NumberWallPrimeValidator.validate(input)).status,
            NumberWallPrimeStatus.invalid,
            reason: input);
      }
      for (final input in ['561', '1105']) {
        expect((await NumberWallPrimeValidator.validate(input)).status,
            NumberWallPrimeStatus.composite,
            reason: input);
      }
      expect((await NumberWallPrimeValidator.validate('9' * 257)).status,
          NumberWallPrimeStatus.invalid);
    });

    test('unfinished and cancelled checks are never reported prime', () async {
      final huge = '170141183460469231731687303715884105727';
      final unfinished = await NumberWallPrimeValidator.validate(
        huge,
        maxTrialDivisions: 1,
      );
      expect(unfinished.status, NumberWallPrimeStatus.unverified);
      final cancelled = await NumberWallPrimeValidator.validate(
        '1000003',
        isCancelled: () => true,
      );
      expect(cancelled.status, NumberWallPrimeStatus.cancelled);
    });
  });

  test(
      'requires and generates the sequence support halo; cancellation publishes nothing',
      () async {
    expect(
        NumberWallGrid.requiredSupport(
          rowCount: 4,
          columnStart: 3,
          columnCount: 5,
          sequence: NumberWallSequence.signedPagoda,
        ),
        (start: -1, end: 11));
    final grid = await NumberWallGrid.generate(
      sequence: NumberWallSequence.fibonacci,
      prime: BigInt.from(7),
      rowCount: 4,
      columnStart: 3,
      columnCount: 5,
    );
    expect(grid, isNotNull);
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 5; column++) {
        expect(
          grid!.values[row][column],
          NumberWallCell.determinant(
              NumberWallSequence.fibonacci, row, column + 3, BigInt.from(7)),
        );
      }
    }
    await expectLater(
      NumberWallGrid.generate(
        sequence: NumberWallSequence.fibonacci,
        prime: BigInt.from(7),
        rowCount: 4,
        columnStart: 3,
        columnCount: 5,
        isCancelled: () => true,
      ),
      completion(isNull),
    );
  });
}
