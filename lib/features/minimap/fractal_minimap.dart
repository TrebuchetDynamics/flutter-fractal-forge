import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../../core/modules/fractal_module.dart';
import '../renderer/providers/fractal_provider.dart';

/// A minimap overlay showing the current viewport position within a fractal.
class FractalMiniMap extends StatelessWidget {
  final Size viewportSize;
  final double size;
  final bool show3DIndicator;

  const FractalMiniMap({
    super.key,
    required this.viewportSize,
    this.size = 120,
    this.show3DIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FractalController>(
      builder: (context, controller, _) {
        final viewState = controller.view;
        final is3D = controller.module.dimension == FractalDimension.threeD;

        if (is3D && show3DIndicator) {
          // For 3D fractals, show zoom indicator only
          return _ZoomIndicator(zoom: viewState.zoom);
        }

        return GestureDetector(
          onTapDown: (details) => _handleTap(context, controller, details.localPosition),
          onPanUpdate: (details) => _handleTap(context, controller, details.localPosition),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(
              children: [
                // Grid lines
                CustomPaint(
                  size: Size(size, size),
                  painter: _GridPainter(),
                ),
                // Viewport rectangle
                CustomPaint(
                  size: Size(size, size),
                  painter: _ViewportPainter(
                    pan: Offset(viewState.pan.x, viewState.pan.y),
                    zoom: viewState.zoom,
                    viewportSize: viewportSize,
                  ),
                ),
                // Center dot
                Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
                // Zoom indicator
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: _ZoomPill(zoom: viewState.zoom),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, FractalController controller, Offset localPosition) {
    // Convert tap position to fractal coordinates
    final normalizedX = (localPosition.dx / size) - 0.5;
    final normalizedY = (localPosition.dy / size) - 0.5;
    
    // Scale by some reasonable factor based on current zoom
    final scale = 2.0 / controller.view.zoom;
    final newPan = vm.Vector2(normalizedX * scale, normalizedY * scale);
    
    controller.updatePan(newPan);
  }
}

class _ZoomIndicator extends StatelessWidget {
  final double zoom;
  const _ZoomIndicator({required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Zoom: ${zoom.toStringAsFixed(1)}×',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _ZoomPill extends StatelessWidget {
  final double zoom;
  const _ZoomPill({required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${zoom.toStringAsFixed(0)}×',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;

    // Draw grid
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ViewportPainter extends CustomPainter {
  final Offset pan;
  final double zoom;
  final Size viewportSize;

  _ViewportPainter({
    required this.pan,
    required this.zoom,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Calculate viewport rectangle
    // The viewport in fractal space is roughly 2/zoom wide (for a -1 to 1 base range)
    final viewportWidth = (2.0 / zoom) * (size.width / 4);
    final viewportHeight = (2.0 / zoom) * (size.height / 4);
    
    // Pan offset
    final centerX = size.width / 2 + pan.dx * size.width / 4;
    final centerY = size.height / 2 + pan.dy * size.height / 4;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: viewportWidth.clamp(4.0, size.width),
      height: viewportHeight.clamp(4.0, size.height),
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewportPainter oldDelegate) {
    return pan != oldDelegate.pan || zoom != oldDelegate.zoom;
  }
}
