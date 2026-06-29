import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class CpuFallbackPane extends StatefulWidget {
  final GlobalKey boundaryKey;
  final ui.Image? initialSnapshot;
  final VoidCallback? onSnapshotFadeComplete;

  const CpuFallbackPane({
    super.key,
    required this.boundaryKey,
    this.initialSnapshot,
    this.onSnapshotFadeComplete,
  });

  @override
  State<CpuFallbackPane> createState() => _CpuFallbackPaneState();
}

class _CpuFallbackPaneState extends State<CpuFallbackPane> {
  bool _showSnapshot = true;
  bool _hasSeenPartial = false;

  @override
  void didUpdateWidget(covariant CpuFallbackPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSnapshot != oldWidget.initialSnapshot) {
      _showSnapshot = widget.initialSnapshot != null;
      _hasSeenPartial = false;
    }
  }

  void _handlePartial() {
    if (_hasSeenPartial) return;
    _hasSeenPartial = true;
    if (widget.initialSnapshot == null) return;
    setState(() {
      _showSnapshot = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final module = controller.module;

    if (module.dimension != FractalDimension.twoD) {
      return const Center(
        child: Text(
          '3D fractals are disabled on this device.\n(Mandelbulb shader load stalls.)',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    final state = FractalRenderState(
      params: controller.params,
      view: controller.view,
      transparentBackground: controller.transparentBackground,
    );

    return RepaintBoundary(
      key: widget.boundaryKey,
      child: Stack(
        children: [
          Positioned.fill(
            child: _DeterministicVisibleFallbackScene(
              transparentBackground: controller.transparentBackground,
            ),
          ),
          Positioned.fill(
            child: CpuFractalRenderer(
              module: module,
              state: state,
              onPartial: _handlePartial,
            ),
          ),
          if (widget.initialSnapshot != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showSnapshot ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  onEnd: () {
                    if (!_showSnapshot) {
                      widget.onSnapshotFadeComplete?.call();
                    }
                  },
                  child: RawImage(
                    image: widget.initialSnapshot,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Stable renderer active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CpuFallbackBanner extends StatelessWidget {
  final VoidCallback onTryGpu;
  final VoidCallback onReport;

  const CpuFallbackBanner({
    super.key,
    required this.onTryGpu,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CPU fallback enabled (GPU output appeared black).',
            style: TextStyle(color: Colors.amber, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onTryGpu,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: Text(AppLocalizations.of(context)!.cpuFallbackTryGpu),
              ),
              OutlinedButton(
                onPressed: onReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.8)),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: Text(AppLocalizations.of(context)!.cpuFallbackReport),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeterministicVisibleFallbackScene extends StatelessWidget {
  const _DeterministicVisibleFallbackScene(
      {required this.transparentBackground});

  final bool transparentBackground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DeterministicVisibleFallbackPainter(
        transparentBackground: transparentBackground,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DeterministicVisibleFallbackPainter extends CustomPainter {
  const _DeterministicVisibleFallbackPainter(
      {required this.transparentBackground});

  final bool transparentBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF102A43),
          Color(0xFF2E5B8A),
          Color(0xFF6A4C93),
          Color(0xFFF15BB5),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.18);

    final c = Offset(size.width * 0.5, size.height * 0.52);
    for (double r = 22; r < size.shortestSide * 0.6; r += 24) {
      canvas.drawCircle(c, r, stroke);
    }

    // Checkerboard is useful only when previewing transparency (export).
    // In normal viewing it looks noisy and reduces perceived quality.
    if (transparentBackground) {
      final checkerA = Paint()..color = const Color(0x22000000);
      final checkerB = Paint()..color = const Color(0x22FFFFFF);
      const cell = 26.0;
      for (double y = 0; y < size.height; y += cell) {
        for (double x = 0; x < size.width; x += cell) {
          final even = ((x / cell).floor() + (y / cell).floor()) % 2 == 0;
          canvas.drawRect(
            Rect.fromLTWH(x, y, cell, cell),
            even ? checkerA : checkerB,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
