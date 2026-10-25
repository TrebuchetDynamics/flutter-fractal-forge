// Same-production-kernel readback and an independent retained ray oracle.
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';

import 'package:vector_math/vector_math_64.dart';

const sineKernelFixtureAsset =
    'test/shaders/recursive_sine_sphere_kernel_fixture.frag';

class SineKernelSample {
  const SineKernelSample(this.status, this.distance, this.residual);

  final int status;
  final double distance;
  final double residual;
}

Future<SineKernelSample> runSineKernel({
  required double depth,
  required double strength,
  required double radius,
  required double phase,
  required double budget,
  required Vector3 origin,
  required Vector3 direction,
}) async {
  final program = await ui.FragmentProgram.fromAsset(sineKernelFixtureAsset);
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
  for (var i = 11; i < 19; i++) {
    shader.setFloat(i, 0); // arbitrary-ray mode, never reuse frame uniforms
  }

  final bytes = await _drawKernel(shader, 4, 1);

  int read24(int pixel) {
    final offset = pixel * 4;
    return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
  }

  return SineKernelSample(
    bytes[0],
    read24(1) / 100000,
    read24(2) / 1000000,
  );
}

Future<Uint8List> runSineKernelFrame({
  required Map<String, Object> params,
  required FractalViewState view,
  required int width,
  required int height,
}) async {
  final program = await ui.FragmentProgram.fromAsset(sineKernelFixtureAsset);
  final shader = program.fragmentShader();
  final values = <double>[
    for (final name in ['depth', 'strength', 'radius', 'phase', 'steps'])
      (params[name] as num).toDouble(),
    0, 0, 0, 0, 0, -1, // unused arbitrary ray
    width.toDouble(), height.toDouble(),
    view.rotation.x, view.rotation.y, view.rotation.z,
    view.pan.x, view.pan.y, view.zoom,
  ];
  for (var i = 0; i < values.length; i++) {
    shader.setFloat(i, values[i]);
  }
  return _drawKernel(shader, width, height);
}

Future<Uint8List> _drawKernel(
    ui.FragmentShader shader, int width, int height) async {
  final size = ui.Size(width.toDouble(), height.toDouble());
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
      .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(width, height);
    try {
      final data =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  } finally {
    shader.dispose();
    picture.dispose();
  }
}

double independentSineFirstCrossing(
  Vector3 origin,
  Vector3 direction,
  (double, double)? bracket, {
  int depth = 2,
  double strength = 0.8,
  double radius = 1,
  double phase = 0.4,
}) {
  double scalarField(double t) {
    var x = origin.x + direction.x * t;
    var y = origin.y + direction.y * t;
    var z = origin.z + direction.z * t;
    for (var n = 0; n < depth; n++) {
      final frequency = 1 << n;
      final amplitude = strength / frequency;
      final oldX = x;
      final oldY = y;
      final oldZ = z;
      x = oldX + amplitude * math.sin(frequency * oldY + phase);
      y = oldY + amplitude * math.sin(frequency * oldZ + phase);
      z = oldZ + amplitude * math.sin(frequency * oldX + phase);
    }
    return math.sqrt(x * x + y * y + z * z) - radius;
  }

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
      if (bracket != null && (low < bracket.$1 || high > bracket.$2)) {
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
