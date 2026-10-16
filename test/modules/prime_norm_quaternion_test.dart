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

  test('orthographic projection and deterministic picking survive rotation',
      () async {
    final slice = await PrimeNormQuaternionSlice.generate(2, d: 0);
    final camera = QuaternionSliceCamera();
    final point = (a: 1, b: 1, c: 0, d: 0);
    final projected = camera.project(point, const Size(400, 300), 2);
    expect(projected, isNotNull);
    expect(
        camera.pick(projected!.screen, slice, const Size(400, 300), 2,
            hitRadius: 1),
        (a: 1, b: 1, c: 1, d: 0));
    final before = slice.points.toSet();
    camera.rotate(0.3, -0.2);
    expect(slice.points.toSet(), before);
    final rotated = camera.project(point, const Size(400, 300), 2)!;
    final picked = camera.pick(rotated.screen, slice, const Size(400, 300), 2,
        hitRadius: 1);
    expect(picked, isNotNull);
    expect(
        camera.pick(rotated.screen, slice, const Size(400, 300), 2,
            hitRadius: 1),
        picked);
  });
}
