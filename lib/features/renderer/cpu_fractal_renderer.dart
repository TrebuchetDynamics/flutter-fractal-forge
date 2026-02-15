import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_fractals/features/renderer/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';

/// Very small CPU fallback renderer for 2D fractals.
///
/// Deep-zoom quality path:
/// - Uses double-precision math on CPU for stable deep zoom coordinates.
/// - Uses multi-sample anti-aliasing (2x2) to reduce grain/noise.
/// - Uses smooth/continuous escape-time coloring.
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
    this.width = 360,
    this.height = 360,
  });

  @override
  State<CpuFractalRenderer> createState() => _CpuFractalRendererState();
}

class _CpuFractalRendererState extends State<CpuFractalRenderer> {
  ui.Image? _image;
  Object? _error;
  int _job = 0;
  Timer? _debounce;
  Timer? _refineTimer;
  RenderCheckResult? _lastValidation;

  // Preview vs refine rendering.
  DateTime? _lastInteractionAt;

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
      _markInteraction();
      _scheduleRender();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _refineTimer?.cancel();
    super.dispose();
  }

  void _markInteraction() {
    _lastInteractionAt = DateTime.now();
  }

  bool _shouldStillBeInteracting() {
    final t = _lastInteractionAt;
    if (t == null) return false;
    return DateTime.now().difference(t) < const Duration(milliseconds: 220);
  }

  void _scheduleRender() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 60), _renderPreview);

    // Schedule a refine pass after user stops touching.
    _refineTimer?.cancel();
    _refineTimer = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      if (_shouldStillBeInteracting()) {
        // Still moving; we'll get rescheduled by later updates.
        return;
      }
      _renderRefine();
    });
  }

  Future<CpuRenderFrame> _renderFrame({
    required int width,
    required int height,
    required int iterations,
    required double bailout,
    required Vector2 juliaC,
    required int sampleCount,
  }) async {
    final req = CpuRenderRequest(
      moduleId: widget.module.id,
      panX: widget.state.view.pan.x,
      panY: widget.state.view.pan.y,
      zoom: widget.state.view.zoom,
      iterations: iterations,
      bailout: bailout,
      juliaCX: juliaC.x,
      juliaCY: juliaC.y,
      width: width,
      height: height,
      sampleCount: sampleCount,
    );

    final resp = await Isolate.run(() => renderCpuFrameInIsolate(req));
    return CpuRenderFrame(rgba: resp.rgba, width: resp.width, height: resp.height);
  }

  Future<void> _renderPreview() async {
    final int job = ++_job;
    try {
      final iterations = _readInt(widget.state.params, 'iterations', 220);
      final bailout = _readDouble(widget.state.params, 'bailout', 4.0);
      final juliaC = _juliaC(widget.state.params);

      // During interaction we render a smaller buffer for speed.
      final w = (widget.width * 0.8).round().clamp(200, widget.width);
      final h = (widget.height * 0.8).round().clamp(200, widget.height);

      var frame = await _renderFrame(
        width: w,
        height: h,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        sampleCount: 1,
      );

      // Ensure user always sees something.
      if (_isNearlyBlack(frame.rgba)) {
        final fallback = _fallbackView(widget.module.id);
        final req = CpuRenderRequest(
          moduleId: widget.module.id,
          panX: fallback.$1.x,
          panY: fallback.$1.y,
          zoom: fallback.$2,
          iterations: iterations,
          bailout: bailout,
          juliaCX: juliaC.x,
          juliaCY: juliaC.y,
          width: w,
          height: h,
          sampleCount: 1,
        );
        final resp = await Isolate.run(() => renderCpuFrameInIsolate(req));
        frame = CpuRenderFrame(rgba: resp.rgba, width: resp.width, height: resp.height);
      }

      final img = await frame.toImage();

      // Optional validation only in debug builds.
      RenderCheckResult? validation;
      if (kDebugMode) {
        final probe = await _renderFrame(
          width: w,
          height: h,
          iterations: iterations + 16,
          bailout: bailout,
          juliaC: juliaC,
          sampleCount: 1,
        );
        validation = validateRenderPair(
          frameA: frame.rgba,
          frameB: probe.rgba,
          width: frame.width,
          height: frame.height,
        );
        debugPrint(validation.summary('cpu'));
      }

      if (!mounted || job != _job) return;
      setState(() {
        _image = img;
        _error = null;
        _lastValidation = validation;
      });
    } catch (e) {
      if (!mounted || job != _job) return;
      setState(() {
        _image = null;
        _error = e;
      });
    }
  }

  Future<void> _renderRefine() async {
    final int job = ++_job;
    try {
      final iterations = _readInt(widget.state.params, 'iterations', 220);
      final bailout = _readDouble(widget.state.params, 'bailout', 4.0);
      final juliaC = _juliaC(widget.state.params);

      // When the user stops, refine at full widget resolution.
      final w = widget.width;
      final h = widget.height;

      var frame = await _renderFrame(
        width: w,
        height: h,
        iterations: iterations,
        bailout: bailout,
        juliaC: juliaC,
        sampleCount: 1,
      );

      if (_isNearlyBlack(frame.rgba)) {
        final fallback = _fallbackView(widget.module.id);
        final req = CpuRenderRequest(
          moduleId: widget.module.id,
          panX: fallback.$1.x,
          panY: fallback.$1.y,
          zoom: fallback.$2,
          iterations: iterations,
          bailout: bailout,
          juliaCX: juliaC.x,
          juliaCY: juliaC.y,
          width: w,
          height: h,
          sampleCount: 1,
        );
        final resp = await Isolate.run(() => renderCpuFrameInIsolate(req));
        frame = CpuRenderFrame(rgba: resp.rgba, width: resp.width, height: resp.height);
      }

      final img = await frame.toImage();

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

  bool _isNearlyBlack(Uint8List rgba) {
    int nonBlack = 0;
    for (int i = 0; i < rgba.length; i += 4) {
      if (rgba[i] > 8 || rgba[i + 1] > 8 || rgba[i + 2] > 8) {
        nonBlack++;
      }
    }
    final ratio = nonBlack / (rgba.length ~/ 4);
    return ratio < 0.005;
  }

  (Vector2, double) _fallbackView(String moduleId) {
    switch (moduleId) {
      case 'burning_ship':
        return (Vector2(-1.75, -0.03), 1.4);
      case 'julia':
        return (Vector2(0.0, 0.0), 1.2);
      case 'buffalo':
      case 'celtic':
      case 'tricorn':
      case 'mandelbrot':
      default:
        return (Vector2(-0.5, 0.0), 1.0);
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
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: img.width.toDouble(),
              height: img.height.toDouble(),
              child: RawImage(image: img, filterQuality: FilterQuality.low),
            ),
          ),
        ),
        if (kDebugMode && _lastValidation != null)
          Positioned(
            left: 10,
            top: 92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CPU check: ${_lastValidation!.pass ? 'PASS' : 'WARN'} ratio=${_lastValidation!.nonBlackRatio.toStringAsFixed(3)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CpuRenderFrame {
  final Uint8List rgba;
  final int width;
  final int height;

  const CpuRenderFrame({
    required this.rgba,
    required this.width,
    required this.height,
  });

  Future<ui.Image> toImage() async {
    final c = Completer<ui.Image>();
    // ignore: deprecated_member_use
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (img) => c.complete(img),
    );
    return c.future;
  }
}

Future<CpuRenderFrame> renderCpuFrame({
  required String moduleId,
  required Vector2 viewPan,
  required double viewZoom,
  required int iterations,
  required double bailout,
  required Vector2 juliaC,
  required int width,
  required int height,
  int sampleCount = 4,
}) async {
  final centerX = viewPan.x;
  final centerY = viewPan.y;
  final zoom = viewZoom <= 0 ? 1.0 : viewZoom;

  final scale = 3.0 / zoom;
  final aspect = width / height;
  final bytes = Uint8List(width * height * 4);
  final samplesPerAxis = math.max(1, math.sqrt(sampleCount).round());
  final totalSamples = samplesPerAxis * samplesPerAxis;

  final formula =
      cpuFormulasByModuleId[moduleId] ?? cpuFormulasByModuleId['mandelbrot']!;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double rAcc = 0;
      double gAcc = 0;
      double bAcc = 0;

      for (int sy = 0; sy < samplesPerAxis; sy++) {
        for (int sx = 0; sx < samplesPerAxis; sx++) {
          final subX = (x + (sx + 0.5) / samplesPerAxis) / (width - 1);
          final subY = (y + (sy + 0.5) / samplesPerAxis) / (height - 1);
          final nx = subX * 2.0 - 1.0;
          final ny = subY * 2.0 - 1.0;

          final cx = centerX + nx * scale * aspect;
          final cy = centerY + ny * scale;

          final color = formula(cx, cy, iterations, bailout, juliaC);
          rAcc += color.$1;
          gAcc += color.$2;
          bAcc += color.$3;
        }
      }

      final idx = (y * width + x) * 4;
      bytes[idx + 0] = (rAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 1] = (gAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 2] = (bAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 3] = 255;
    }
  }

  return CpuRenderFrame(rgba: bytes, width: width, height: height);
}

/// Lower is smoother (less grain).
double computeGrainScore(Uint8List rgba, int width, int height) {
  if (width < 2 || height < 2) return 0;
  double sum = 0;
  int count = 0;

  int at(int x, int y, int c) => rgba[(y * width + x) * 4 + c];

  for (int y = 0; y < height - 1; y++) {
    for (int x = 0; x < width - 1; x++) {
      for (int c = 0; c < 3; c++) {
        final v = at(x, y, c);
        sum += (v - at(x + 1, y, c)).abs();
        sum += (v - at(x, y + 1, c)).abs();
        count += 2;
      }
    }
  }
  return sum / count;
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
  final x = _readDouble(params, 'juliaCReal', -0.8);
  final y = _readDouble(params, 'juliaCImag', 0.156);
  return Vector2(x, y);
}
