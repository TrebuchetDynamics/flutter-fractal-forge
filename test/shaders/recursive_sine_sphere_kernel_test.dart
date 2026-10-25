import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

const _kernelFixtureAsset =
    'test/shaders/recursive_sine_sphere_kernel_fixture.frag';

class _KernelSample {
  const _KernelSample(this.status, this.distance, this.residual);

  final int status;
  final double distance;
  final double residual;
}

Future<_KernelSample> _runKernel({
  required double depth,
  required double strength,
  required double radius,
  required double phase,
  required double budget,
  required Vector3 origin,
  required Vector3 direction,
}) async {
  final program = await ui.FragmentProgram.fromAsset(_kernelFixtureAsset);
  final shader = program.fragmentShader();
  shader
    ..setFloat(0, depth)
    ..setFloat(1, strength)
    ..setFloat(2, radius)
    ..setFloat(3, phase)
    ..setFloat(4, budget)
    ..setFloat(5, origin.x)
    ..setFloat(6, origin.y)
    ..setFloat(7, origin.z)
    ..setFloat(8, direction.x)
    ..setFloat(9, direction.y)
    ..setFloat(10, direction.z);

  const size = ui.Size(4, 1);
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Offset.zero & size,
    ui.Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(4, 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  shader.dispose();
  image.dispose();
  picture.dispose();
  final bytes =
      data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  int read24(int pixel) {
    final offset = pixel * 4;
    return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
  }

  return _KernelSample(
    bytes[0],
    read24(1) / 100000,
    read24(2) / 1000000,
  );
}

Future<_KernelSample> _sphereSample({
  required Vector3 origin,
  required Vector3 direction,
}) =>
    _runKernel(
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
      _kernelFixtureAsset,
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
      final reference = _independentFirstCrossing(
        fixture.origin,
        Vector3(0, 0, -1),
        fixture.bracket,
      );
      expect(reference, closeTo(fixture.expected, 1e-10));
      final sample = await _runKernel(
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
    final sample = await _runKernel(
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
    final sample = await _runKernel(
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

  test('shader distinguishes bounded-budget exhaustion from a miss', () async {
    final sample = await _runKernel(
      depth: 6,
      strength: 1,
      radius: 1,
      phase: 0,
      budget: 64,
      origin: Vector3(0, 0, 8),
      direction: Vector3(0, 0, -1),
    );
    expect(sample.status, 2); // unresolved, not certified miss or hit
  });
}

double _independentFirstCrossing(
  Vector3 origin,
  Vector3 direction,
  (double, double) bracket,
) {
  double scalarField(double t) {
    var x = origin.x + direction.x * t;
    var y = origin.y + direction.y * t;
    var z = origin.z + direction.z * t;
    for (var n = 0; n < 2; n++) {
      final frequency = 1 << n;
      final amplitude = 0.8 / frequency;
      final oldX = x;
      final oldY = y;
      final oldZ = z;
      x = oldX + amplitude * math.sin(frequency * oldY + 0.4);
      y = oldY + amplitude * math.sin(frequency * oldZ + 0.4);
      z = oldZ + amplitude * math.sin(frequency * oldX + 0.4);
    }
    return math.sqrt(x * x + y * y + z * z) - 1;
  }

  const radius = 1.0;
  const strength = 0.8;
  const depth = 2;
  final enclosure =
      radius + math.sqrt(3) * strength * (2 * (1 - math.pow(2, -depth)));
  final projection = origin.dot(direction);
  final discriminant =
      projection * projection - origin.length2 + enclosure * enclosure;
  final start = math.max(0.0, -projection - math.sqrt(discriminant));
  final end = -projection + math.sqrt(discriminant);
  final scanIntervals = 200000;
  final increment = (end - start) / scanIntervals;
  var low = start;
  var lowValue = scalarField(low);
  for (var index = 1; index <= scanIntervals; index++) {
    var high = start + increment * index;
    final highValue = scalarField(high);
    if ((highValue < 0) != (lowValue < 0)) {
      if (low < bracket.$1 || high > bracket.$2) {
        throw StateError('the first crossing is outside its retained bracket');
      }
      for (var i = 0; i < 64; i++) {
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
  throw StateError('no crossing found in the ray enclosure');
}
