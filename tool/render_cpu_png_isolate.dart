import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';

/// Pure-Dart CPU renderer dump (no Flutter engine required).
///
/// Usage:
///   /home/xel/flutter/bin/cache/dart-sdk/bin/dart run tool/render_cpu_png_isolate.dart --out /tmp/cpu.png
void main(List<String> args) {
  String moduleId = 'mandelbrot';
  int w = 512;
  int h = 512;
  double panX = -0.5;
  double panY = 0.0;
  double zoom = 1.0;
  int iters = 220;
  double bailout = 4.0;
  int aa = 4;
  String out = '/tmp/cpu.png';

  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    final v = (i + 1 < args.length) ? args[i + 1] : null;
    if (a == '--module' && v != null) {
      moduleId = v;
      i++;
    } else if (a == '--w' && v != null) {
      w = int.parse(v);
      i++;
    } else if (a == '--h' && v != null) {
      h = int.parse(v);
      i++;
    } else if (a == '--panX' && v != null) {
      panX = double.parse(v);
      i++;
    } else if (a == '--panY' && v != null) {
      panY = double.parse(v);
      i++;
    } else if (a == '--zoom' && v != null) {
      zoom = double.parse(v);
      i++;
    } else if (a == '--iters' && v != null) {
      iters = int.parse(v);
      i++;
    } else if (a == '--bailout' && v != null) {
      bailout = double.parse(v);
      i++;
    } else if (a == '--aa' && v != null) {
      aa = int.parse(v);
      i++;
    } else if (a == '--out' && v != null) {
      out = v;
      i++;
    }
  }

  // Match in-app policy: iterations scale up with zoom.
  final extra = (math.log(math.max(zoom, 1.0)) / math.ln2 * 24.0).round();
  final iterations = (iters + extra).clamp(50, 500);

  final resp = renderCpuFrameInIsolate(
    CpuRenderRequest(
      moduleId: moduleId,
      panX: panX,
      panY: panY,
      zoom: zoom,
      iterations: iterations,
      bailout: bailout,
      juliaCX: -0.8,
      juliaCY: 0.156,
      width: w,
      height: h,
      sampleCount: aa,
    ),
  );

  final image = img.Image.fromBytes(
    width: w,
    height: h,
    bytes: resp.rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );

  final bytes = img.encodePng(image, level: 0);
  final f = File(out);
  f.parent.createSync(recursive: true);
  f.writeAsBytesSync(bytes);

  // ignore: avoid_print
  print('WROTE $out (${bytes.length} bytes) module=$moduleId pan=($panX,$panY) zoom=$zoom iters=$iterations aa=$aa');
}
