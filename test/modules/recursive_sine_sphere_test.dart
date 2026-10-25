import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/recursive_sine_sphere_model.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('RecursiveSineSphereModel', () {
    test('uses simultaneous cyclic updates and scaled composition', () {
      final model = RecursiveSineSphereModel(
        depth: 2,
        strength: 1,
        radius: 1,
        phase: 0,
      );
      final q = model.warp(Vector3(0, math.pi / 2, 0));
      expect(q.x, closeTo(1, 1e-12));
      expect(q.y, closeTo(math.pi / 2, 1e-12));
      expect(q.z, closeTo(0.45464871341284085, 1e-12));
      expect(model.lipschitzBound, 4);
      expect(model.enclosureRadius, closeTo(1 + 1.5 * math.sqrt(3), 1e-12));
    });

    test('phase is deterministic and bounded inputs reject invalid values', () {
      final a = RecursiveSineSphereModel(
          depth: 2, strength: 0.8, radius: 1, phase: 0.4);
      final b = RecursiveSineSphereModel(
          depth: 2, strength: 0.8, radius: 1, phase: 0.4);
      final point = Vector3(0.3, -0.2, 0.7);
      expect(a.field(point), closeTo(0.9242376675405959, 1e-12));
      expect(a.field(point), b.field(point));
      expect(
          () => RecursiveSineSphereModel(
              depth: 7, strength: 0.8, radius: 1, phase: 0),
          throwsRangeError);
      expect(
          () => RecursiveSineSphereModel(
              depth: 2, strength: double.nan, radius: 1, phase: 0),
          throwsArgumentError);
      expect(
          () => a.field(Vector3(double.infinity, 0, 0)), throwsArgumentError);
    });

    test('depth zero and strength zero return analytic sphere intersections',
        () {
      for (final model in [
        RecursiveSineSphereModel(depth: 0, strength: 0.8, radius: 1, phase: 0),
        RecursiveSineSphereModel(depth: 3, strength: 0, radius: 1, phase: 1.2),
      ]) {
        expect(model.field(Vector3.zero()), -1);
        final hit = model.intersectRay(
            origin: Vector3(0, 0, 3), direction: Vector3(0, 0, -1));
        expect(hit.status, RecursiveSineRayStatus.hit);
        expect(hit.distance, closeTo(2, 2e-5));
        expect(hit.residual, lessThanOrEqualTo(2e-5));
        final inside = model.intersectRay(
            origin: Vector3.zero(), direction: Vector3(0, 1, 0));
        expect(inside.distance, closeTo(1, 2e-5));
        final tangent = model.intersectRay(
            origin: Vector3(1, 0, 3), direction: Vector3(0, 0, -1));
        expect(tangent.status, RecursiveSineRayStatus.tangent);
        expect(tangent.distance, closeTo(3, 2e-5));
        expect(tangent.residual, lessThanOrEqualTo(2e-5));
        expect(
            model
                .intersectRay(
                    origin: Vector3(1.001, 0, 3), direction: Vector3(0, 0, -1))
                .status,
            RecursiveSineRayStatus.miss);
      }
    });

    test('normal is finite and unit length', () {
      final normal = RecursiveSineSphereModel(
              depth: 3, strength: 0.8, radius: 1, phase: 0.4)
          .normal(Vector3(0.2, 0.3, 0.4));
      expect(
          normal.x.isFinite && normal.y.isFinite && normal.z.isFinite, isTrue);
      expect(normal.length, closeTo(1, 1e-12));
    });

    test('independent brackets determine nearest warped ray crossing', () {
      final model = RecursiveSineSphereModel(
          depth: 2, strength: 0.8, radius: 1, phase: 0.4);
      final firstAxialCrossing = _independentFirstCrossing(
          origin: Vector3(0, 0, 4), direction: Vector3(0, 0, -1));
      final hit = model.intersectRay(
          origin: Vector3(0, 0, 4), direction: Vector3(0, 0, -1));
      expect(hit.status, RecursiveSineRayStatus.hit);
      expect(firstAxialCrossing, closeTo(4.0894271782, 1e-10));
      expect(hit.distance, closeTo(firstAxialCrossing, 5e-5));
      expect(hit.residual, lessThanOrEqualTo(2e-5));
      final offsetOrigin = Vector3(0.3, -0.4, 4);
      final firstOffsetCrossing = _independentFirstCrossing(
          origin: offsetOrigin, direction: Vector3(0, 0, -1));
      final offset = model.intersectRay(
          origin: offsetOrigin, direction: Vector3(0, 0, -1));
      expect(offset.status, RecursiveSineRayStatus.hit);
      expect(firstOffsetCrossing, closeTo(3.9893505716, 1e-10));
      expect(offset.distance, closeTo(firstOffsetCrossing, 5e-5));
      expect(offset.residual, lessThanOrEqualTo(2e-5));
      expect(
          model
              .intersectRay(
                  origin: Vector3(0, 3, 4), direction: Vector3(0, 0, -1))
              .status,
          RecursiveSineRayStatus.unresolved);
    });
  });

  test('controller exposes normalized bounded parameter values', () {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final module = registry.byId('recursive_sine_sphere');
    controller.selectModule(module, animate: false);

    controller.updateParam('depth', 99);
    controller.updateParam('strength', double.nan);
    controller.updateParam('phase', double.infinity);

    expect(controller.module.id, 'recursive_sine_sphere');
    expect(controller.params['depth'], 6);
    expect(controller.params['strength'], 0.8);
    expect(controller.params['phase'], 0.0);
  });

  test('registers one bounded localized GPU module and compiles its shader',
      () async {
    final registry = ModuleRegistry();
    final module = registry.byId('recursive_sine_sphere');
    expect(registry.modules.where((m) => m.id == module.id), hasLength(1));
    expect(module.dimension, FractalDimension.threeD);
    expect(module.animationCapability, FractalAnimationCapability.timeDriven);
    expect(module.defaultPreset.params['depth'], 3);
    expect(module.defaultPreset.params['strength'], 0.8);
    expect(module.defaultPreset.params['radius'], 1.0);
    expect(module.defaultPreset.params['phase'], 0.0);
    expect(
        module.parameters.map((p) => p.id),
        containsAll(
            ['depth', 'strength', 'radius', 'phase', 'steps', 'animate']));
    expect(module.parameters.map((p) => p.id), isNot(contains('power')));
    final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
    final shader = program.fragmentShader();
    module.setUniforms(
        shader,
        FractalRenderState(
            params: module.defaultPreset.params,
            view: module.defaultPreset.view,
            transparentBackground: true),
        const ui.Size(320, 240),
        12);
    shader.dispose();
  });
}

double _independentFirstCrossing({
  required Vector3 origin,
  required Vector3 direction,
}) {
  double scalarField(double distance) {
    var x = origin.x + direction.x * distance;
    var y = origin.y + direction.y * distance;
    var z = origin.z + direction.z * distance;
    for (var level = 0; level < 2; level++) {
      final frequency = math.pow(2, level).toDouble();
      final amplitude = 0.8 / frequency;
      final oldX = x;
      final oldY = y;
      final oldZ = z;
      x = oldX + amplitude * math.sin(frequency * oldY + 0.4);
      y = oldY + amplitude * math.sin(frequency * oldZ + 0.4);
      z = oldZ + amplitude * math.sin(frequency * oldX + 0.4);
    }
    return Vector3(x, y, z).length - 1;
  }

  final enclosure = 1 + math.sqrt(3) * 0.8 * (2 * (1 - math.pow(2, -2)));
  final projection = origin.dot(direction);
  final discriminant =
      projection * projection + enclosure * enclosure - origin.length2;
  final start = math.max(0.0, -projection - math.sqrt(discriminant));
  final end = -projection + math.sqrt(discriminant);
  const intervals = 200000;
  final increment = (end - start) / intervals;
  var low = start;
  var lowValue = scalarField(low);
  for (var index = 1; index <= intervals; index++) {
    var high = start + increment * index;
    final highValue = scalarField(high);
    if ((highValue < 0) != (lowValue < 0)) {
      for (var step = 0; step < 64; step++) {
        final middle = (low + high) * 0.5;
        final middleValue = scalarField(middle);
        if ((middleValue < 0) == (lowValue < 0)) {
          low = middle;
          lowValue = middleValue;
        } else {
          high = middle;
        }
      }
      return (low + high) * 0.5;
    }
    low = high;
    lowValue = highValue;
  }
  throw StateError('no crossing found in the finite ray enclosure');
}
