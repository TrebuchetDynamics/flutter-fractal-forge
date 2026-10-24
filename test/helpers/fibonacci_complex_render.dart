import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:image/image.dart' as img;

/// Real runtime-effect draw and encoded readback, using the module's setter.
Future<img.Image> drawFibonacciPng(
    FractalModule module, FractalRenderState state,
    {int width = 64,
    int height = 48,
    double time = 0,
    bool invalidC = false,
    String? artifact}) async {
  final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
  final shader = program.fragmentShader();
  module.setUniforms(
      shader, state, ui.Size(width.toDouble(), height.toDouble()), time);
  if (invalidC) shader.setFloat(8, double.nan);
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    final directory = Platform.environment['FIBONACCI_EVIDENCE_DIR'];
    if (directory != null && artifact != null) {
      await Directory(directory).create(recursive: true);
      await File('$directory/$artifact.png').writeAsBytes(bytes);
    }
    return img.decodePng(bytes)!;
  } finally {
    image.dispose();
    picture.dispose();
    shader.dispose();
  }
}

Uint8List rgba(img.Image image) => image.getBytes(order: img.ChannelOrder.rgba);

/// Independent sequence-history oracle: no mutable (z,w) simultaneous update.
/// Small finite fixtures deliberately stay away from radius/precision boundaries.
int referenceUpdate(
    double x, double y, int n, double cr, double ci, double bailout) {
  final history = <(double, double)>[(x, y), (x, y)];
  final radius2 =
      (2 + math.sqrt(cr * cr + ci * ci)).clamp(bailout, double.infinity);
  for (var k = 0; k <= n; k++) {
    final a = history.last;
    final b = history[history.length - 2];
    if (a.$1 * a.$1 + a.$2 * a.$2 > radius2 * radius2 &&
        b.$1 * b.$1 + b.$2 * b.$2 > radius2 * radius2) return k;
    if (k == n) return -1;
    history
        .add((a.$1 * b.$1 - a.$2 * b.$2 + cr, a.$1 * b.$2 + a.$2 * b.$1 + ci));
  }
  throw StateError('unreachable');
}

List<int> referenceRgb(int k) {
  if (k == -1) return [12, 18, 30];
  if (const {1, 2, 3, 5, 9, 11, 15, 21, 27, 41, 45}.contains(k)) {
    return [255, 180 + 5 * (k % 6), 40];
  }
  return [30 + 5 * (k % 6), 90 + 12 * (k % 6), 170 + 12 * (k % 6)];
}
