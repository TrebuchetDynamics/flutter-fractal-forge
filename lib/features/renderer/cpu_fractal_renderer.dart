import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

/// Very small CPU fallback renderer for 2D fractals.
///
/// Purpose: provide a "works everywhere" path when GPU shader output is black.
/// This is intentionally low-res and throttled.
class CpuFractalRenderer extends StatefulWidget {
  final FractalModule module;
  final FractalRenderState state;

  /// Target render resolution (will be scaled to fit).
  final int width;
  final int height;

  const CpuFractalRenderer({
    super.key,
    required this.module,
    required this.state,
    this.width = 320,
    this.height = 640,
  });

  @override
  State<CpuFractalRenderer> createState() => _CpuFractalRendererState();
}

class _CpuFractalRendererState extends State<CpuFractalRenderer> {
  ui.Image? _image;
  Object? _error;
  int _job = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scheduleRender();
  }

  @override
  void didUpdateWidget(covariant CpuFractalRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.module.id != widget.module.id ||
        oldWidget.state.view.zoom != widget.state.view.zoom ||
        oldWidget.state.view.pan != widget.state.view.pan ||
        oldWidget.state.params != widget.state.params) {
      _scheduleRender();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleRender() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), _render);
  }

  Future<void> _render() async {
    final int job = ++_job;
    try {
      final img = await _renderCpu(
        moduleId: widget.module.id,
        viewPan: widget.state.view.pan,
        viewZoom: widget.state.view.zoom,
        iterations: _readInt(widget.state.params, 'iterations', 120),
        bailout: _readDouble(widget.state.params, 'bailout', 4.0),
        juliaC: _juliaC(widget.state.params),
        width: widget.width,
        height: widget.height,
      );
      if (!mounted || job != _job) return;
      setState(() {
        _image = img;
        _error = null;
      });
    } catch (e) {
      if (!mounted || job != _job) return;
      setState(() {
        _image = null;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          'CPU render failed: $_error',
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }
    final img = _image;
    if (img == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: img.width.toDouble(),
        height: img.height.toDouble(),
        child: RawImage(image: img, filterQuality: FilterQuality.none),
      ),
    );
  }
}

Future<ui.Image> _renderCpu({
  required String moduleId,
  required Vector2 viewPan,
  required double viewZoom,
  required int iterations,
  required double bailout,
  required Vector2 juliaC,
  required int width,
  required int height,
}) async {
  // Map screen -> complex plane.
  // Use a sensible default view that shows the set without requiring perfect params.
  final centerX = viewPan.x;
  final centerY = viewPan.y;
  final zoom = viewZoom <= 0 ? 1.0 : viewZoom;

  // For 2D, interpret zoom as magnification; larger => more detail.
  final scale = 3.0 / zoom;

  final bytes = Uint8List(width * height * 4);
  final bailout2 = bailout * bailout;

  for (int y = 0; y < height; y++) {
    final ny = (y / (height - 1)) * 2.0 - 1.0;
    for (int x = 0; x < width; x++) {
      final nx = (x / (width - 1)) * 2.0 - 1.0;

      // Keep aspect ratio.
      final aspect = width / height;
      final cx = centerX + nx * scale * aspect;
      final cy = centerY + ny * scale;

      int it = 0;
      double zx, zy;
      double c0x, c0y;

      if (moduleId == 'julia') {
        zx = cx;
        zy = cy;
        c0x = juliaC.x;
        c0y = juliaC.y;
      } else {
        // mandelbrot, burning_ship, phoenix (fallback to mandelbrot-style)
        zx = 0.0;
        zy = 0.0;
        c0x = cx;
        c0y = cy;
      }

      while (it < iterations) {
        double zx2 = zx * zx;
        double zy2 = zy * zy;
        if (zx2 + zy2 > bailout2) break;

        if (moduleId == 'burning_ship') {
          // z = (|Re(z)| + i|Im(z)|)^2 + c
          final azx = zx.abs();
          final azy = zy.abs();
          final rx = azx * azx - azy * azy + c0x;
          final ry = 2.0 * azx * azy + c0y;
          zx = rx;
          zy = ry;
        } else if (moduleId == 'phoenix') {
          // Very rough phoenix-like variant: z = z^2 + c + p*prev
          // (We don't track prev here; fallback to mandelbrot dynamics.)
          final rx = zx2 - zy2 + c0x;
          final ry = 2.0 * zx * zy + c0y;
          zx = rx;
          zy = ry;
        } else {
          // Mandelbrot / Julia
          final rx = zx2 - zy2 + c0x;
          final ry = 2.0 * zx * zy + c0y;
          zx = rx;
          zy = ry;
        }

        it++;
      }

      final idx = (y * width + x) * 4;
      if (it >= iterations) {
        // inside set
        bytes[idx + 0] = 0;
        bytes[idx + 1] = 0;
        bytes[idx + 2] = 0;
        bytes[idx + 3] = 255;
      } else {
        // simple smooth-ish gradient
        final t = it / iterations;
        final r = (9 * (1 - t) * t * t * t * 255).clamp(0, 255).toInt();
        final g = (15 * (1 - t) * (1 - t) * t * t * 255).clamp(0, 255).toInt();
        final b = (8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255).clamp(0, 255).toInt();
        bytes[idx + 0] = r;
        bytes[idx + 1] = g;
        bytes[idx + 2] = b;
        bytes[idx + 3] = 255;
      }
    }
  }

  final c = Completer<ui.Image>();
  // ignore: deprecated_member_use
  ui.decodeImageFromPixels(
    bytes,
    width,
    height,
    ui.PixelFormat.rgba8888,
    (img) => c.complete(img),
  );
  return c.future;
}

int _readInt(Map<String, Object> params, String key, int fallback) {
  final v = params[key];
  if (v is int) return v;
  if (v is double) return v.round();
  return fallback;
}

double _readDouble(Map<String, Object> params, String key, double fallback) {
  final v = params[key];
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return fallback;
}

Vector2 _juliaC(Map<String, Object> params) {
  final x = _readDouble(params, 'juliaX', -0.7);
  final y = _readDouble(params, 'juliaY', 0.27);
  return Vector2(x, y);
}
