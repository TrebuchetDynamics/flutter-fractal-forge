import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_fractals/features/fourier/lab/discrete_cantor_alphabet.dart';
import 'package:flutter_fractals/features/fourier/lab/discrete_cantor_mask.dart';
import 'package:flutter_fractals/features/fourier/lab/fractal_uncertainty_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestrictedFourierOperator', () {
    test('A agrees with a naive dense unitary DFT oracle', () {
      final xMask = _mask(
        DiscreteCantorAlphabet(
          base: 2,
          cells: {const CantorCell(0, 0), const CantorCell(1, 1)},
        ),
      );
      final yMask = _mask(
        DiscreteCantorAlphabet(
          base: 2,
          cells: {const CantorCell(0, 0), const CantorCell(0, 1)},
        ),
      );
      final operator = RestrictedFourierOperator(xMask, yMask);
      final input = Float64List.fromList(<double>[
        1,
        0.5,
        99,
        99,
        99,
        99,
        -0.25,
        0.75,
      ]);

      final actual = operator.apply(input);
      final expected = _naiveRestrictedForward(input, xMask, yMask);

      _expectComplexClose(actual, expected, 1e-12);
    });

    test('A* agrees with the complex inner-product adjoint identity', () {
      final xMask = _mask(DiscreteCantorAlphabet.verticalLine(base: 3, x: 0));
      final yMask = _mask(DiscreteCantorAlphabet.horizontalLine(base: 3, y: 0));
      final operator = RestrictedFourierOperator(xMask, yMask);
      final v = _deterministicVector(9, phase: 0.3);
      final w = _deterministicVector(9, phase: -0.7);

      final left = _inner(operator.apply(v), w);
      final right = _inner(v, operator.applyAdjoint(w));

      expect(left.$1, closeTo(right.$1, 1e-11));
      expect(left.$2, closeTo(right.$2, 1e-11));
    });

    test('A*A is positive semidefinite', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );
      final mask = _mask(dust);
      final operator = RestrictedFourierOperator(mask, mask);
      final v = _deterministicVector(9, phase: 0.19);

      final quadratic = _inner(v, operator.applyNormal(v));

      expect(quadratic.$1, greaterThanOrEqualTo(-1e-12));
      expect(quadratic.$2, closeTo(0, 1e-11));
    });
  });

  group('FractalUncertaintyEstimator', () {
    test('both orthogonal axis-line pairs have norm one', () {
      final estimator = FractalUncertaintyEstimator();
      final vertical = DiscreteCantorMask.generate(
        DiscreteCantorAlphabet.verticalLine(base: 3, x: 0),
        recursion: 2,
      );
      final horizontal = DiscreteCantorMask.generate(
        DiscreteCantorAlphabet.horizontalLine(base: 3, y: 0),
        recursion: 2,
      );

      final first = estimator.estimate(vertical, horizontal);
      final second = estimator.estimate(horizontal, vertical);

      expect(first.sigma, closeTo(1, 1e-10));
      expect(second.sigma, closeTo(1, 1e-10));
      expect(first.converged, isTrue);
      expect(second.converged, isTrue);
    });

    test('line-free product dust has sigma strictly below one', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );

      final result = FractalUncertaintyEstimator().estimate(
        DiscreteCantorMask.generate(dust, recursion: 2),
        DiscreteCantorMask.generate(dust, recursion: 2),
      );

      expect(result.sigma, greaterThanOrEqualTo(0));
      expect(result.sigma, lessThan(1 - 1e-6));
      expect(result.residual, lessThan(1e-9));
    });

    test('retained energy and leakage are exact complements', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );

      final result = FractalUncertaintyEstimator().estimate(
        DiscreteCantorMask.generate(dust, recursion: 2),
        DiscreteCantorMask.generate(dust, recursion: 2),
      );

      expect(
          result.retainedEnergy, closeTo(result.sigma * result.sigma, 1e-14));
      expect(result.retainedEnergy + result.leakage, closeTo(1, 1e-14));
      expect(result.hilbertSchmidtBound, inInclusiveRange(0, 1));
      expect(result.empiricalBeta, greaterThan(0));
    });

    test('supports deterministic cancellation', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );
      var checks = 0;

      expect(
        () => FractalUncertaintyEstimator().estimate(
          _mask(dust),
          _mask(dust),
          isCancelled: () => ++checks >= 2,
        ),
        throwsA(isA<FractalUncertaintyEstimationCancelled>()),
      );
    });

    test('fits an explicitly finite multi-k empirical decay slope', () {
      final dust = DiscreteCantorAlphabet.product(
        base: 3,
        xDigits: const {0, 2},
        yDigits: const {0, 2},
      );
      final estimator = FractalUncertaintyEstimator();
      final results = [
        for (var recursion = 1; recursion <= 2; recursion++)
          estimator.estimate(
            DiscreteCantorMask.generate(dust, recursion: recursion),
            DiscreteCantorMask.generate(dust, recursion: recursion),
          ),
      ];

      final fit = FiniteDecayFit.fromResults(results);

      expect(fit.label, 'finite empirical estimate');
      expect(fit.beta, greaterThan(0));
      expect(fit.rSquared, inInclusiveRange(0, 1));
      expect(fit.sampleCount, 2);
    });

    test('respects a submultiplicative fixture within finite precision', () {
      final singleton = DiscreteCantorAlphabet(
        base: 3,
        cells: {const CantorCell(0, 0)},
      );
      final estimator = FractalUncertaintyEstimator();
      final levelOne = estimator.estimate(
        DiscreteCantorMask.generate(singleton, recursion: 1),
        DiscreteCantorMask.generate(singleton, recursion: 1),
      );
      final levelTwo = estimator.estimate(
        DiscreteCantorMask.generate(singleton, recursion: 2),
        DiscreteCantorMask.generate(singleton, recursion: 2),
      );

      expect(levelTwo.sigma,
          lessThanOrEqualTo(levelOne.sigma * levelOne.sigma + 1e-12));
    });
  });
}

DiscreteCantorMask _mask(DiscreteCantorAlphabet alphabet) =>
    DiscreteCantorMask.generate(alphabet, recursion: 1);

Float64List _deterministicVector(int length, {required double phase}) {
  final result = Float64List(length * 2);
  for (var index = 0; index < length; index++) {
    result[index * 2] = math.sin(index * 0.71 + phase);
    result[index * 2 + 1] = math.cos(index * 0.43 - phase);
  }
  return result;
}

Float64List _naiveRestrictedForward(
  Float64List input,
  DiscreteCantorMask xMask,
  DiscreteCantorMask yMask,
) {
  final n = xMask.sideLength;
  final output = Float64List(input.length);
  for (final frequency in yMask.activeCoordinates) {
    var real = 0.0;
    var imaginary = 0.0;
    for (final spatial in xMask.activeCoordinates) {
      final angle = -2 *
          math.pi *
          (spatial.x * frequency.x + spatial.y * frequency.y) /
          n;
      final inputIndex = (spatial.y * n + spatial.x) * 2;
      final a = input[inputIndex];
      final b = input[inputIndex + 1];
      real += a * math.cos(angle) - b * math.sin(angle);
      imaginary += a * math.sin(angle) + b * math.cos(angle);
    }
    final outputIndex = (frequency.y * n + frequency.x) * 2;
    output[outputIndex] = real / n;
    output[outputIndex + 1] = imaginary / n;
  }
  return output;
}

(double, double) _inner(Float64List left, Float64List right) {
  var real = 0.0;
  var imaginary = 0.0;
  for (var index = 0; index < left.length; index += 2) {
    real += left[index] * right[index] + left[index + 1] * right[index + 1];
    imaginary +=
        left[index] * right[index + 1] - left[index + 1] * right[index];
  }
  return (real, imaginary);
}

void _expectComplexClose(
    Float64List actual, Float64List expected, double tolerance) {
  expect(actual.length, expected.length);
  for (var index = 0; index < actual.length; index++) {
    expect(actual[index], closeTo(expected[index], tolerance),
        reason: 'index $index');
  }
}
