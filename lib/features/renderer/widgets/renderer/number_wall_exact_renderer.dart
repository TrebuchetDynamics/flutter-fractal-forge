import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Displays the controller's completed exact field; never computes another wall.
/// The capture boundary exists only for a completed, current field/style.
class NumberWallExactRenderer extends StatefulWidget {
  const NumberWallExactRenderer(
      {super.key,
      this.boundaryKey,
      this.backendMode = RendererBackendMode.auto,
      this.showIndicator = true});

  final GlobalKey? boundaryKey;
  final RendererBackendMode backendMode;
  final bool showIndicator;

  @override
  State<NumberWallExactRenderer> createState() =>
      _NumberWallExactRendererState();
}

class _NumberWallExactRendererState extends State<NumberWallExactRenderer> {
  ui.FragmentShader? _shader;
  bool _shaderFailed = false;
  ui.Image? _image;
  NumberWallGrid? _imageGrid;
  String? _imageStyle;
  String? _requestedStyle;
  NumberWallGrid? _requestedGrid;
  int _textureGeneration = 0;
  int? _row;
  int? _column;

  @override
  void initState() {
    super.initState();
    _loadSampler();
  }

  Future<void> _loadSampler() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
          'shaders/number_theory/number_wall_gpu.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (error) {
      AppLogger.instance.warn('render', 'Number wall sampler unavailable',
          data: {'module': 'number_wall', 'error': error.toString()});
      if (mounted) setState(() => _shaderFailed = true);
    }
  }

  void _syncTexture(NumberWallGrid grid, int mode, int scheme) {
    final style = '$mode|$scheme';
    if (_requestedGrid == grid && _requestedStyle == style) return;
    _requestedGrid = grid;
    _requestedStyle = style;
    final generation = ++_textureGeneration;
    unawaited(Future<void>.microtask(() async {
      if (!mounted || generation != _textureGeneration) return;
      final pixels = Uint8List(grid.columnCount * grid.rowCount * 4);
      var i = 0;
      for (final row in grid.values) {
        for (final value in row) {
          final c = _cellColor(value, grid.prime, mode, scheme);
          pixels[i++] = (c.r * 255).round();
          pixels[i++] = (c.g * 255).round();
          pixels[i++] = (c.b * 255).round();
          pixels[i++] = 255;
        }
      }
      final decoded = Completer<ui.Image>();
      ui.decodeImageFromPixels(pixels, grid.columnCount, grid.rowCount,
          ui.PixelFormat.rgba8888, decoded.complete);
      final image = await decoded.future;
      if (!mounted || generation != _textureGeneration) {
        image.dispose();
        return;
      }
      final previous = _image;
      setState(() {
        _image = image;
        _imageGrid = grid;
        _imageStyle = style;
      });
      previous?.dispose();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final grid = controller.numberWallGrid;
    final mode = (controller.params['colorMode'] as num?)?.toInt() ?? 0;
    final scheme = (controller.params['colorScheme'] as num?)?.toInt() ?? 0;
    if (grid != null && widget.backendMode != RendererBackendMode.cpuOnly) {
      _syncTexture(grid, mode, scheme);
    }
    final image =
        _imageGrid == grid && _imageStyle == '$mode|$scheme' ? _image : null;
    final shader =
        widget.backendMode == RendererBackendMode.cpuOnly ? null : _shader;
    final gpu = shader != null && image != null;
    final unavailable =
        widget.backendMode == RendererBackendMode.gpuOnly && _shaderFailed;
    final ready = grid != null &&
        !controller.numberWallPending &&
        (widget.backendMode != RendererBackendMode.gpuOnly || gpu);
    final status = controller.numberWallPending
        ? l10n.numberWallComputing
        : switch (controller.numberWallStatus) {
            NumberWallPrimeStatus.invalid ||
            NumberWallPrimeStatus.composite =>
              l10n.numberWallRetainedInvalid,
            NumberWallPrimeStatus.unverified =>
              l10n.numberWallRetainedUnverified,
            NumberWallPrimeStatus.cancelled => l10n.numberWallCancelled,
            _ => null,
          };
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final rect = _fieldRect(size, controller.view.zoom, controller.view.pan.x,
          controller.view.pan.y);
      final row = grid == null ? null : _row?.clamp(0, grid.rowCount - 1);
      final column =
          grid == null ? null : _column?.clamp(0, grid.columnCount - 1);
      final description = grid != null && row != null && column != null
          ? l10n.numberWallCell(
              row.toString(),
              (grid.columnStart + column).toString(),
              grid.prime.toString(),
              grid.values[row][column].toString(),
              grid.values[row][column] == BigInt.zero
                  ? l10n.numberWallDivisible
                  : l10n.numberWallNonzero)
          : null;
      final plot = ColoredBox(
        key: const Key('numberWallExactPlot'),
        color: const Color(0xff090b12),
        child: grid == null ||
                unavailable ||
                (widget.backendMode == RendererBackendMode.gpuOnly && !gpu)
            ? const SizedBox.expand()
            : CustomPaint(
                size: Size.infinite,
                painter: _NumberWallPainter(
                    grid: grid,
                    rect: rect,
                    colorMode: mode,
                    colorScheme: scheme,
                    image: gpu ? image : null,
                    shader: gpu ? shader : null)),
      );
      return Focus(
        onKeyEvent: (_, event) {
          if (grid == null || event is! KeyDownEvent)
            return KeyEventResult.ignored;
          final delta = switch (event.logicalKey) {
            LogicalKeyboardKey.arrowLeft => const Offset(-1, 0),
            LogicalKeyboardKey.arrowRight => const Offset(1, 0),
            LogicalKeyboardKey.arrowUp => const Offset(0, -1),
            LogicalKeyboardKey.arrowDown => const Offset(0, 1),
            _ => null,
          };
          if (delta == null) return KeyEventResult.ignored;
          setState(() {
            _row = ((row ?? 0) + delta.dy.toInt()).clamp(0, grid.rowCount - 1);
            _column = ((column ?? 0) + delta.dx.toInt())
                .clamp(0, grid.columnCount - 1);
          });
          return KeyEventResult.handled;
        },
        child: Builder(
            builder: (context) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: grid == null
                      ? null
                      : (details) {
                          Focus.of(context).requestFocus();
                          if (!rect.contains(details.localPosition)) return;
                          setState(() {
                            _column = ((details.localPosition.dx - rect.left) /
                                    rect.width *
                                    grid.columnCount)
                                .floor();
                            _row = ((details.localPosition.dy - rect.top) /
                                    rect.height *
                                    grid.rowCount)
                                .floor();
                          });
                        },
                  child: Stack(fit: StackFit.expand, children: [
                    RepaintBoundary(
                        key: ready ? widget.boundaryKey : null, child: plot),
                    if (widget.showIndicator && grid != null)
                      Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: IgnorePointer(
                              child: Text(
                                  gpu
                                      ? l10n.numberWallExactSampler
                                      : l10n.numberWallExactCanvas,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.black)))),
                    if (unavailable || status != null || grid == null)
                      Center(
                          child: Semantics(
                              liveRegion: true,
                              child: Text(
                                  unavailable
                                      ? l10n.numberWallGpuUnavailable
                                      : status ?? l10n.numberWallComputing,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.black)))),
                    if (description != null)
                      Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: IgnorePointer(
                              child: Semantics(
                                  liveRegion: true,
                                  child: Text(description,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          backgroundColor: Colors.black))))),
                  ]),
                )),
      );
    });
  }

  @override
  void dispose() {
    _textureGeneration++;
    _image?.dispose();
    _shader?.dispose();
    super.dispose();
  }
}

Rect _fieldRect(Size size, double zoom, double panX, double panY) =>
    Rect.fromCenter(
        center:
            Offset(size.width / 2 * (1 + panX), size.height / 2 * (1 + panY)),
        width: size.width * zoom.clamp(0.25, 16),
        height: size.height * zoom.clamp(0.25, 16));

Color _cellColor(BigInt value, BigInt prime, int mode, int scheme) {
  if (value == BigInt.zero) return const Color(0xfff4c95d);
  if (mode == 0) return const Color(0xff20283b);
  final bin = (value * BigInt.from(1536) ~/ prime).toInt();
  return HSVColor.fromAHSV(1, ((bin + scheme * 41) % 360).toDouble(), 0.72,
          0.38 + 0.48 * ((bin % 256) / 255))
      .toColor();
}

class _NumberWallPainter extends CustomPainter {
  const _NumberWallPainter(
      {required this.grid,
      required this.rect,
      required this.colorMode,
      required this.colorScheme,
      this.image,
      this.shader});
  final NumberWallGrid grid;
  final Rect rect;
  final int colorMode, colorScheme;
  final ui.Image? image;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = this.shader;
    if (shader != null && image != null) {
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, grid.columnCount.toDouble())
        ..setFloat(3, grid.rowCount.toDouble())
        ..setFloat(4, rect.left)
        ..setFloat(5, rect.top)
        ..setFloat(6, rect.width)
        ..setFloat(7, rect.height)
        ..setImageSampler(0, image!);
      canvas.drawRect(
          rect,
          Paint()
            ..shader = shader
            ..isAntiAlias = false);
      return;
    }
    final paint = Paint()..isAntiAlias = false;
    for (var row = 0; row < grid.rowCount; row++) {
      for (var column = 0; column < grid.columnCount; column++) {
        paint.color = _cellColor(
            grid.values[row][column], grid.prime, colorMode, colorScheme);
        canvas.drawRect(
            Rect.fromLTRB(
                rect.left + column * rect.width / grid.columnCount,
                rect.top + row * rect.height / grid.rowCount,
                rect.left + (column + 1) * rect.width / grid.columnCount,
                rect.top + (row + 1) * rect.height / grid.rowCount),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NumberWallPainter old) =>
      old.grid != grid ||
      old.rect != rect ||
      old.colorMode != colorMode ||
      old.colorScheme != colorScheme ||
      old.image != image ||
      old.shader != shader;
}
