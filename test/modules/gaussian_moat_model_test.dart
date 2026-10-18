import 'dart:async';

import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slow map jobs run once plus only the latest replacement', () async {
    final calls = <int>[];
    final published = <int>[];
    final jobs = <Completer<GaussianPrimeMap?>>[];
    final latestStarted = Completer<void>();
    var active = 0;
    var peakActive = 0;
    final queue = GaussianMoatMapJobQueue((bound, {isCancelled}) {
      active++;
      if (active > peakActive) peakActive = active;
      calls.add(bound);
      if (bound == 6 && !latestStarted.isCompleted) latestStarted.complete();
      final job = Completer<GaussianPrimeMap?>();
      jobs.add(job);
      return job.future.whenComplete(() => active--);
    }, (bound, _) => published.add(bound));

    queue.submit(32);
    await Future<void>.delayed(Duration.zero);
    queue
      ..submit(4)
      ..submit(5)
      ..submit(6);
    expect(calls, [32]);
    expect(active, 1);

    jobs.first.complete(await GaussianPrimeMap.generate(32));
    await latestStarted.future;
    expect(calls, [32, 6], reason: 'B and C are superseded by D');
    expect(active, 1);
    expect(peakActive, 1, reason: 'Only one map computation may be active');
    expect(published, isEmpty, reason: 'A is stale after D was submitted');

    jobs.last.complete(await GaussianPrimeMap.generate(6));
    await queue.idle;
    expect(published, [6]);
    expect(active, 0);
    queue.dispose();
  });

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
  test('step adjacency includes k=4 and rejects k=3, repeats and composites',
      () async {
    final map = (await GaussianPrimeMap.generate(4))!;
    expect(map.isAdjacent((a: 1, b: 1), (a: 1, b: -1), 4), isTrue);
    expect(map.isAdjacent((a: 1, b: 1), (a: 1, b: -1), 3), isFalse);
    expect(map.isAdjacent((a: 1, b: 1), (a: 1, b: 1), 4), isFalse);
    expect(map.isAdjacent((a: 1, b: 1), (a: 2, b: 0), 4), isFalse);
    expect(map.isAdjacent((a: 1, b: 1), (a: 1, b: -1), 0), isFalse);
  });

  test('inclusive squared-step components distinguish k=4 from k=3', () async {
    final map = (await GaussianPrimeMap.generate(1))!;
    expect(map.component((a: 1, b: 1), maxSquaredStep: 2), {
      (a: 1, b: 1),
    });
    expect(map.component((a: 1, b: 1), maxSquaredStep: 4), {
      (a: 1, b: 1),
      (a: 1, b: -1),
      (a: -1, b: 1),
      (a: -1, b: -1),
    });
    expect(map.component((a: 1, b: 1), maxSquaredStep: 3), {
      (a: 1, b: 1),
    });
  });

  test('components are monotone as squared radius grows in a fixed domain',
      () async {
    final map = (await GaussianPrimeMap.generate(8))!;
    final radii = [1, 2, 4, 8, 16];
    var previous = map.component((a: 1, b: 1), maxSquaredStep: radii.first);
    final firstSize = previous.length;
    for (final radius in radii.skip(1)) {
      final current = map.component((a: 1, b: 1), maxSquaredStep: radius);
      expect(current.containsAll(previous), isTrue,
          reason: 'Increasing k to $radius must not lose connected points');
      previous = current;
    }
    expect(previous.length, greaterThan(firstSize));
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
