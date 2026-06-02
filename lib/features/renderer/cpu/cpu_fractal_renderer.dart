import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import '../validation/render_validation.dart';
import '../validation/convergence_detector.dart';
import 'cpu_render_isolate.dart';
import 'cpu_tile_worker.dart';
import 'cpu_iteration_budget.dart';
import 'cpu_iterators.dart';
import 'cpu_viewport_mapping.dart';

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

  /// Called when a partial CPU frame is available.
  final VoidCallback? onPartial;

  /// Called when slow mode active state changes.
  final ValueChanged<bool>? onSlowModeActiveChanged;

  const CpuFractalRenderer({
    super.key,
    required this.module,
    required this.state,
    this.width = 360,
    this.height = 360,
    this.onPartial,
    this.onSlowModeActiveChanged,
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

  // Convergence detection for adaptive iteration adjustment.
  final ConvergenceDetector _convergenceDetector = const ConvergenceDetector();
  Uint8List? _previousFrameBuffer;
  bool _isConverged = false;

  CpuTileWorker? _worker;

  int? _slowModeRow;
  int? _slowModeTotal;
  bool _slowModeActive = false;

  // Preview vs refine rendering.
  DateTime? _lastInteractionAt;

  @override
  void initState() {
    super.initState();
    _spawnWorker();
  }

  Future<void> _spawnWorker() async {
    try {
      _worker = await CpuTileWorker.spawn();
      if (!mounted) {
        _worker?.dispose();
        return;
      }
      _scheduleRender();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
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
    _setSlowModeActive(false);
    _worker?.dispose();
    _image?.dispose();
    super.dispose();
  }

  void _markInteraction() {
    _lastInteractionAt = DateTime.now();
    // Reset convergence state on new interaction.
    _isConverged = false;
  }

  /// Checks frame-to-frame convergence and updates iteration budget.
  /// Returns adjusted iteration count based on convergence result.
  int _checkConvergence(
      Uint8List currentBuffer, int width, int height, int currentIterations) {
    final prev = _previousFrameBuffer;

    if (prev == null || prev.length != currentBuffer.length) {
      // First frame - store and return current iterations.
      _previousFrameBuffer = Uint8List.fromList(currentBuffer);
      _isConverged = false;
      return currentIterations;
    }

    // Compare with previous frame.
    final result = _convergenceDetector.detect(
      previous: prev,
      current: currentBuffer,
      width: width,
      height: height,
      currentIterations: currentIterations,
    );

    // Store current buffer for next comparison.
    _previousFrameBuffer = Uint8List.fromList(currentBuffer);
    _isConverged = result.converged;

    // Log convergence state in debug mode.
    if (kDebugMode && result.changeRatio > 0.01) {
      debugPrint('[cpu] convergence: converged=${result.converged} '
          'change=${(result.changeRatio * 100).toStringAsFixed(1)}% '
          'iter=$currentIterations->${result.suggestedIterations}');
    }

    // Use suggested iterations for next render if not converged.
    return result.suggestedIterations.clamp(50, _iterationMaxForModule());
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
      // Skip refine pass if the preview frame already converged — no
      // visible change would result from the extra CPU work.
      if (_isConverged) return;
      _renderRefine();
    });
  }

  void _setSlowModeActive(bool active) {
    if (_slowModeActive == active) return;
    if (mounted) {
      setState(() {
        _slowModeActive = active;
      });
    } else {
      _slowModeActive = active;
    }
    widget.onSlowModeActiveChanged?.call(active);
  }

  static const int _tileSize = 96;

  List<(int x0, int y0, int w, int h)> _tileOrder({
    required int width,
    required int height,
  }) {
    final cols = (width / _tileSize).ceil();
    final rows = (height / _tileSize).ceil();

    final startX = (cols - 1) ~/ 2;
    final startY = (rows - 1) ~/ 2;

    final out = <(int, int, int, int)>[];
    final seen = List.generate(rows, (_) => List<bool>.filled(cols, false));

    void addTile(int tx, int ty) {
      if (tx < 0 || ty < 0 || tx >= cols || ty >= rows) return;
      if (seen[ty][tx]) return;
      seen[ty][tx] = true;

      final x0 = tx * _tileSize;
      final y0 = ty * _tileSize;
      final w = (x0 + _tileSize <= width) ? _tileSize : (width - x0);
      final h = (y0 + _tileSize <= height) ? _tileSize : (height - y0);
      if (w <= 0 || h <= 0) return;
      out.add((x0, y0, w, h));
    }

    // Classic spiral walk over the tile grid.
    int x = startX;
    int y = startY;
    int dx = 1;
    int dy = 0;
    int segmentLen = 1;
    int segmentPassed = 0;
    int segments = 0;

    while (out.length < cols * rows) {
      addTile(x, y);
      x += dx;
      y += dy;
      segmentPassed++;

      if (segmentPassed == segmentLen) {
        segmentPassed = 0;
        // rotate right
        final ndx = -dy;
        final ndy = dx;
        dx = ndx;
        dy = ndy;
        segments++;
        if (segments % 2 == 0) segmentLen++;
      }

      // Safety: break if we somehow loop forever.
      if (segmentLen > cols + rows + 4) break;
    }

    return out;
  }

  Future<CpuRenderFrame> _renderFrameTiled({
    required int width,
    required int height,
    required int iterations,
    required double bailout,
    required Vector2 juliaC,
    required int sampleCount,
    required int job,
    required Duration? maxTime,
    required ValueChanged<ui.Image> onPartial,
  }) async {
    final full = Uint8List(width * height * 4);
    // Start with an opaque background so partial-tile progressive updates don't
    // look like "missing" regions (transparent pixels showing the UI behind).
    for (int i = 3; i < full.length; i += 4) {
      full[i] = 255;
    }
    final started = DateTime.now();

    int tilesDone = 0;
    DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

    for (final tile in _tileOrder(width: width, height: height)) {
      if (!mounted || job != _job) break;

      if (maxTime != null && DateTime.now().difference(started) > maxTime) {
        break;
      }

      final req = CpuTileRenderRequest(
        moduleId: widget.module.id,
        panX: widget.state.view.pan.x,
        panY: widget.state.view.pan.y,
        zoom: widget.state.view.zoom,
        iterations: iterations,
        bailout: bailout,
        juliaCX: juliaC.x,
        juliaCY: juliaC.y,
        fullWidth: width,
        fullHeight: height,
        x0: tile.$1,
        y0: tile.$2,
        w: tile.$3,
        h: tile.$4,
        sampleCount: sampleCount,
      );

      final worker = _worker;
      if (worker == null)
        return CpuRenderFrame(rgba: full, width: width, height: height);
      final resp = await worker.renderTile(req);

      // Blit tile into full buffer.
      for (int ty = 0; ty < resp.h; ty++) {
        final dstRow = ((resp.y0 + ty) * width + resp.x0) * 4;
        final srcRow = (ty * resp.w) * 4;
        full.setRange(
          dstRow,
          dstRow + resp.w * 4,
          resp.rgba,
          srcRow,
        );
      }

      tilesDone++;

      // Progressive UI update (throttled).
      final now = DateTime.now();
      final shouldUpdate = tilesDone == 1 ||
          tilesDone % 6 == 0 ||
          now.difference(lastUpdate) > const Duration(milliseconds: 80);
      if (shouldUpdate) {
        lastUpdate = now;
        final img =
            await CpuRenderFrame(rgba: full, width: width, height: height)
                .toImage();
        if (!mounted || job != _job) break;
        onPartial(img);
      }
    }

    return CpuRenderFrame(rgba: full, width: width, height: height);
  }

  Future<void> _renderPass({
    required double resolutionScale,
    required int sampleCount,
    Duration? maxTime,
    bool isPreview = false,
  }) async {
    final int job = ++_job;
    try {
      final baseIterations = readInt(widget.state.params, 'iterations', 220);
      final maxIterations = _iterationMaxForModule();
      final control = cpuControlScalarForModule(
        widget.module.id,
        widget.state.params,
      );
      final juliaC = cpuJuliaCForModule(widget.module.id, widget.state.params);

      // Increase iteration budget as zoom increases to avoid blotchy boundaries.
      final iterations = CpuIterationBudget.forZoom(
        baseIterations: baseIterations,
        maxIterations: maxIterations,
        zoom: widget.state.view.zoom,
      );

      final w = resolutionScale < 1.0
          ? (widget.width * resolutionScale).round().clamp(200, widget.width)
          : widget.width;
      final h = resolutionScale < 1.0
          ? (widget.height * resolutionScale).round().clamp(200, widget.height)
          : widget.height;

      var frame = await _renderFrameTiled(
        width: w,
        height: h,
        iterations: iterations,
        bailout: control,
        juliaC: juliaC,
        sampleCount: sampleCount,
        job: job,
        maxTime: maxTime,
        onPartial: (img) {
          if (!mounted || job != _job) return;
          final oldImage = _image;
          setState(() {
            _image = img;
            _error = null;
          });
          oldImage?.dispose();
          widget.onPartial?.call();
        },
      );

      // Ensure user always sees something.
      if (_isNearlyBlack(frame.rgba)) {
        final fallback = _fallbackView(widget.module);
        final req = CpuTileRenderRequest(
          moduleId: widget.module.id,
          panX: fallback.$1.x,
          panY: fallback.$1.y,
          zoom: fallback.$2,
          iterations: iterations,
          bailout: control,
          juliaCX: juliaC.x,
          juliaCY: juliaC.y,
          fullWidth: w,
          fullHeight: h,
          x0: 0,
          y0: 0,
          w: w,
          h: h,
          sampleCount: 1,
        );
        final worker = _worker;
        if (worker != null) {
          final resp = await worker.renderTile(req);
          frame = CpuRenderFrame(rgba: resp.rgba, width: w, height: h);
        }
      }

      final img = await frame.toImage();

      if (isPreview) {
        // Always run convergence check after preview pass.
        // On first frame _checkConvergence stores the buffer and returns;
        // on subsequent frames it compares and updates _isConverged.
        _checkConvergence(frame.rgba, frame.width, frame.height, iterations);

        // Optional validation only in debug builds.
        RenderCheckResult? validation;
        if (kDebugMode) {
          final probe = await _renderFrameTiled(
            width: w,
            height: h,
            iterations: iterations + 16,
            bailout: control,
            juliaC: juliaC,
            sampleCount: 1,
            job: job,
            maxTime: null,
            onPartial: (_) {},
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
        final oldImage = _image;
        setState(() {
          _image = img;
          _error = null;
          _lastValidation = validation;
        });
        oldImage?.dispose();
      } else {
        // Refine pass completion.
        if (!mounted || job != _job) return;
        final oldImage = _image;
        setState(() {
          _image = img;
          _error = null;
          _slowModeRow = null;
          _slowModeTotal = null;
        });
        oldImage?.dispose();

        // Start slow mode after refine completes.
        _renderSlowMode();
      }
    } catch (e) {
      if (!mounted || job != _job) return;
      final oldImage = _image;
      setState(() {
        _image = null;
        _error = e;
      });
      oldImage?.dispose();
    }
  }

  Future<void> _renderPreview() => _renderPass(
        resolutionScale: 0.8,
        sampleCount: 1,
        maxTime: const Duration(milliseconds: 140),
        isPreview: true,
      );

  Future<void> _renderRefine() => _renderPass(
        resolutionScale: 1.0,
        sampleCount: 4,
        maxTime: null,
        isPreview: false,
      );

  Future<void> _renderSlowMode() async {
    final int job = ++_job;
    _setSlowModeActive(true);

    try {
      final w = (widget.width * 2).clamp(400, 2160);
      final h = (widget.height * 2).clamp(400, 3840);
      final buffer = Uint8List(w * h * 4);
      for (int i = 3; i < buffer.length; i += 4) {
        buffer[i] = 255;
      }

      final baseIterations = readInt(widget.state.params, 'iterations', 220);
      final maxIterations = _iterationMaxForModule();
      final control = cpuControlScalarForModule(
        widget.module.id,
        widget.state.params,
      );
      final juliaC = cpuJuliaCForModule(widget.module.id, widget.state.params);
      final iterations = CpuIterationBudget.forZoom(
        baseIterations: baseIterations,
        maxIterations: maxIterations,
        zoom: widget.state.view.zoom,
      );

      for (int row = 0; row < h; row++) {
        if (!mounted || job != _job) {
          _setSlowModeActive(false);
          return;
        }

        final req = CpuTileRenderRequest(
          moduleId: widget.module.id,
          panX: widget.state.view.pan.x,
          panY: widget.state.view.pan.y,
          zoom: widget.state.view.zoom,
          iterations: iterations,
          bailout: control,
          juliaCX: juliaC.x,
          juliaCY: juliaC.y,
          fullWidth: w,
          fullHeight: h,
          x0: 0,
          y0: row,
          w: w,
          h: 1,
          sampleCount: 4,
        );

        final worker = _worker;
        if (worker == null) {
          _setSlowModeActive(false);
          return;
        }
        final resp = await worker.renderTile(req);

        final dstOffset = row * w * 4;
        buffer.setRange(dstOffset, dstOffset + w * 4, resp.rgba);

        if (row % 8 == 0 || row == h - 1) {
          final img =
              await CpuRenderFrame(rgba: buffer, width: w, height: h).toImage();
          if (!mounted || job != _job) {
            _setSlowModeActive(false);
            return;
          }
          final oldImage = _image;
          setState(() {
            _image = img;
            _slowModeRow = row;
            _slowModeTotal = h;
            _error = null;
          });
          oldImage?.dispose();
          widget.onPartial?.call();
        }
      }

      if (mounted && job == _job) {
        setState(() {
          _slowModeRow = null;
          _slowModeTotal = null;
        });
      }
      _setSlowModeActive(false);
    } catch (e) {
      _setSlowModeActive(false);
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  bool _isNearlyBlack(Uint8List rgba) {
    final totalPixels = rgba.length ~/ 4;
    final threshold = (totalPixels * 0.005).ceil();
    int nonBlack = 0;
    for (int i = 0; i < rgba.length; i += 4) {
      if (rgba[i] > 8 || rgba[i + 1] > 8 || rgba[i + 2] > 8) {
        nonBlack++;
        if (nonBlack >= threshold) return false;
      }
    }
    return true;
  }

  (Vector2, double) _fallbackView(FractalModule module) {
    // Prefer each module's curated default preset (stable fallback baseline).
    final view = module.defaultPreset.view;
    final zoom = view.zoom > 0 ? view.zoom : 1.0;
    return (Vector2(view.pan.x, view.pan.y), zoom);
  }

  int _iterationMaxForModule() {
    for (final param in widget.module.parameters) {
      if (param.id == 'iterations') {
        return param.max.round();
      }
    }
    return 5000;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;

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
            if (_slowModeRow != null && _slowModeTotal != null)
              Positioned(
                top: (_slowModeRow! / _slowModeTotal! * height),
                left: 0,
                right: 0,
                height: 2,
                child: Container(color: Colors.cyan.withValues(alpha: 0.6)),
              ),
            if (_slowModeActive)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.cyan.withValues(alpha: 0.7)),
                  ),
                  child: const Text(
                    'High Res ✦',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (kDebugMode && _lastValidation != null)
              Positioned(
                left: 10,
                top: 92,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
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
      },
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
  final bytes = renderCpuRectRgba(
    moduleId: moduleId,
    panX: viewPan.x,
    panY: viewPan.y,
    zoom: viewZoom,
    iterations: iterations,
    bailout: bailout,
    juliaCX: juliaC.x,
    juliaCY: juliaC.y,
    fullWidth: width,
    fullHeight: height,
    x0: 0,
    y0: 0,
    w: width,
    h: height,
    sampleCount: sampleCount,
  );

  return CpuRenderFrame(rgba: bytes, width: width, height: height);
}

/// Iteration/escape buffer (palette-independent) for correctness + quality metrics.
///
/// Returns a [Uint16List] with one entry per pixel:
/// - 0..iterations: integer escape iteration count
/// - iterations means "inside" (did not escape)
Future<Uint16List?> renderCpuIterationBuffer({
  required String moduleId,
  required Vector2 viewPan,
  required double viewZoom,
  required int iterations,
  required double bailout,
  required Vector2 juliaC,
  required int width,
  required int height,
}) async {
  final viewport = CpuViewportMapping(
    viewPan: viewPan,
    viewZoom: viewZoom,
    width: width,
    height: height,
  );

  final itFn = proxyIteratorForModule(moduleId);

  final out = Uint16List(width * height);
  for (int y = 0; y < height; y++) {
    final ny = viewport.normalizedPixel(y, height);
    for (int x = 0; x < width; x++) {
      final nx = viewport.normalizedPixel(x, width);
      final c = viewport.coordinate(nx: nx, ny: ny);
      final r = itFn(c.$1, c.$2, iterations, bailout, juliaC);
      out[y * width + x] = r.it.clamp(0, iterations);
    }
  }

  return out;
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

/// Module-aware control scalar for CPU formulas.
///
/// Most formulas use `bailout`; Nova uses `relaxation` in that slot.
double cpuControlScalarForModule(String moduleId, Map<String, Object> params) {
  if (moduleId == 'nova') {
    return readDouble(params, 'relaxation', 1.0);
  }
  return readDouble(params, 'bailout', 4.0);
}

/// Module-aware complex parameter passed to CPU formulas.
///
/// Julia-family formulas read `juliaC*`; Phoenix reads `phoenixC*`.
Vector2 cpuJuliaCForModule(String moduleId, Map<String, Object> params) {
  if (moduleId == 'phoenix') {
    final x = readDouble(params, 'phoenixCReal', 0.5667);
    final y = readDouble(params, 'phoenixCImag', 0.0);
    return Vector2(x, y);
  }

  final x = readDouble(params, 'juliaCReal', -0.8);
  final y = readDouble(params, 'juliaCImag', 0.156);
  return Vector2(x, y);
}
