import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

/// Debug overlay showing shader uniform values for troubleshooting.
class ShaderDebugOverlay extends StatelessWidget {
  final bool enabled;
  final Size? canvasSize;

  const ShaderDebugOverlay({
    super.key,
    this.enabled = true,
    this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return Consumer<FractalController>(
      builder: (context, controller, _) {
        final view = controller.view;
        final params = controller.params;
        final module = controller.module;

        return Positioned(
          top: 80,
          left: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔧 SHADER DEBUG', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Module: ${module.id}'),
                  Text('Shader: ${module.shaderAsset}'),
                  const Divider(color: Colors.white24, height: 8),
                  const Text('UNIFORMS:', style: TextStyle(color: Colors.cyan)),
                  Text('[0] time: ${DateTime.now().millisecondsSinceEpoch % 10000}'),
                  Text('[1-2] resolution: ${canvasSize?.width.toStringAsFixed(0) ?? "?"} x ${canvasSize?.height.toStringAsFixed(0) ?? "?"}'),
                  Text('[3-4] center: ${view.pan.x.toStringAsFixed(4)}, ${view.pan.y.toStringAsFixed(4)}'),
                  Text('[5] zoom: ${view.zoom.toStringAsFixed(4)}'),
                  Text('[6] iterations: ${params['iterations'] ?? 'null'}'),
                  Text('[7] bailout: ${params['bailout'] ?? 'null'}'),
                  Text('[8] colorScheme: ${params['colorScheme'] ?? 'null'}'),
                  Text('[9] transparentBg: ${controller.transparentBackground ? 1 : 0}'),
                  const Divider(color: Colors.white24, height: 8),
                  const Text('VIEW STATE:', style: TextStyle(color: Colors.green)),
                  Text('pan: (${view.pan.x.toStringAsFixed(6)}, ${view.pan.y.toStringAsFixed(6)})'),
                  Text('zoom: ${view.zoom}'),
                  Text('rotation: (${view.rotation.x.toStringAsFixed(2)}, ${view.rotation.y.toStringAsFixed(2)}, ${view.rotation.z.toStringAsFixed(2)})'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
