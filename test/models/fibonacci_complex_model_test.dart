import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fibonacci_complex_model.dart';

// Exact coefficient convolution is independent of the model's complex-state
// update. Coefficients are ascending powers; c is a fixed nonzero integer.
List<int> _polynomialProduct(List<int> a, List<int> b, int c) {
  final coefficients = List<int>.filled(a.length + b.length - 1, 0);
  for (var i = 0; i < a.length; i++) {
    for (var j = 0; j < b.length; j++) {
      coefficients[i + j] += a[i] * b[j];
    }
  }
  coefficients[0] += c;
  return coefficients;
}

(double, double, double, double) _state(FibonacciComplexOrbit result) =>
    (result.zReal, result.zImag, result.wReal, result.wImag);

void _expectFinite(FibonacciComplexOrbit result) {
  for (final value in [
    result.zReal,
    result.zImag,
    result.wReal,
    result.wImag,
  ]) {
    expect(value.isFinite, isTrue);
  }
}

void main() {
  test('complex diagonal updates copy OLD z into w at every completed step',
      () {
    // Hand-expanded at p=1+2i and c=-1/2+i/4, not a second orbit loop.
    final expected = [
      (-3.5, 4.25, 1.0, 2.0),
      (-12.5, -2.5, -3.5, 4.25),
      (53.875, -44.125, -12.5, -2.5),
    ];
    for (var n = 1; n <= expected.length; n++) {
      final result = FibonacciComplexModel.orbit(
        zReal: 1,
        zImag: 2,
        cReal: -.5,
        cImag: .25,
        maxIterations: n,
        bailout: 1e6,
      );
      expect(result.status, FibonacciComplexStatus.capReached);
      expect(result.updates, n);
      expect(_state(result), expected[n - 1]);
    }
  });

  test('nonzero-c coefficient oracles are monic with Fibonacci degrees', () {
    const degrees = [1, 2, 3, 5, 8, 13, 21, 34, 55];
    for (final c in [-1, 1]) {
      var polynomials = <List<int>>[
        [0, 1],
        [0, 1]
      ];
      for (var k = 0; k < degrees.length; k++) {
        final coefficients = polynomials.last;
        expect(coefficients.length - 1, degrees[k]);
        expect(coefficients.last, 1);
        expect(FibonacciComplexModel.degreeAtUpdate(k), degrees[k]);
        if (k > 0) {
          for (final p in [-.25, .5, .75]) {
            var expected = 0.0;
            for (final coefficient in coefficients.reversed) {
              expected = expected * p + coefficient;
            }
            final result = FibonacciComplexModel.orbit(
              zReal: p,
              zImag: 0,
              cReal: c.toDouble(),
              cImag: 0,
              maxIterations: k,
              bailout: 1e100,
            );
            expect(result.status, FibonacciComplexStatus.capReached);
            expect(result.zReal,
                closeTo(expected, 1e-10 * math.max(1, expected.abs())));
            expect(result.zImag, 0);
          }
        }
        polynomials = [
          polynomials.last,
          _polynomialProduct(polynomials.last, polynomials.first, c),
        ];
      }
    }
  });

  test('all finite prime-degree markers use primality of F, not its index', () {
    const primeDegrees = {
      1: 2,
      2: 3,
      3: 5,
      5: 13,
      9: 89,
      11: 233,
      15: 1597,
      21: 28657,
      27: 514229,
      41: 433494437,
      45: 2971215073,
    };
    var previous = 1, degree = 1;
    for (var k = 0; k <= 45; k++) {
      expect(FibonacciComplexModel.degreeAtUpdate(k), degree);
      expect(FibonacciComplexModel.isPrimeDegreeAtUpdate(k),
          primeDegrees.containsKey(k),
          reason: 'k=$k, F${k + 2}=$degree');
      if (primeDegrees.containsKey(k)) expect(degree, primeDegrees[k]);
      final next = previous + degree;
      previous = degree;
      degree = next;
    }
    expect(FibonacciComplexModel.degreeAtUpdate(2), 3); // F4 exception.
    expect(FibonacciComplexModel.degreeAtUpdate(17), 37 * 113); // F19.
    for (final k in [-1, 46]) {
      expect(() => FibonacciComplexModel.degreeAtUpdate(k), throwsRangeError);
      expect(() => FibonacciComplexModel.isPrimeDegreeAtUpdate(k),
          throwsRangeError);
    }
  });

  test('c=0 reference disk agrees away from the precision boundary', () {
    for (final p in [
      (0.0, 0.0),
      (.5, .5),
      (.99, 0.0),
      (1.0, 0.0),
      (-1.0, 0.0),
      (0.0, 1.0),
      (0.0, -1.0)
    ]) {
      final result = FibonacciComplexModel.orbit(
        zReal: p.$1,
        zImag: p.$2,
        cReal: 0,
        cImag: 0,
      );
      expect(result.status, FibonacciComplexStatus.capReached);
      expect(result.updates, 45);
      _expectFinite(result);
    }
    // At r=1.01 the old coordinate first exceeds 4 at F12=144:
    // 1.01^89 < 4 < 1.01^144, hence first escape is k=11.
    for (final p in [(1.01, 0.0), (-1.01, 0.0), (0.0, 1.01), (.606, .808)]) {
      final result = FibonacciComplexModel.orbit(
        zReal: p.$1,
        zImag: p.$2,
        cReal: 0,
        cImag: 0,
      );
      expect(result.status, FibonacciComplexStatus.escaped);
      expect(result.updates, 11);
      final modulus =
          math.sqrt(result.zReal * result.zReal + result.zImag * result.zImag);
      expect(modulus, closeTo(math.pow(1.01, 233), 1e-10));
      _expectFinite(result);
    }
  });

  test('nonzero complex c retains the exact algebraic three-cycle', () {
    const cycle = [
      (1.5, .25, -1.0, 0.0),
      (-1.0, 0.0, 1.5, .25),
      (-1.0, 0.0, -1.0, 0.0),
    ];
    for (var n = 1; n <= 6; n++) {
      final result = FibonacciComplexModel.orbit(
        zReal: -1,
        zImag: 0,
        cReal: .5,
        cImag: .25,
        maxIterations: n,
      );
      expect(result.status, FibonacciComplexStatus.capReached);
      expect(result.updates, n);
      expect(_state(result), cycle[(n - 1) % 3]);
    }
  });

  test('one-large-coordinate states collapse instead of escaping', () {
    for (final start in [(1e308, 0.0), (0.0, 1e308)]) {
      final result = FibonacciComplexModel.orbit(
        zReal: start.$1,
        zImag: 0,
        wReal: start.$2,
        wImag: 0,
        cReal: 0,
        cImag: 0,
        maxIterations: 2,
      );
      expect(result.status, FibonacciComplexStatus.capReached);
      expect(result.updates, 2);
      expect(_state(result), (0.0, 0.0, 0.0, 0.0));
    }
  });

  test('safe radius is strict, uses abs(c), and inspects k=0 through N', () {
    final cases = [
      // (p, cRe, cIm, bailout, N, expected k, expected status)
      (5.0, 0.0, 0.0, 4.0, 1, 0, FibonacciComplexStatus.escaped),
      (2.0, 0.0, 0.0, .25, 1, 1, FibonacciComplexStatus.capReached),
      (2.0, 0.0, 0.0, .25, 2, 2, FibonacciComplexStatus.escaped),
      (3.0, 2.0, 0.0, 1.0, 1, 1, FibonacciComplexStatus.capReached),
      (3.0, 2.0, 0.0, 1.0, 2, 2, FibonacciComplexStatus.escaped),
      (4.5, 2.0, 2.0, 1.0, 1, 1, FibonacciComplexStatus.capReached),
      (4.0, 0.0, 0.0, 16.0, 2, 2, FibonacciComplexStatus.capReached),
      (4.0, 0.0, 0.0, 16.0, 3, 3, FibonacciComplexStatus.escaped),
    ];
    for (final t in cases) {
      final result = FibonacciComplexModel.orbit(
        zReal: t.$1,
        zImag: 0,
        cReal: t.$2,
        cImag: t.$3,
        bailout: t.$4,
        maxIterations: t.$5,
      );
      expect(result.status, t.$7, reason: '$t');
      expect(result.updates, t.$6, reason: '$t');
    }
    // Squaring or multiplying these inputs overflows. Region inspection must
    // happen first and must not use overflowing squared magnitudes.
    for (final t in [
      (1e308, 1e308, 0.0, 0.0, 4.0),
      // Each component is below R, but the combined modulus exceeds R.
      (1.3e308, 1.3e308, 0.0, 0.0, 1.7e308),
      // |c| is finite even though squaring either c component overflows.
      (1.5e200, 0.0, 1e200, 1e200, 4.0),
    ]) {
      final huge = FibonacciComplexModel.orbit(
        zReal: t.$1,
        zImag: t.$2,
        cReal: t.$3,
        cImag: t.$4,
        bailout: t.$5,
      );
      expect(huge.status, FibonacciComplexStatus.escaped, reason: '$t');
      expect(huge.updates, 0);
      _expectFinite(huge);
    }
  });

  test('invalid low-level inputs return finite numerical uncertainty', () {
    final inputs = <Map<String, double>>[
      for (final name in [
        'zReal',
        'zImag',
        'wReal',
        'wImag',
        'cReal',
        'cImag',
        'bailout'
      ])
        for (final value in [
          double.nan,
          double.infinity,
          double.negativeInfinity
        ])
          {name: value},
      {'bailout': 0},
      {'bailout': -1},
      {'cReal': 1.7e308, 'cImag': 1.7e308},
    ];
    for (final input in inputs) {
      final result = FibonacciComplexModel.orbit(
        zReal: input['zReal'] ?? 5,
        zImag: input['zImag'] ?? 0,
        wReal: input['wReal'],
        wImag: input['wImag'],
        cReal: input['cReal'] ?? 0,
        cImag: input['cImag'] ?? 0,
        bailout: input['bailout'] ?? 4,
      );
      expect(result.status, FibonacciComplexStatus.numericallyUnresolved,
          reason: '$input');
      expect(result.updates, 0);
      _expectFinite(result);
    }
    for (final n in [-1, 0, 46]) {
      final result = FibonacciComplexModel.orbit(
        zReal: 5,
        zImag: 0,
        cReal: 0,
        cImag: 0,
        maxIterations: n,
      );
      expect(result.status, FibonacciComplexStatus.numericallyUnresolved);
      _expectFinite(result);
    }
  });

  test('nonfinite products are unresolved, never escaped or cap-nonescape', () {
    final result = FibonacciComplexModel.orbit(
      zReal: 1e154,
      zImag: 0,
      wReal: 1,
      wImag: 0,
      cReal: 0,
      cImag: 0,
      bailout: 1e308,
      maxIterations: 3,
    );
    expect(result.status, FibonacciComplexStatus.numericallyUnresolved);
    expect(
        result.updates, 2); // Last finite state, before failed multiplication.
    expect(result.zReal, 1e308);
    expect(result.wReal, 1e154);
    _expectFinite(result);
    // Reading prime/color metadata has no role in the status decision.
    expect(FibonacciComplexModel.isPrimeDegreeAtUpdate(result.updates), isTrue);
    expect(result.status, FibonacciComplexStatus.numericallyUnresolved);
  });
}
