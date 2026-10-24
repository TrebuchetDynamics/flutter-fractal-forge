import 'dart:math' as math;

import 'package:flutter_fractals/core/models/attractor_trajectory_settings.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/features/looper/looper_camera_sampler.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('looper lerps camera and numeric parameters', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);

    fractal
      ..updateView(_view(x: 0, y: 0, zoom: 1))
      ..updateParam('bailout', 2.0)
      ..updateParam('iterations', 100)
      ..updateParam('colorScheme', 0);
    looper.setAFromCurrent();

    fractal
      ..updateView(_view(x: 2, y: 0, zoom: 100))
      ..updateParam('bailout', 6.0)
      ..updateParam('iterations', 200)
      ..updateParam('colorScheme', 10);
    looper.setBFromCurrent();

    final halfway = looper.plan!.stateAtPhase(0.25);

    expect(halfway.view.pan.x, closeTo(1, 1e-9));
    expect(halfway.view.zoom, closeTo(10, 1e-9));
    expect(halfway.params['bailout'], closeTo(4, 1e-9));
    expect(halfway.params['iterations'], 150);
    expect(halfway.params['colorScheme'], 5);

    looper.dispose();
    fractal.dispose();
  });

  test('looper hits B exactly on the middle frame at deep zoom', () {
    final registry = ModuleRegistry();
    final fractal = FractalController(registry);
    fractal.selectModule(registry.byId('mandelbrot_tia'), animate: false);
    final looper = LooperController(controller: fractal);

    fractal.updateView(_view(
      x: -0.9548019170761108,
      y: 0.28065797686576843,
      zoom: 30252.334908611236,
    ));
    looper.setAFromCurrent();

    final bView = _view(
      x: -0.9548019170761108 + 1 / 30252.334908611236,
      y: 0.28065797686576843 - 1 / 30252.334908611236,
      zoom: 60504.66981722247,
    );
    fractal.updateView(bView);
    looper.setBFromCurrent();

    final middle = looper.plan!.stateAtFrame(looper.plan!.frameCount ~/ 2);

    expect(middle.view.pan.x, bView.pan.x);
    expect(middle.view.pan.y, bView.pan.y);
    expect(middle.view.zoom, closeTo(bView.zoom, 1e-9));

    looper.dispose();
    fractal.dispose();
  });

  test('seeded camera randomization replaces only the chosen point', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);
    fractal.updateView(_view(x: 0, y: 0, zoom: 1));
    looper.setAFromCurrent();
    fractal.updateView(_view(x: 1, y: 1, zoom: 2));
    looper.setBFromCurrent();
    fractal.updateView(_view(x: 2, y: 2, zoom: 3));
    looper.addPointFromCurrent();

    final priorB = looper.points[1];
    final priorC = looper.points[2];
    final originalParams = looper.points[0].params;
    final duration = looper.duration;
    final frozen = looper.plan!;
    looper.play();
    expect(looper.randomizePoint(0, random: math.Random(42)), isTrue);

    expect(looper.points[0].view.zoom, inInclusiveRange(0.8, 1.25));
    expect(looper.points[0].view.pan.x.abs(), lessThanOrEqualTo(0.15));
    expect(looper.points[0].view.pan.y.abs(), lessThanOrEqualTo(0.15));
    expect(looper.points[1], same(priorB));
    expect(looper.points[2], same(priorC));
    expect(fractal.view.pan.x, 2);
    expect(looper.randomizePoint(1, random: math.Random(42)), isTrue);
    expect(looper.points[0].view.zoom, isNot(1));
    expect(looper.isPlaying, isFalse);
    expect(looper.duration, duration);
    expect(looper.points[0].params, originalParams);
    expect(frozen.points[0].view.zoom, 1);

    looper.dispose();
    fractal.dispose();
  });

  test('seeded 3D randomization preserves pan and roll within angle bounds',
      () {
    final registry = ModuleRegistry();
    final fractal = FractalController(registry);
    fractal.selectModule(registry.byId('mandelbulb'), animate: false);
    fractal.updateView(FractalViewState(
      pan: Vector2(0.4, -0.3),
      zoom: 3,
      rotation: Vector3(0.2, -0.4, 0.6),
    ));
    final looper = LooperController(controller: fractal);
    looper.setAFromCurrent();
    expect(looper.randomizePoint(0, random: math.Random(19)), isTrue);

    final randomized = looper.points.single.view;
    expect(randomized.pan.x, 0.4);
    expect(randomized.pan.y, -0.3);
    expect(randomized.rotation.z, 0.6);
    expect(
        (randomized.rotation.x - 0.2).abs(), lessThanOrEqualTo(math.pi / 12));
    expect(
        (randomized.rotation.y + 0.4).abs(), lessThanOrEqualTo(math.pi / 12));
    expect(randomized.zoom / 3, inInclusiveRange(0.8, 1.25));

    looper.dispose();
    fractal.dispose();
  });

  test('trajectory settings disable randomization without changing snapshots',
      () {
    final registry = ModuleRegistry();
    final fractal = FractalController(registry);
    fractal.selectModule(registry.byId('thomas_attractor'), animate: false);
    final trajectory = OrbitTrajectorySettings.defaultsFor('thomas_attractor');
    fractal.updateView(fractal.view.copyWith(trajectory: trajectory));
    final looper = LooperController(controller: fractal);
    looper.setAFromCurrent();
    final stored = looper.points.single;

    expect(looper.canRandomizePoints, isFalse);
    expect(looper.randomizePoint(0, random: math.Random(42)), isFalse);
    expect(looper.addRandomPoint(random: math.Random(42)), isFalse);
    expect(looper.points.single, same(stored));
    expect(looper.points.single.view.trajectory, same(trajectory));
    expect(fractal.view.trajectory, same(trajectory));

    looper.dispose();
    fractal.dispose();
  });

  test('random optional points require A and B', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);
    expect(looper.randomizePoint(1, random: math.Random(7)), isFalse);
    expect(looper.addRandomPoint(random: math.Random(7)), isFalse);
    expect(looper.randomizePoint(0, random: math.Random(7)), isTrue);
    expect(looper.addRandomPoint(random: math.Random(7)), isFalse);
    expect(looper.randomizePoint(1, random: math.Random(7)), isTrue);
    expect(looper.addRandomPoint(random: math.Random(7)), isTrue);
    expect(looper.points, hasLength(3));
    looper.dispose();
    fractal.dispose();
  });

  test('sampler rejects invalid anchors without consuming random numbers', () {
    final module = ModuleRegistry().byId('mandelbrot');
    final rng = _ConstantRandom(0.5);
    for (final zoom in [double.nan, double.infinity, 0.0, -1.0, 1e13]) {
      expect(
          sampleLooperCamera(
              module: module,
              anchor: _view(x: 0, y: 0, zoom: zoom),
              random: rng),
          isNull);
    }
    for (final pan in [double.nan, double.infinity, 3.1]) {
      expect(
          sampleLooperCamera(
              module: module,
              anchor: _view(x: pan, y: 0, zoom: 1),
              random: rng),
          isNull);
    }
    expect(rng.calls, 0);
  });

  test('sampler clips at module and deep zoom bounds with repeatable draws',
      () {
    final registry = ModuleRegistry();
    final cantor = registry.byId('cantor_set');
    final clipped = sampleLooperCamera(
        module: cantor,
        anchor: _view(x: -3, y: -3, zoom: 0.2),
        random: _ConstantRandom(0))!;
    expect(clipped.zoom, 0.2);
    expect(clipped.pan.x, -3);
    expect(clipped.pan.y, -3);
    final deep = sampleLooperCamera(
        module: registry.byId('mandelbrot'),
        anchor: _view(x: 0, y: 0, zoom: 1e12),
        random: _ConstantRandom(0.999999))!;
    expect(deep.zoom, 1e12);
    expect(deep.pan.x.abs(), lessThanOrEqualTo(0.15 / 1e12));
    final seedA = sampleLooperCamera(
        module: cantor, anchor: clipped, random: math.Random(42))!;
    final seedB = sampleLooperCamera(
        module: cantor, anchor: clipped, random: math.Random(42))!;
    expect(seedA.zoom, seedB.zoom);
    expect(seedA.pan, seedB.pan);
  });

  test('busy and clipped no-change commands preserve preview and frozen plan',
      () {
    final registry = ModuleRegistry();
    final fractal = FractalController(registry);
    fractal.selectModule(registry.byId('cantor_set'), animate: false);
    fractal.updateView(_view(x: -3, y: -3, zoom: 0.2));
    var busy = false;
    final looper =
        LooperController(controller: fractal, exportIsBusy: () => busy);
    looper.setAFromCurrent();
    looper.setBFromCurrent();
    final points = looper.points;
    final plan = looper.plan!;
    looper.play();
    expect(looper.randomizePoint(0, random: _ConstantRandom(0)), isFalse);
    expect(looper.addRandomPoint(random: _ConstantRandom(0)), isFalse);
    expect(looper.isPlaying, isTrue);
    busy = true;
    expect(looper.canRandomizePoints, isFalse);
    final rng = _ConstantRandom(0.5);
    expect(looper.randomizePoint(0, random: rng), isFalse);
    expect(looper.addRandomPoint(random: rng), isFalse);
    expect(rng.calls, 0);
    expect(looper.points, orderedEquals(points));
    expect(plan.points, orderedEquals(points));
    expect(looper.isPlaying, isTrue);
    busy = false;
    expect(looper.randomizePoint(-1), isFalse);
    expect(looper.randomizePoint(2), isFalse);
    looper.dispose();
    fractal.dispose();
  });

  test('looper supports more than A and B keyframes', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);

    for (final x in [0.0, 1.0, 2.0]) {
      fractal.updateView(_view(x: x, y: 0, zoom: 1));
      looper.addPointFromCurrent();
    }

    final plan = looper.plan!;

    expect(looper.points.length, 3);
    expect(plan.stateAtPhase(0).view.pan.x, closeTo(0, 1e-9));
    expect(plan.stateAtPhase(1 / 3).view.pan.x, closeTo(1, 1e-9));
    expect(plan.stateAtPhase(2 / 3).view.pan.x, closeTo(2, 1e-9));
    expect(plan.stateAtPhase(5 / 6).view.pan.x, closeTo(1, 1e-9));

    looper.dispose();
    fractal.dispose();
  });
}

class _ConstantRandom implements math.Random {
  _ConstantRandom(this.value);
  final double value;
  int calls = 0;
  @override
  double nextDouble() {
    calls++;
    return value;
  }

  @override
  bool nextBool() => throw UnimplementedError();
  @override
  int nextInt(int max) => throw UnimplementedError();
}

FractalViewState _view({
  required double x,
  required double y,
  required double zoom,
}) =>
    FractalViewState(
      pan: Vector2(x, y),
      zoom: zoom,
      rotation: Vector3.zero(),
    );
