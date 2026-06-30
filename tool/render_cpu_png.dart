import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';

/// Usage:
///   dart run tool/render_cpu_png.dart --out /tmp/mandelbrot.png
///
/// Optional args:
///   --module mandelbrot
///   --w 512 --h 512
///   --panX -0.5 --panY 0
///   --zoom 1
///   --iters 220
///   --bailout 4
///   --aa 4
void main(List<String> args) async {
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
    String a = args[i];
    String? v = (i + 1 < args.length) ? args[i + 1] : null;
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

  final frame = await renderCpuFrame(
    moduleId: moduleId,
    viewPan: Vector2(panX, panY),
    viewZoom: zoom,
    iterations: iterations,
    bailout: bailout,
    juliaC: Vector2(-0.8, 0.156),
    width: w,
    height: h,
    sampleCount: aa,
  );

  final image = img.Image.fromBytes(
    width: w,
    height: h,
    bytes: frame.rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );

  final bytes = img.encodePng(image, level: 0);
  final f = File(out);
  await f.parent.create(recursive: true);
  await f.writeAsBytes(bytes);

  // ignore: avoid_print
  print('WROTE $out (${bytes.length} bytes) module=$moduleId pan=($panX,$panY) zoom=$zoom iters=$iterations aa=$aa');
}
