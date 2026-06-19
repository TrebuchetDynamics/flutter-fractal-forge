import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<Uint8List> renderTestShaderFrame({
  required ui.FragmentProgram program,
  required String shaderAsset,
  required int width,
  required int height,
  required List<double> uniforms,
}) async {
  final shader = program.fragmentShader();
  for (var i = 0; i < uniforms.length; i++) {
    shader.setFloat(i, uniforms[i]);
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..shader = shader,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  picture.dispose();
  image.dispose();

  if (bytes == null) {
    throw StateError('Unable to read raw RGBA bytes from $shaderAsset');
  }
  return bytes.buffer.asUint8List();
}
