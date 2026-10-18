import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/attractor_trajectory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RK4 short-horizon fixtures retain the reviewed vector fields', () {
    const seed = OrbitPoint(0.1, 0.2, 0.3);
    const dt = 0.01;
    const fixtures = <(AttractorSystem, OrbitPoint)>[
      (
        AttractorSystem.thomas,
        OrbitPoint(0.101789084902954, 0.202538000247744, 0.300382263876495),
      ),
      (
        AttractorSystem.fourWing,
        OrbitPoint(0.100801946301577, 0.198909615912361, 0.302785794133354),
      ),
      (
        AttractorSystem.lorenz2d,
        OrbitPoint(0.110802162964979, 0.227029836615913, 0.292327630146888),
      ),
    ];

    for (final (system, expected) in fixtures) {
      final actual = AttractorTrajectoryModel.integrate(
        system: system,
        initial: seed,
        dt: dt,
        steps: 1,
      );
      expect(actual.x, closeTo(expected.x, 1e-12), reason: '$system x');
      expect(actual.y, closeTo(expected.y, 1e-12), reason: '$system y');
      expect(actual.z, closeTo(expected.z, 1e-12), reason: '$system z');
    }
  });

  test('RK4 converges against a half-step over the same short horizon', () {
    const seed = OrbitPoint(0.1, 0.2, 0.3);
    for (final system in AttractorSystem.values) {
      final standard = AttractorTrajectoryModel.integrate(
        system: system,
        initial: seed,
        dt: 0.01,
        steps: 100,
      );
      final halfStep = AttractorTrajectoryModel.integrate(
        system: system,
        initial: seed,
        dt: 0.005,
        steps: 200,
      );
      expect((standard - halfStep).length, lessThan(1e-4), reason: '$system');
    }
  });

  test('projections use the accepted orthonormal views', () {
    const point = OrbitPoint(1, 2, 3);

    final xz = AttractorTrajectoryModel.project(
      point,
      OrbitProjection.xz,
    );
    expect(xz.x, 1);
    expect(xz.y, 3);

    final oblique = AttractorTrajectoryModel.project(
      point,
      OrbitProjection.thomasOblique,
    );
    expect(oblique.x, closeTo(-1 / math.sqrt(2), 1e-15));
    expect(oblique.y, closeTo(-3 / math.sqrt(6), 1e-15));
  });

  test('bounded trajectory generation burns in then retains finite samples',
      () {
    final settings = OrbitTrajectorySettings.defaultsFor('thomas_attractor')
        .copyWith(burnInSteps: 2, retainedSteps: 3);
    final result = AttractorTrajectoryModel.generate(settings);

    expect(result.points, hasLength(3));
    expect(result.bounds.isFinite, isTrue);
    expect(
      result.points.every(
          (point) => point.x.isFinite && point.y.isFinite && point.z.isFinite),
      isTrue,
    );
  });

  test('four-wing default trajectory retains a visible projected extent', () {
    final trajectory = AttractorTrajectoryModel.generate(
      OrbitTrajectorySettings.defaultsFor('four_wing'),
    );
    expect(trajectory.bounds.maxX - trajectory.bounds.minX, greaterThan(1));
    expect(trajectory.bounds.maxY - trajectory.bounds.minY, greaterThan(0.25));
  });

  test('trajectory settings reject work above the accepted safety caps', () {
    expect(
      () => OrbitTrajectorySettings.defaultsFor('thomas_attractor').copyWith(
        burnInSteps: 5001,
        retainedSteps: 20000,
      ),
      throwsArgumentError,
    );
    expect(
      () => OrbitTrajectorySettings.defaultsFor('thomas_attractor').copyWith(
        burnInSteps: 5000,
        retainedSteps: 20001,
      ),
      throwsArgumentError,
    );
  });

  test('trajectory cache reuses generated samples across view redraws',
      () async {
    final settings = OrbitTrajectorySettings.defaultsFor('four_wing')
        .copyWith(burnInSteps: 2, retainedSteps: 3);
    final cache = AttractorTrajectoryCache();
    final first = await cache.getOrGenerate(
      settings,
      cancellation: AttractorTrajectoryCancellation(),
    );
    final second = await cache.getOrGenerate(
      settings,
      cancellation: AttractorTrajectoryCancellation(),
    );

    expect(identical(second, first), isTrue);
    expect(cache.length, 1);
  });

  test('cancelled asynchronous generation does not publish partial points',
      () async {
    final cancellation = AttractorTrajectoryCancellation();
    final settings = OrbitTrajectorySettings.defaultsFor('lorenz_2d');
    final generation = AttractorTrajectoryModel.generateAsync(
      settings,
      cancellation: cancellation,
      stepsPerChunk: 16,
    );
    cancellation.cancel();

    expect(await generation, isNull);
  });
}
