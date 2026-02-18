import 'dart:typed_data';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

class ArCoreAnchorScreen extends StatefulWidget {
  final Uint8List fractalTextureBytes;

  const ArCoreAnchorScreen({
    super.key,
    required this.fractalTextureBytes,
  });

  static Future<bool> isSupportedOnDevice() async {
    try {
      final available = await ArCoreController.checkArCoreAvailability();
      final installed = await ArCoreController.checkIsArCoreInstalled();
      return available == true && installed == true;
    } catch (_) {
      return false;
    }
  }

  @override
  State<ArCoreAnchorScreen> createState() => _ArCoreAnchorScreenState();
}

class _ArCoreAnchorScreenState extends State<ArCoreAnchorScreen> {
  ArCoreController? _controller;
  final List<String> _placedNodeNames = <String>[];

  bool _planeDetected = false;
  bool _isPlacing = false;
  bool _placementLocked = false;

  @override
  Widget build(BuildContext context) {
    final fractalController = context.watch<FractalController>();

    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
            enableUpdateListener: true,
            debug: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _glassButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusChip(
                      text: _placementLocked
                          ? 'Anchored on plane'
                          : (_planeDetected
                              ? 'Tap plane to place fractal'
                              : 'Move phone to detect a plane'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fractalController.module.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Place again',
                      onPressed: () {
                        setState(() {
                          _placementLocked = false;
                        });
                      },
                      icon: const Icon(Icons.push_pin_rounded,
                          color: Colors.white),
                    ),
                    IconButton(
                      tooltip: 'Clear',
                      onPressed: _clearAllNodes,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _statusChip({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _controller = controller;
    controller.onPlaneDetected = (plane) {
      if (!mounted) return;
      if (!_planeDetected) {
        setState(() {
          _planeDetected = true;
        });
      }
    };
    controller.onPlaneTap = _onPlaneTap;
    controller.onError = (text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ARCore error: $text')),
      );
    };
    controller.onNodeTap = (name) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $name')),
      );
    };
  }

  Future<void> _onPlaneTap(List<ArCoreHitTestResult> hits) async {
    if (_placementLocked || _isPlacing || hits.isEmpty) return;

    final hit = hits.first;
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      _isPlacing = true;
    });

    try {
      final material = ArCoreMaterial(
        color: Colors.white,
        textureBytes: widget.fractalTextureBytes,
        metallic: 0.0,
        roughness: 1.0,
        reflectance: 0.2,
      );

      final shape = ArCoreCube(
        materials: [material],
        size: vector.Vector3(0.45, 0.45, 0.01),
      );

      final nodeName = 'fractal_${DateTime.now().millisecondsSinceEpoch}';
      final node = ArCoreNode(
        name: nodeName,
        shape: shape,
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
      );

      await controller.addArCoreNodeWithAnchor(node);
      _placedNodeNames.add(nodeName);

      if (!mounted) return;
      setState(() {
        _placementLocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fractal anchored to detected plane'),
          duration: Duration(milliseconds: 1200),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place fractal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacing = false;
        });
      }
    }
  }

  Future<void> _clearAllNodes() async {
    final controller = _controller;
    if (controller == null) return;

    for (final name in List<String>.from(_placedNodeNames)) {
      try {
        await controller.removeNode(nodeName: name);
      } catch (_) {
        // Keep clearing remaining nodes.
      }
    }

    _placedNodeNames.clear();
    if (!mounted) return;
    setState(() {
      _placementLocked = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
