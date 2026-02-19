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
      // Do NOT call checkIsArCoreInstalled() here: that API triggers an
      // install/update prompt from a non-AR context in this legacy plugin.
      // We only gate by compatibility and let ArCoreView handle service flow.
      return available == true;
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
  bool _planeRendererVisible = true;
  int _planeCount = 0;

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
                          ? 'Anchored — fractal flat on surface'
                          : (_planeDetected
                              ? 'Tap surface to place · $_planeCount plane${_planeCount == 1 ? '' : 's'} found'
                              : 'Scan slowly to detect a flat surface'),
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
                      onPressed: () async {
                        await _setPlaneRendererVisible(true);
                        if (!mounted) return;
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

  Future<void> _setPlaneRendererVisible(bool visible) async {
    final controller = _controller;
    if (controller == null) return;
    if (_planeRendererVisible == visible) return;

    try {
      await controller.togglePlaneRenderer();
      _planeRendererVisible = visible;
    } catch (_) {
      // Best effort only.
    }
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _controller = controller;
    controller.onPlaneDetected = (plane) {
      if (!mounted) return;
      setState(() {
        _planeCount++;
        _planeDetected = true;
      });
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

    // Prefer the closest hit to reduce accidental distant placement.
    final hit = hits.reduce((a, b) => a.distance <= b.distance ? a : b);
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
        // Slightly thicker plane improves visibility and avoids z-fighting.
        size: vector.Vector3(0.45, 0.45, 0.015),
      );

      final nodeName = 'fractal_${DateTime.now().millisecondsSinceEpoch}';

      // Apply -90° X rotation to lay the fractal flat on horizontal surfaces.
      // ARCore hit-pose on a horizontal plane has Y pointing up (plane normal).
      // The cube's visible face is +Z; rotating -90° around X maps +Z→+Y so
      // the fractal image faces upward, lying flat on the detected surface.
      //
      // ArCoreNode.rotation is Vector4(x,y,z,w) quaternion.
      // flatRot = -90° around X = (sin(-π/4), 0, 0, cos(-π/4)) ≈ (-0.7071, 0, 0, 0.7071).
      // combined = hit.pose.rotation * flatRot (standard quaternion product).
      final h = hit.pose.rotation; // Vector4(x, y, z, w)
      const double qs = -0.7071067811865476; // sin(-π/4)
      const double qc = 0.7071067811865476; // cos(-π/4)
      final combinedRot = vector.Vector4(
        h.w * qs + h.x * qc, // rx = w1·x2 + x1·w2
        h.y * qc + h.z * qs, // ry = y1·w2 + z1·x2
        h.z * qc - h.y * qs, // rz = z1·w2 - y1·x2
        h.w * qc - h.x * qs, // rw = w1·w2 - x1·x2
      );

      // Lift slightly above detected plane to avoid depth fighting.
      final anchoredPosition = vector.Vector3.copy(hit.pose.translation)
        ..y += 0.004;

      final node = ArCoreNode(
        name: nodeName,
        shape: shape,
        position: anchoredPosition,
        rotation: combinedRot,
      );

      await controller.addArCoreNodeWithAnchor(node);
      _placedNodeNames.add(nodeName);

      // Hide plane renderer after successful placement so anchor reads stable.
      await _setPlaneRendererVisible(false);

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
    await _setPlaneRendererVisible(true);
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
