import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

import '../helpers/sine_sphere_oracle.dart';

Future<SineKernelSample> _sphereSample({
  required Vector3 origin,
  required Vector3 direction,
}) =>
    runSineKernel(
      depth: 0,
      strength: 0.8,
      radius: 1,
      phase: 0,
      budget: 512,
      origin: origin,
      direction: direction,
    );

void main() {
  test('portable shader assets embed the identical canonical kernel', () {
    const directory = 'shaders/3d_and_hypercomplex/raymarched_volumes';
    // Git may check these assets out as CRLF on Windows.
    final kernel = File('$directory/recursive_sine_sphere_kernel.glsl')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    for (final path in [
      '$directory/recursive_sine_sphere_gpu.frag',
      sineKernelFixtureAsset,
    ]) {
      final source = File(path).readAsStringSync().replaceAll('\r\n', '\n');
      expect(
          source,
          contains('// BEGIN GENERATED SINE SPHERE KERNEL\n'
              '$kernel// END GENERATED SINE SPHERE KERNEL\n'),
          reason: 'Regenerate with python3 scripts/sync_sine_sphere_kernel.py');
      expect(
          source, isNot(matches(RegExp(r'^\s*#include\s+"', multiLine: true))));
    }
  });

  test('shared production kernel classifies analytic sphere rays', () async {
    final axial = await _sphereSample(
      origin: Vector3(0, 0, 3),
      direction: Vector3(0, 0, -1),
    );
    expect(axial.status, 1); // hit
    expect(axial.distance, closeTo(2, 5e-4));
    expect(axial.residual, lessThanOrEqualTo(5e-4));

    final interior = await _sphereSample(
      origin: Vector3.zero(),
      direction: Vector3(0, 1, 0),
    );
    expect(interior.status, 1);
    expect(interior.distance, closeTo(1, 5e-4));

    final tangent = await _sphereSample(
      origin: Vector3(1, 0, 3),
      direction: Vector3(0, 0, -1),
    );
    expect(tangent.status, 3); // tangent, not promoted to a transverse hit
    expect(tangent.distance, closeTo(3, 5e-4));
    expect(tangent.residual, lessThanOrEqualTo(5e-4));

    final nearSilhouette = await _sphereSample(
      origin: Vector3(0.999, 0, 3),
      direction: Vector3(0, 0, -1),
    );
    expect(nearSilhouette.status, 1);
    expect(
      nearSilhouette.distance,
      closeTo(3 - math.sqrt(1 - 0.999 * 0.999), 5e-4),
    );

    final miss = await _sphereSample(
      origin: Vector3(1.001, 0, 3),
      direction: Vector3(0, 0, -1),
    );
    expect(miss.status, 0); // outside the analytic silhouette
  });

  test('shader warped hits match independently bracketed nearest crossings',
      () async {
    for (final fixture in [
      (
        origin: Vector3(0, 0, 4),
        bracket: (4.0891, 4.0898),
        expected: 4.089427178194093,
      ),
      (
        origin: Vector3(0.3, -0.4, 4),
        bracket: (3.9890, 3.9897),
        expected: 3.989350571627848,
      ),
    ]) {
      // These bounds retain the independently located first crossing. The test
      // re-scans the full enclosure interval, verifies the first discovered
      // bracket is inside them, then bisects with its own double recurrence.
      final reference = independentSineFirstCrossing(
        fixture.origin,
        Vector3(0, 0, -1),
        fixture.bracket,
      );
      expect(reference, closeTo(fixture.expected, 1e-10));
      final sample = await runSineKernel(
        depth: 2,
        strength: 0.8,
        radius: 1,
        phase: 0.4,
        budget: 512,
        origin: fixture.origin,
        direction: Vector3(0, 0, -1),
      );
      expect(sample.status, 1);
      expect(sample.distance, closeTo(reference, 5e-4));
      expect(sample.residual, lessThanOrEqualTo(5e-4));
    }
  });

  test('shader accepts an origin already on the warped surface', () async {
    // At phase pi/2 the first warp sends the origin to (0.5,0.5,0.5).
    final sample = await runSineKernel(
      depth: 1,
      strength: 0.5,
      radius: math.sqrt(0.75),
      phase: math.pi / 2,
      budget: 64,
      origin: Vector3.zero(),
      direction: Vector3(1, 0, 0),
    );
    expect(sample.status, 1);
    expect(sample.distance, closeTo(0, 1e-5));
    expect(sample.residual, lessThanOrEqualTo(5e-4));
  });

  test('shader certifies miss after traversing the full finite enclosure',
      () async {
    final sample = await runSineKernel(
      depth: 2,
      strength: 0.8,
      radius: 1,
      phase: 0.4,
      budget: 512,
      origin: Vector3(3, -4, 0),
      direction: Vector3(0, 1, 0),
    );
    expect(sample.status, 0);
  });

  test('shader separates budget exhaustion and float stagnation from misses',
      () async {
    final sample = await runSineKernel(
      depth: 6,
      strength: 1,
      radius: 1,
      phase: 0,
      budget: 64,
      origin: Vector3(0, 0, 8),
      direction: Vector3(0, 0, -1),
    );
    expect(sample.status, 2); // budget exhausted, not certified miss or hit
    final stagnant = await runSineKernel(
      depth: 2,
      strength: 0.8,
      radius: 1,
      phase: 0.4,
      budget: 512,
      origin: Vector3(0, 0, 100000),
      direction: Vector3(0, 0, -1),
    );
    expect(stagnant.status, 4); // float distance cannot advance
  });
}
