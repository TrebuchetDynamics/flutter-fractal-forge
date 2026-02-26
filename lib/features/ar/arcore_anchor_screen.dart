import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// ArCoreAnchorScreen
//
// Full-featured ARCore placement screen with glass-morphism UI, multiple
// anchor support, pre-placement size control, share/export, and per-node
// tap-to-remove confirmation.
// ---------------------------------------------------------------------------

class ArCoreAnchorScreen extends StatefulWidget {
  final Uint8List fractalTextureBytes;
  final String? fractalName;

  const ArCoreAnchorScreen({
    super.key,
    required this.fractalTextureBytes,
    this.fractalName,
  });

  /// Returns `true` when the device reports ARCore compatibility.
  ///
  /// This checks capability only. Installation readiness is handled separately
  /// by [isInstalledOnDevice].
  static Future<bool> isSupportedOnDevice() async {
    try {
      final available = await ArCoreController.checkArCoreAvailability();
      return available == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` when ARCore services are already installed and ready.
  ///
  /// We intentionally avoid ARCore install flows that depend on a Play Store
  /// handler because those can crash on emulator/device profiles without one.
  static Future<bool> isInstalledOnDevice() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final installed = await ArCoreController.checkIsArCoreInstalled();
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  @override
  State<ArCoreAnchorScreen> createState() => _ArCoreAnchorScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _ArCoreAnchorScreenState extends State<ArCoreAnchorScreen>
    with TickerProviderStateMixin {
  // -- ARCore --
  ArCoreController? _controller;
  final List<String> _placedNodeNames = <String>[];

  bool _planeDetected = false;
  bool _isPlacing = false;
  bool _planeRendererVisible = true;
  bool _panelExpanded = false;
  bool _showScanTips = false;

  // -- Size slider (meters) --
  double _placementSize = 0.45;
  static const double _minSize = 0.15;
  static const double _maxSize = 1.50;

  // -- Scanning reticle animation --
  late final AnimationController _reticleController;

  // -- Pulsing dot animation for scanning status --
  late final AnimationController _pulseController;

  // -- Scan tips timer --
  Timer? _scanTipsTimer;

  // -- Node removal confirmation --
  String? _pendingRemoveNode;

  // -- Theme constants --
  static const Color _cyanAccent = Color(0xFF00BCD4);

  @override
  void initState() {
    super.initState();
    _reticleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanTipsTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_planeDetected) {
        setState(() => _showScanTips = true);
      }
    });
  }

  @override
  void dispose() {
    _scanTipsTimer?.cancel();
    _reticleController.dispose();
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final fractalController = context.watch<FractalController>();
    final displayName = widget.fractalName ?? fractalController.module.id;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // -- AR camera view --
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
            enableUpdateListener: true,
            debug: false,
          ),

          // -- Safety banner (always visible) --
          _buildSafetyBanner(context),

          // -- Scanning reticle (center, fades out once plane found) --
          if (!_planeDetected) _buildScanningReticle(),

          // -- Scan tips card (appears after 10 s with no plane) --
          if (_showScanTips) _buildScanTips(),

          // -- Top status bar --
          _buildTopBar(context),

          // -- Bottom controls panel --
          _buildBottomPanel(context, displayName),

          // -- Node removal confirmation chip --
          if (_pendingRemoveNode != null) _buildRemoveConfirmationChip(context),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Safety banner
  // -----------------------------------------------------------------------

  Widget _buildSafetyBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 56,
      left: 12,
      right: 12,
      child: Semantics(
        label: l10n.arSafetyBannerLabel,
        child: IgnorePointer(
          child: _GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: _cyanAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.arSafetyBannerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Top status bar
  // -----------------------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Back button (glass pill)
              _GlassPill(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Status chip (center)
              Expanded(child: _buildStatusChip()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final l10n = AppLocalizations.of(context)!;
    final int placed = _placedNodeNames.length;

    // Determine state.
    final _StatusState state;
    if (placed > 0) {
      state = _StatusState.placed;
    } else if (_planeDetected) {
      state = _StatusState.ready;
    } else {
      state = _StatusState.scanning;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _GlassContainer(
        key: ValueKey(state),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(state),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _statusText(state, l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(_StatusState state) {
    switch (state) {
      case _StatusState.scanning:
        // Pulsing cyan dot
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) {
            final opacity = 0.4 + 0.6 * _pulseController.value;
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyanAccent.withValues(alpha: opacity),
              ),
            );
          },
        );
      case _StatusState.ready:
        return const Icon(
          Icons.check_circle_rounded,
          color: _cyanAccent,
          size: 16,
        );
      case _StatusState.placed:
        return const Icon(
          Icons.push_pin_rounded,
          color: _cyanAccent,
          size: 16,
        );
    }
  }

  String _statusText(_StatusState state, AppLocalizations l10n) {
    switch (state) {
      case _StatusState.scanning:
        return l10n.arStatusScanning;
      case _StatusState.ready:
        return l10n.arStatusSurfaceDetected;
      case _StatusState.placed:
        final n = _placedNodeNames.length;
        return n == 1
            ? l10n.arStatusFractalsPlaced(n)
            : l10n.arStatusFractalsPlacedPlural(n);
    }
  }

  // -----------------------------------------------------------------------
  // Scan tips card (shown after 10 s without plane detection)
  // -----------------------------------------------------------------------

  Widget _buildScanTips() {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      left: 24,
      right: 24,
      bottom: 100,
      child: _GlassContainer(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                    color: _cyanAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.arScanTipsTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showScanTips = false),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...[
              l10n.arScanTip1,
              l10n.arScanTip2,
              l10n.arScanTip3,
              l10n.arScanTip4,
            ].map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style:
                            TextStyle(color: _cyanAccent, fontSize: 12)),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Scanning reticle (animated, center)
  // -----------------------------------------------------------------------

  Widget _buildScanningReticle() {
    return Center(
      child: AnimatedOpacity(
        opacity: _planeDetected ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 600),
        child: AnimatedBuilder(
          animation: _reticleController,
          builder: (_, __) {
            return Transform.rotate(
              angle: _reticleController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: _DashedCirclePainter(
                  color: _cyanAccent.withValues(alpha: 0.6),
                  strokeWidth: 2.0,
                  dashCount: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Bottom controls panel
  // -----------------------------------------------------------------------

  Widget _buildBottomPanel(BuildContext context, String displayName) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _panelExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          // -- Collapsed: minimal floating icon bar --
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: _GlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.arTooltipMoreOptions,
                      onPressed: () =>
                          setState(() => _panelExpanded = true),
                      icon: const Icon(Icons.expand_less_rounded,
                          color: Colors.white70, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    const _VerticalDivider(),
                    IconButton(
                      tooltip: l10n.arTooltipShare,
                      onPressed: _shareFractal,
                      icon: const Icon(Icons.share_rounded,
                          color: _cyanAccent, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: l10n.arTooltipSave,
                      onPressed: _saveFractal,
                      icon: const Icon(Icons.save_alt_rounded,
                          color: _cyanAccent, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: l10n.arTooltipClearAll,
                      onPressed:
                          _placedNodeNames.isEmpty ? null : _clearAllNodes,
                      icon: Icon(Icons.delete_sweep_rounded,
                          color: _placedNodeNames.isEmpty
                              ? Colors.white24
                              : _cyanAccent,
                          size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: l10n.arTooltipRescan,
                      onPressed: () async {
                        await _setPlaneRendererVisible(true);
                      },
                      icon: const Icon(Icons.refresh_rounded,
                          color: _cyanAccent, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // -- Expanded: full panel with collapse handle --
          secondChild: _GlassContainer(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapse handle
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _panelExpanded = false),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Icon(Icons.expand_more_rounded,
                          color: Colors.white38, size: 22),
                    ),
                  ),
                ),

                // Row 1: Fractal name
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: _cyanAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Scanning hint OR size slider
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 400),
                  crossFadeState: _planeDetected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: _cyanAccent.withValues(alpha: 0.85),
                          size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.arScanHint,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  secondChild: Row(
                    children: [
                      Text(
                        l10n.arPlacementSize(_placementSize.toStringAsFixed(2)),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _cyanAccent,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.15),
                            thumbColor: _cyanAccent,
                            overlayColor:
                                _cyanAccent.withValues(alpha: 0.2),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                          ),
                          child: Slider(
                            value: _placementSize,
                            min: _minSize,
                            max: _maxSize,
                            onChanged: (v) =>
                                setState(() => _placementSize = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Row 3: Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                        icon: Icons.share_rounded,
                        label: l10n.arActionShare,
                        onPressed: _shareFractal),
                    _ActionButton(
                        icon: Icons.save_alt_rounded,
                        label: l10n.arActionSave,
                        onPressed: _saveFractal),
                    _ActionButton(
                        icon: Icons.delete_sweep_rounded,
                        label: l10n.arActionClear,
                        onPressed: _placedNodeNames.isEmpty
                            ? null
                            : _clearAllNodes),
                    _ActionButton(
                        icon: Icons.refresh_rounded,
                        label: l10n.arActionRescan,
                        onPressed: () async {
                          await _setPlaneRendererVisible(true);
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Node removal confirmation chip
  // -----------------------------------------------------------------------

  Widget _buildRemoveConfirmationChip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      top: _pendingRemoveNode != null
          ? MediaQuery.of(context).padding.top + 70
          : -60,
      left: 0,
      right: 0,
      child: Center(
        child: _GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.arRemoveFractalPrompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              _GlassPill(
                onTap: () => _confirmRemoveNode(true),
                color: _cyanAccent.withValues(alpha: 0.3),
                child: Text(
                  l10n.arConfirmYes,
                  style: const TextStyle(color: _cyanAccent, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              _GlassPill(
                onTap: () => _confirmRemoveNode(false),
                child: Text(
                  l10n.arConfirmNo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveNode(bool confirm) async {
    final name = _pendingRemoveNode;
    if (name == null) return;

    setState(() => _pendingRemoveNode = null);

    if (!confirm) return;

    final controller = _controller;
    if (controller == null) return;

    try {
      await controller.removeNode(nodeName: name);
      _placedNodeNames.remove(name);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.arErrorRemoveNode(e.toString()))),
        );
      }
    }
  }

  // -----------------------------------------------------------------------
  // ARCore callbacks (preserved logic)
  // -----------------------------------------------------------------------

  void _onArCoreViewCreated(ArCoreController controller) {
    _controller = controller;
    controller.onPlaneDetected = (plane) {
      if (!mounted) return;
      _scanTipsTimer?.cancel();
      setState(() {
        _planeDetected = true;
        _showScanTips = false;
      });
    };
    controller.onPlaneTap = _onPlaneTap;
    controller.onError = (text) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.arErrorArCore(text))),
      );
    };
    controller.onNodeTap = (name) {
      if (!mounted) return;
      if (_placedNodeNames.contains(name)) {
        setState(() => _pendingRemoveNode = name);
      }
    };
  }

  Future<void> _onPlaneTap(List<ArCoreHitTestResult> hits) async {
    if (_isPlacing) return;
    if (hits.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.arNoSurfaceHit),
              duration: const Duration(milliseconds: 2000),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

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
        // Use slider-controlled size; thin Z to keep it flat.
        size: vector.Vector3(_placementSize, _placementSize, 0.015),
      );

      final nodeName = 'fractal_${DateTime.now().millisecondsSinceEpoch}';

      // Apply -90 deg X rotation to lay the fractal flat on horizontal
      // surfaces. ARCore hit-pose on a horizontal plane has Y pointing up
      // (plane normal). The cube's visible face is +Z; rotating -90 deg
      // around X maps +Z -> +Y so the fractal image faces upward, lying
      // flat on the detected surface.
      //
      // ArCoreNode.rotation is Vector4(x, y, z, w) quaternion.
      // flatRot = -90 deg around X = (sin(-pi/4), 0, 0, cos(-pi/4))
      //         ~ (-0.7071, 0, 0, 0.7071).
      // combined = hit.pose.rotation * flatRot (standard quaternion product).
      final h = hit.pose.rotation; // Vector4(x, y, z, w)
      const double qs = -0.7071067811865476; // sin(-pi/4)
      const double qc = 0.7071067811865476; // cos(-pi/4)
      final combinedRot = vector.Vector4(
        h.w * qs + h.x * qc, // rx = w1*x2 + x1*w2
        h.y * qc + h.z * qs, // ry = y1*w2 + z1*x2
        h.z * qc - h.y * qs, // rz = z1*w2 - y1*x2
        h.w * qc - h.x * qs, // rw = w1*w2 - x1*x2
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

      // Hide plane renderer after first successful placement for cleaner view.
      if (_planeRendererVisible) {
        await _setPlaneRendererVisible(false);
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.arErrorPlaceFractal(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacing = false;
        });
      }
    }
  }

  // -----------------------------------------------------------------------
  // Plane renderer toggle
  // -----------------------------------------------------------------------

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

  // -----------------------------------------------------------------------
  // Clear all nodes
  // -----------------------------------------------------------------------

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
    _pendingRemoveNode = null;
    await _setPlaneRendererVisible(true);
    if (!mounted) return;
    setState(() {});
  }

  // -----------------------------------------------------------------------
  // Share & save
  // -----------------------------------------------------------------------

  Future<void> _shareFractal() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/fractal_ar_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(widget.fractalTextureBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.arShareText,
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.arErrorShareFailed(e.toString()))),
      );
    }
  }

  Future<void> _saveFractal() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/fractal_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(widget.fractalTextureBytes);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.arSavedTo(file.path))),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.arErrorSaveFailed(e.toString()))),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Status state enum
// ---------------------------------------------------------------------------

enum _StatusState { scanning, ready, placed }

// ---------------------------------------------------------------------------
// Glass-morphism container
// ---------------------------------------------------------------------------

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass pill button
// ---------------------------------------------------------------------------

class _GlassPill extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color? color;

  const _GlassPill({
    required this.onTap,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button (icon + label, bottom panel)
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  static const Color _cyan = Color(0xFF00BCD4);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.3);

    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: enabled ? _cyan : color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed circle painter (scanning reticle)
// ---------------------------------------------------------------------------

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashCount = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;
    final dashArc = (2 * math.pi) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashArc;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashArc,
        false,
        paint,
      );
    }

    // Center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashCount != dashCount;
}
