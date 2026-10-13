import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('containment rejects extreme integers and respects signed boundaries',
      () async {
    final map = (await GaussianPrimeMap.generate(4))!;
    for (final coordinate in [
      -9223372036854775808,
      9223372036854775807,
      -5,
      5,
    ]) {
      for (final p in [(a: coordinate, b: 0), (a: 0, b: coordinate)]) {
        expect(map.contains(p), isFalse, reason: '$p');
        expect(map.isPrime(p), isFalse, reason: '$p');
      }
    }
    for (final coordinate in [-4, 4]) {
      expect(map.contains((a: coordinate, b: 0)), isTrue);
      expect(map.contains((a: 0, b: coordinate)), isTrue);
    }
  });

  test('invalid domains fail before work and cancellation discards results',
      () async {
    var yields = 0;
    for (final bound in [
      0,
      -1,
      129,
      1.5,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      1e30
    ]) {
      await expectLater(
          GaussianPrimeMap.generate(bound, yieldChunk: () async {
            yields++;
          }),
          throwsArgumentError);
    }
    expect(yields, 0);
    expect(
        await GaussianPrimeMap.generate(128,
            isCancelled: () => yields > 0,
            yieldChunk: () async {
              yields++;
            }),
        isNull);
    expect(yields, 1);
  });
  test('cap matches an independent trial-division oracle at every position',
      () async {
    bool prime(int n) {
      if (n < 2) return false;
      for (var d = 2; d * d <= n; d++) {
        if (n % d == 0) return false;
      }
      return true;
    }

    var yields = 0;
    final clock = Stopwatch()..start();
    final map = (await GaussianPrimeMap.generate(128, yieldChunk: () async {
      yields++;
    }))!;
    for (var a = -128; a <= 128; a++) {
      for (var b = -128; b <= 128; b++) {
        final axis = a == 0 ? b.abs() : a.abs();
        final expected =
            a * b != 0 ? prime(a * a + b * b) : prime(axis) && axis % 4 == 3;
        expect(map.isPrime((a: a, b: b)), expected, reason: '($a,$b)');
      }
    }
    expect(yields, greaterThanOrEqualTo(64));
    expect(() => map.points.add((a: 0, b: 0)), throwsUnsupportedError);
    // Host model telemetry, not a device performance qualification.
    print(
        'B=128 points=${map.points.length} yields=$yields oracleElapsedMs=${clock.elapsedMilliseconds}');
  });
  test('exact finite field includes signed and axis primes, not units',
      () async {
    final map = (await GaussianPrimeMap.generate(4))!;
    for (final p in [(a: 1, b: 1), (a: 1, b: -1), (a: 3, b: 0), (a: 0, b: 3)]) {
      expect(map.isPrime(p), isTrue, reason: '$p');
    }
    for (final p in [
      (a: 0, b: 0),
      (a: 1, b: 0),
      (a: 0, b: -1),
      (a: 2, b: 0),
      (a: 2, b: 2)
    ]) {
      expect(map.isPrime(p), isFalse, reason: '$p');
    }
    expect((await GaussianPrimeMap.generate(1))!.points.toSet(), {
      (a: -1, b: -1),
      (a: -1, b: 1),
      (a: 1, b: -1),
      (a: 1, b: 1),
    });
    expect(map.contains((a: 5, b: 0)), isFalse);
  });
}
