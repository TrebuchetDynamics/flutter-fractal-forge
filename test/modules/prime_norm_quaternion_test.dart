import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/prime_norm_quaternion_model.dart';

void main() {
  test('fixed-d domain uses ordinary prime quaternion norms', () async {
    final slice = await PrimeNormQuaternionSlice.generate(2, d: 0);
    expect(slice.points, contains((a: 1, b: 1, c: 0, d: 0)));
    expect(slice.points, contains((a: 1, b: 1, c: 1, d: 0)));
    expect(slice.contains((a: 0, b: 0, c: 0, d: 0)), isTrue);
    expect(slice.isPrimeNorm((a: 0, b: 0, c: 0, d: 0)), isFalse);
    expect(slice.isPrimeNorm((a: 1, b: 0, c: 0, d: 0)), isFalse);
    expect(slice.isPrimeNorm((a: 2, b: 0, c: 0, d: 0)), isFalse);
    expect(slice.isPrimeNorm((a: 1, b: 1, c: 1, d: 0)), isTrue);
  });

  test('signed fixed d, bounds and validation are exact', () async {
    final slice = await PrimeNormQuaternionSlice.generate(2, d: -1);
    expect(slice.isPrimeNorm((a: 1, b: 1, c: 0, d: -1)), isTrue);
    expect(slice.isPrimeNorm((a: -1, b: -1, c: 0, d: -1)), isTrue);
    expect(slice.contains((a: 3, b: 0, c: 0, d: -1)), isFalse);
    expect(
        () => PrimeNormQuaternionSlice.validateDomain(13), throwsArgumentError);
    expect(
        () => PrimeNormQuaternionSlice.validateSlice(13), throwsArgumentError);
  });

  test('walk adjacency and component use original fixed-d coordinates',
      () async {
    final slice = await PrimeNormQuaternionSlice.generate(2, d: 0);
    const start = (a: 1, b: 1, c: 0, d: 0);
    const diagonal = (a: 1, b: 0, c: 1, d: 0);
    expect(slice.isAdjacent(start, diagonal, 2), isTrue);
    expect(slice.isAdjacent(start, diagonal, 1), isFalse);
    expect(slice.component(start, maxSquaredStep: 2), contains(start));
    expect(slice.component(start, maxSquaredStep: 2), contains(diagonal));
    expect(slice.isAdjacent(start, (a: 1, b: 0, c: 1, d: 1), 2), isFalse);
  });

  test('maximum generation yields at probe cap and cancels replacements',
      () async {
    var yields = 0;
    final rssBefore = ProcessInfo.currentRss;
    final stopwatch = Stopwatch()..start();
    final slice = await PrimeNormQuaternionSlice.generate(
      PrimeNormQuaternionSlice.maxDomain,
      d: PrimeNormQuaternionSlice.maxAbsSlice,
      yieldChunk: () async {
        yields++;
      },
    );
    stopwatch.stop();
    final rssAfter = ProcessInfo.currentRss;

    expect(yields, 15);
    expect(slice.points.length, lessThanOrEqualTo(15625));
    expect(slice.points.every(slice.isPrimeNorm), isTrue);
    print(
        'quaternion cap: points=${slice.points.length}/15625 yields=$yields elapsedMs=${stopwatch.elapsedMilliseconds} rssBefore=$rssBefore rssAfter=$rssAfter');

    var cancelAfterYield = false;
    await expectLater(
      PrimeNormQuaternionSlice.generate(
        PrimeNormQuaternionSlice.maxDomain,
        d: PrimeNormQuaternionSlice.maxAbsSlice,
        isCancelled: () => cancelAfterYield,
        yieldChunk: () async {
          cancelAfterYield = true;
        },
      ),
      throwsStateError,
    );
  });

  test('orthographic projection and deterministic picking survive rotation',
      () async {
    final slice = await PrimeNormQuaternionSlice.generate(2, d: 0);
    final camera = QuaternionSliceCamera();
    const backPoint = (a: 1, b: 1, c: 0, d: 0);
    const frontPoint = (a: 1, b: 1, c: 1, d: 0);
    final projected = camera.project(backPoint, const Size(400, 300), 2);
    final occluded = camera.project(frontPoint, const Size(400, 300), 2);
    expect(projected, isNotNull);
    expect(occluded, isNotNull);
    expect(occluded!.screen, projected!.screen);
    expect(occluded.depth, greaterThan(projected.depth));
    expect(
        camera.pick(projected.screen, slice, const Size(400, 300), 2,
            hitRadius: 1),
        frontPoint);
    final before = slice.points.toSet();
    camera.rotate(0.3, -0.2);
    expect(slice.points.toSet(), before);
    final rotated = camera.project(backPoint, const Size(400, 300), 2)!;
    final picked = camera.pick(rotated.screen, slice, const Size(400, 300), 2,
        hitRadius: 1);
    expect(picked, isNotNull);
    expect(
        camera.pick(rotated.screen, slice, const Size(400, 300), 2,
            hitRadius: 1),
        picked);
  });
}
