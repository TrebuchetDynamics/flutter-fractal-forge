import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/ar_export_service.dart';
import 'package:flutter_fractals/core/services/ar_video_exporter.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/services/exploration_stats_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/ar/arcore_anchor_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'dart:developer' as dev;

enum ArOverlayStylePreset {
  neon,
  soft,
  mono,
}

extension on ArOverlayStylePreset {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ArOverlayStylePreset.neon:
        return l10n.arStyleNeon;
      case ArOverlayStylePreset.soft:
        return l10n.arStyleSoft;
      case ArOverlayStylePreset.mono:
        return l10n.arStyleMono;
    }
  }

  Color outlineColor(Brightness brightness) {
    // Keep it subtle; avoid hard white edges on AMOLED.
    final base = brightness == Brightness.dark ? Colors.white : Colors.black;
    switch (this) {
      case ArOverlayStylePreset.neon:
        return Colors.cyanAccent.withValues(alpha: 0.65);
      case ArOverlayStylePreset.soft:
        return base.withValues(alpha: 0.28);
      case ArOverlayStylePreset.mono:
        return base.withValues(alpha: 0.40);
    }
  }

  Color gridColor(Brightness brightness) {
    final base = brightness == Brightness.dark ? Colors.white : Colors.black;
    switch (this) {
      case ArOverlayStylePreset.neon:
        return Colors.cyanAccent.withValues(alpha: 0.16);
      case ArOverlayStylePreset.soft:
        return base.withValues(alpha: 0.10);
      case ArOverlayStylePreset.mono:
        return base.withValues(alpha: 0.12);
    }
  }

  ColorFilter? colorFilter() {
    switch (this) {
      case ArOverlayStylePreset.neon:
        // Slightly boost luminance so it reads better against camera noise.
        return const ColorFilter.matrix(<double>[
          1.1,
          0,
          0,
          0,
          0,
          0,
          1.1,
          0,
          0,
          0,
          0,
          0,
          1.1,
          0,
          0,
          0,
          0,
          0,
          1.0,
          0,
        ]);
      case ArOverlayStylePreset.soft:
        return null;
      case ArOverlayStylePreset.mono:
        return const ColorFilter.matrix(<double>[
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0,
          0,
          0,
          1.0,
          0,
        ]);
    }
  }
}

class ArOverlayScreen extends StatefulWidget {
  const ArOverlayScreen({Key? key}) : super(key: key);

  @override
  State<ArOverlayScreen> createState() => _ArOverlayScreenState();
}

class _ArOverlayScreenState extends State<ArOverlayScreen> {
  CameraController? _cameraController;
  CameraDescription? _activeCamera;
  late final FractalController _fractalController;
  bool _permissionDenied = false;
  bool _initializing = true;
  bool _exporting = false;
  double? _exportProgress;
  String? _cameraFailureReason;
  bool _hasMultipleCameras = false;

  final GlobalKey _overlayKey = GlobalKey();
  final ExportService _exportService = const ExportService();
  late final ArExportService _arExportService = ArExportService(_exportService);
  final ArVideoExporter _videoExporter = const ArVideoExporter();

  Offset _overlayOffset = Offset.zero;
  double _overlayScale = 1.0;
  double _overlayRotation = 0.0;
  double _overlayOpacity = 0.75;
  bool _overlayLocked = false;
  bool _anchorPlaced = false;
  // In AR, escape-time fractals look best when the interior black set is cut out.
  // Default to transparent for those modules.
  bool _transparentBackground = true;
  bool _panelCollapsed = true;

  bool _showGrid = true;
  bool _showOutline = true;
  ArOverlayStylePreset _stylePreset = ArOverlayStylePreset.neon;

  late ArQualityPreset _qualityPreset;

  double _startScale = 1.0;
  double _startRotation = 0.0;

  bool _previousTransparency = false;

  // Exploration stats tracking
  ExplorationStatsService? _statsService;
  DateTime? _sessionStart;
  double? _lastZoom;
  String? _lastModuleId;

  bool _shouldUseTransparentBackgroundInAr(FractalModule module) {
    if (module.dimension != FractalDimension.twoD) {
      return false;
    }
    final paramIds = module.parameters.map((p) => p.id).toSet();
    return paramIds.contains('iterations') && paramIds.contains('bailout');
  }

  @override
  void initState() {
    super.initState();
    _fractalController = context.read<FractalController>();
    _transparentBackground =
        _shouldUseTransparentBackgroundInAr(_fractalController.module);
    _statsService = context.read<ExplorationStatsService?>();
    _sessionStart = DateTime.now();

    _lastZoom = _fractalController.view.zoom;
    _lastModuleId = _fractalController.module.id;
    _statsService?.recordFractalExplored(_fractalController.module.id);
    _fractalController.addListener(_onFractalChanged);

    _qualityPreset = context.read<ArQualityStore>().getPreset();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Cache controller so dispose doesn't depend on context.
      _previousTransparency = _fractalController.transparentBackground;

      // For escape-time fractals, keep interior black regions transparent in AR.
      _fractalController.setTransparentBackground(_transparentBackground);

      _fractalController.applyArQualityPreset(_qualityPreset);

      // Sensible defaults per dimension.
      final dim = _fractalController.module.dimension;
      if (!mounted) return;
      setState(() {
        if (dim == FractalDimension.threeD) {
          _overlayOpacity = 0.85;
          _overlayScale = 1.0;
          _stylePreset = ArOverlayStylePreset.soft;
        } else {
          _overlayOpacity = 0.70;
          _overlayScale = 1.1;
          _stylePreset = ArOverlayStylePreset.neon;
        }
      });
    });
  }

  Future<void> _initCamera() async {
    dev.log('initCamera: requesting permission', name: 'FF.AR');

    PermissionStatus status;
    try {
      status = await Permission.camera.request();
    } catch (e, st) {
      dev.log('initCamera: permission request failed: $e',
          name: 'FF.AR', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _permissionDenied = false;
        _cameraFailureReason = 'Camera permission check failed: $e';
        _initializing = false;
      });
      return;
    }

    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _cameraFailureReason = null;
        _initializing = false;
      });
      return;
    }

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } catch (e, st) {
      dev.log('initCamera: availableCameras failed: $e',
          name: 'FF.AR', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _hasMultipleCameras = false;
        _permissionDenied = false;
        _cameraFailureReason = 'Could not enumerate cameras: $e';
        _initializing = false;
      });
      return;
    }

    if (cameras.isEmpty) {
      if (!mounted) return;
      setState(() {
        _hasMultipleCameras = false;
        _permissionDenied = false;
        _cameraFailureReason = 'No camera devices were reported by the system.';
        _initializing = false;
      });
      return;
    }

    _hasMultipleCameras = cameras.length > 1;

    final preferred = <CameraDescription>[
      ...cameras.where((c) => c.lensDirection == CameraLensDirection.back),
      ...cameras.where((c) => c.lensDirection == CameraLensDirection.external),
      ...cameras.where((c) => c.lensDirection == CameraLensDirection.front),
    ];

    final presets = <ResolutionPreset>[
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    Object? lastError;
    StackTrace? lastStack;

    for (final camera in preferred) {
      for (final preset in presets) {
        CameraController? candidate;
        try {
          dev.log(
            'initCamera: trying ${camera.name} (${camera.lensDirection.name}) @ ${preset.name}',
            name: 'FF.AR',
          );
          candidate = CameraController(
            camera,
            preset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.yuv420,
          );
          await candidate.initialize();
          if (!mounted) {
            await candidate.dispose();
            return;
          }
          final previous = _cameraController;
          setState(() {
            _cameraController = candidate;
            _activeCamera = camera;
            _cameraFailureReason = null;
            _permissionDenied = false;
            _initializing = false;
          });
          await previous?.dispose();
          dev.log(
            'initCamera: initialized ${camera.name} @ ${preset.name}',
            name: 'FF.AR',
          );
          return;
        } catch (e, st) {
          lastError = e;
          lastStack = st;
          dev.log(
            'initCamera: failed ${camera.name} @ ${preset.name}: $e',
            name: 'FF.AR',
            error: e,
            stackTrace: st,
          );
          try {
            await candidate?.dispose();
          } catch (e) { if (kDebugMode) debugPrint('[FF] silent catch: $e'); }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _permissionDenied = false;
      _cameraFailureReason =
          'Failed to initialize any camera profile. ${lastError ?? 'Unknown error.'}';
      _initializing = false;
    });

    if (lastError != null) {
      dev.log('initCamera: all camera attempts failed',
          name: 'FF.AR', error: lastError, stackTrace: lastStack);
    }
  }

  Future<void> _switchCamera() async {
    if (_initializing || _exporting) return;

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraFailureReason = 'Unable to switch camera: $e';
      });
      return;
    }

    if (cameras.length < 2) {
      return;
    }

    final currentName = _activeCamera?.name;
    var index = cameras.indexWhere((camera) => camera.name == currentName);
    if (index < 0) index = 0;
    final nextCamera = cameras[(index + 1) % cameras.length];

    final presets = <ResolutionPreset>[
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    setState(() {
      _initializing = true;
      _cameraFailureReason = null;
    });

    Object? lastError;
    for (final preset in presets) {
      CameraController? candidate;
      try {
        candidate = CameraController(
          nextCamera,
          preset,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        await candidate.initialize();
        if (!mounted) {
          await candidate.dispose();
          return;
        }
        final previous = _cameraController;
        setState(() {
          _cameraController = candidate;
          _activeCamera = nextCamera;
          _cameraFailureReason = null;
          _initializing = false;
          _hasMultipleCameras = cameras.length > 1;
        });
        await previous?.dispose();
        return;
      } catch (e) {
        lastError = e;
        try {
          await candidate?.dispose();
        } catch (e) { if (kDebugMode) debugPrint('[FF] silent catch: $e'); }
      }
    }

    if (!mounted) return;
    setState(() {
      _cameraFailureReason =
          'Could not switch to camera ${nextCamera.name}: ${lastError ?? 'unknown error'}';
      _initializing = false;
    });
  }

  @override
  void dispose() {
    dev.log('dispose: tearing down AR screen', name: 'FF.AR');

    try {
      _fractalController.removeListener(_onFractalChanged);
    } catch (_) {
      // ignore
    }

    final start = _sessionStart;
    if (start != null) {
      _statsService?.addExploreTime(DateTime.now().difference(start));
    }

    try {
      _cameraController?.dispose();
    } catch (e, st) {
      dev.log('dispose: cameraController dispose failed: $e',
          name: 'FF.AR', error: e, stackTrace: st);
    }

    // Restore prior viewer transparency.
    // Avoid context.read() in dispose (can throw if provider tree already torn down).
    try {
      _fractalController.setTransparentBackground(_previousTransparency);
    } catch (e, st) {
      dev.log('dispose: restoring transparency failed: $e',
          name: 'FF.AR', error: e, stackTrace: st);
    }
    super.dispose();
  }

  void _onFractalChanged() {
    // Zoom distance: sum abs(log(new/old))
    final prevZoom = _lastZoom;
    final currentZoom = _fractalController.view.zoom;
    if (prevZoom != null &&
        prevZoom > 0 &&
        currentZoom > 0 &&
        prevZoom != currentZoom) {
      final delta = (math.log(currentZoom / prevZoom)).abs();
      _statsService?.addZoomDistance(delta);
      _lastZoom = currentZoom;
    }

    final id = _fractalController.module.id;
    if (_lastModuleId != id) {
      _lastModuleId = id;
      _statsService?.recordFractalExplored(id);

      final shouldTransparent =
          _shouldUseTransparentBackgroundInAr(_fractalController.module);
      if (_transparentBackground != shouldTransparent) {
        _transparentBackground = shouldTransparent;
        _fractalController.setTransparentBackground(shouldTransparent);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<FractalController>();

    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_permissionDenied) {
      return _ArStatusState(
        icon: Icons.no_photography,
        title: l10n.arPermissionDenied,
        message: l10n.arPermissionRequest,
        primaryActionLabel: l10n.actionOpenSettings,
        onPrimaryAction: openAppSettings,
        secondaryActionLabel: l10n.actionRetry,
        onSecondaryAction: () {
          setState(() {
            _permissionDenied = false;
            _cameraFailureReason = null;
            _initializing = true;
          });
          _initCamera();
        },
      );
    }
    if (_cameraFailureReason != null) {
      return _ArStatusState(
        icon: Icons.warning_amber_rounded,
        title: l10n.arCameraUnavailable,
        message: _cameraFailureReason!,
        primaryActionLabel: l10n.actionRetry,
        onPrimaryAction: () {
          setState(() {
            _cameraFailureReason = null;
            _initializing = true;
          });
          _initCamera();
        },
      );
    }
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _ArStatusState(
        icon: Icons.camera_alt_outlined,
        title: l10n.arCameraUnavailable,
        message: l10n.arCameraUnavailableHelp,
        primaryActionLabel: l10n.actionRetry,
        onPrimaryAction: () {
          setState(() {
            _cameraFailureReason = null;
            _initializing = true;
          });
          _initCamera();
        },
      );
    }

    final dim = controller.module.dimension;
    final viewportSize = MediaQuery.of(context).size;
    final overlaySize = viewportSize.shortestSide *
        (dim == FractalDimension.threeD ? 0.55 : 0.62);
    final transparencyForced =
        _shouldUseTransparentBackgroundInAr(controller.module);

    final brightness = Theme.of(context).brightness;

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_cameraController!)),
        Positioned.fill(
          child: RepaintBoundary(
            key: _overlayKey,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTapUp: _overlayLocked
                        ? null
                        : (details) {
                            final center = viewportSize.center(Offset.zero);
                            setState(() {
                              _overlayOffset = details.localPosition - center;
                              _anchorPlaced = true;
                              _overlayLocked = true;
                            });
                            if (mounted) {
                              final l10n = AppLocalizations.of(context)!;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.arFractalAnchored),
                                  duration: const Duration(milliseconds: 1200),
                                ),
                              );
                            }
                          },
                    onScaleStart: (_overlayLocked || !_anchorPlaced)
                        ? null
                        : (details) {
                            _startScale = _overlayScale;
                            _startRotation = _overlayRotation;
                          },
                    onScaleUpdate: (_overlayLocked || !_anchorPlaced)
                        ? null
                        : (details) {
                            setState(() {
                              _overlayScale =
                                  (_startScale * details.scale).clamp(0.3, 4.0);
                              _overlayRotation =
                                  _startRotation + details.rotation;
                              _overlayOffset += details.focalPointDelta;
                            });
                          },
                    child: _anchorPlaced
                        ? Center(
                            child: Opacity(
                              opacity: _overlayOpacity,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..translateByDouble(
                                    _overlayOffset.dx,
                                    _overlayOffset.dy,
                                    0.0,
                                    0.0,
                                  )
                                  ..rotateZ(_overlayRotation)
                                  ..scaleByDouble(
                                    _overlayScale,
                                    _overlayScale,
                                    1.0,
                                    1.0,
                                  ),
                                child: SizedBox(
                                  width: overlaySize,
                                  height: overlaySize,
                                  child: _ArOverlayFrame(
                                    showGrid: _showGrid,
                                    showOutline: _showOutline,
                                    gridColor:
                                        _stylePreset.gridColor(brightness),
                                    outlineColor:
                                        _stylePreset.outlineColor(brightness),
                                    child: ColorFiltered(
                                      colorFilter: _stylePreset.colorFilter() ??
                                          const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.dst,
                                          ),
                                      child: const FractalRenderer(
                                        boundaryKey: null,
                                        gesturesEnabled: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: _ArAnchorReticle(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.actionClose,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          _anchorPlaced
                              ? l10n.arAnchoredStatus(_activeCamera?.lensDirection.name ?? 'camera')
                              : l10n.arTapToAnchor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_hasMultipleCameras) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: l10n.arTooltipSwitchCamera,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.cameraswitch_rounded,
                          color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _ArControlsPanel(
            collapsed: _panelCollapsed,
            opacity: _overlayOpacity,
            locked: _overlayLocked,
            transparent: _transparentBackground,
            transparentLocked: transparencyForced,
            showGrid: _showGrid,
            showOutline: _showOutline,
            stylePreset: _stylePreset,
            qualityPreset: _qualityPreset,
            currentModuleLabel: controller.module.displayName(l10n),
            isAnchored: _anchorPlaced,
            onBeginAnchoring: _exporting
                ? null
                : () => setState(() {
                      _anchorPlaced = false;
                      _overlayLocked = false;
                      _overlayOffset = Offset.zero;
                    }),
            onCollapsedChanged: (value) =>
                setState(() => _panelCollapsed = value),
            onOpacityChanged: (value) =>
                setState(() => _overlayOpacity = value),
            onLockedChanged: (value) => setState(() => _overlayLocked = value),
            onCenterOverlay: () => setState(() {
              _overlayOffset = Offset.zero;
              _overlayRotation = 0.0;
            }),
            onResetOverlay: () => setState(() {
              _overlayOffset = Offset.zero;
              _overlayScale = 1.0;
              _overlayRotation = 0.0;
              _overlayOpacity = 0.75;
            }),
            onTransparentChanged: (value) {
              final nextValue = transparencyForced ? true : value;
              setState(() => _transparentBackground = nextValue);
              controller.setTransparentBackground(nextValue);
            },
            onGridChanged: (value) => setState(() => _showGrid = value),
            onOutlineChanged: (value) => setState(() => _showOutline = value),
            onStyleChanged: (value) => setState(() => _stylePreset = value),
            onQualityChanged: (preset) {
              setState(() => _qualityPreset = preset);
              context.read<ArQualityStore>().setPreset(preset);
              controller.applyArQualityPreset(preset);
            },
            onExportOverlay: _exporting ? null : () => _exportOverlay(context),
            onExportBaked: _exporting ? null : () => _exportBaked(context),
            onExportVideo: _exporting ? null : () => _exportVideo(context),
            onSwitchToArCore: _exporting ? null : _switchToArCore,
          ),
        ),
        if (_exporting)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.exporting),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 200,
                          child:
                              LinearProgressIndicator(value: _exportProgress),
                        ),
                        if (_exportProgress != null) ...[
                          const SizedBox(height: 8),
                          Text('${(_exportProgress! * 100).round()}%'),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _exportOverlay(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_overlayKey.currentContext == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(l10n.errorOverlayNotReady))),
        );
      }
      return;
    }
    dev.log('exportOverlay: capturing overlay png', name: 'FF.AR');
    setState(() {
      _exporting = true;
      _exportProgress = null;
    });
    try {
      final bytes =
          await _exportService.capturePng(_overlayKey, pixelRatio: 2.0);
      final file = await _exportService.saveBytes(
        bytes,
        filename: 'ar_overlay_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      context.read<ExplorationStatsService?>()?.recordScreenshot();
      await _exportService.shareFile(file, text: l10n.arOverlayOnlyExport);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _exportBaked(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(l10n.errorCameraNotReady))),
        );
      }
      return;
    }
    if (_overlayKey.currentContext == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(l10n.errorOverlayNotReady))),
        );
      }
      return;
    }
    setState(() {
      _exporting = true;
      _exportProgress = null;
    });
    try {
      final overlayBytes =
          await _exportService.capturePng(_overlayKey, pixelRatio: 2.0);
      dev.log('exportBaked: capturing overlay + takePicture', name: 'FF.AR');
      final file = await _arExportService.exportBakedScreenshot(
        cameraController: cam,
        overlayPng: overlayBytes,
        filename: 'ar_baked_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      context.read<ExplorationStatsService?>()?.recordScreenshot();
      await _exportService.shareFile(file, text: l10n.arBakedScreenshotExport);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _exportVideo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(l10n.errorCameraNotReady))),
        );
      }
      return;
    }
    if (_overlayKey.currentContext == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(l10n.errorOverlayNotReady))),
        );
      }
      return;
    }
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.arDuration5),
              onTap: () =>
                  Navigator.of(context).pop(const Duration(seconds: 5)),
            ),
            ListTile(
              title: Text(l10n.arDuration10),
              onTap: () =>
                  Navigator.of(context).pop(const Duration(seconds: 10)),
            ),
            ListTile(
              title: Text(l10n.arDuration15),
              onTap: () =>
                  Navigator.of(context).pop(const Duration(seconds: 15)),
            ),
          ],
        ),
      ),
    );
    if (duration == null) {
      return;
    }
    setState(() {
      _exporting = true;
      _exportProgress = 0.0;
    });
    try {
      dev.log('exportVideo: recording baked video (fallback gif)',
          name: 'FF.AR');
      final result = await _videoExporter.recordBakedVideo(
        cameraController: cam,
        overlayKey: _overlayKey,
        duration: duration,
        fps: 30,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        targetShortSide: 720,
        onProgress: (progress) {
          if (!mounted) {
            return;
          }
          setState(() => _exportProgress = progress.clamp(0.0, 1.0));
        },
      );
      if (result != null) {
        await _exportService.shareFile(result.file, text: l10n.exportArVideo);
        if (result.method == ArVideoExportMethod.dartGifFallback && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.arVideoFallbackNotice)),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.arVideoExportFailed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _switchToArCore() async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.arSafetyWarningTitle),
              content: Text(l10n.arSafetyWarningBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.actionClose),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.arSafetyContinue),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    // Check ARCore availability
    final supported = await ArCoreAnchorScreen.isSupportedOnDevice();
    if (!supported) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.arErrorSurfaceDetectionUnavailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final installed = await ArCoreAnchorScreen.isInstalledOnDevice();
    if (!installed) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.arErrorArCoreUnavailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Capture current fractal as texture
    Uint8List textureBytes;
    try {
      textureBytes = await const ExportService().capturePng(
        _overlayKey,
        pixelRatio: 1.5,
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.arErrorCaptureFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    // Replace current route with ARCore screen
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: ArCoreAnchorScreen(
            fractalTextureBytes: textureBytes,
          ),
        ),
      ),
    );
  }
}

class _ArOverlayFrame extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showOutline;
  final Color gridColor;
  final Color outlineColor;

  const _ArOverlayFrame({
    required this.child,
    required this.showGrid,
    required this.showOutline,
    required this.gridColor,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 18.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showGrid)
            CustomPaint(
              painter: _ArGridPainter(color: gridColor),
            ),
          // PhysicalModel gives smoother clipped edges than Container+clip.
          PhysicalModel(
            color: Colors.transparent,
            shadowColor: Colors.black,
            elevation: 6,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          if (showOutline)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: outlineColor, width: 1.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArGridPainter extends CustomPainter {
  final Color color;

  const _ArGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Soft grid: 4x4 plus center cross.
    const divisions = 4;
    for (int i = 1; i < divisions; i++) {
      final x = size.width * (i / divisions);
      final y = size.height * (i / divisions);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Center lines a bit stronger.
    final strongAlpha = (color.a * 1.6).clamp(0.0, 1.0);
    final strong = Paint()
      ..color = color.withValues(alpha: strongAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      strong,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      strong,
    );
  }

  @override
  bool shouldRepaint(covariant _ArGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ArAnchorReticle extends StatelessWidget {
  const _ArAnchorReticle();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.0),
                  ),
                  child: const SizedBox(width: 80, height: 80),
                ),
                // Inner target crosshair
                CustomPaint(
                  size: const Size(80, 80),
                  painter: const _CrosshairPainter(),
                ),
                // Center dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)!.arTapAnywhereToPlace,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Corner brackets
    const arm = 14.0;
    const gap = 24.0;
    // Top-left
    canvas.drawLine(
        Offset(cx - gap, cy - gap), Offset(cx - gap + arm, cy - gap), paint);
    canvas.drawLine(
        Offset(cx - gap, cy - gap), Offset(cx - gap, cy - gap + arm), paint);
    // Top-right
    canvas.drawLine(
        Offset(cx + gap, cy - gap), Offset(cx + gap - arm, cy - gap), paint);
    canvas.drawLine(
        Offset(cx + gap, cy - gap), Offset(cx + gap, cy - gap + arm), paint);
    // Bottom-left
    canvas.drawLine(
        Offset(cx - gap, cy + gap), Offset(cx - gap + arm, cy + gap), paint);
    canvas.drawLine(
        Offset(cx - gap, cy + gap), Offset(cx - gap, cy + gap - arm), paint);
    // Bottom-right
    canvas.drawLine(
        Offset(cx + gap, cy + gap), Offset(cx + gap - arm, cy + gap), paint);
    canvas.drawLine(
        Offset(cx + gap, cy + gap), Offset(cx + gap, cy + gap - arm), paint);
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter _) => false;
}

class _ArStatusState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const _ArStatusState({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    child: Text(primaryActionLabel),
                  ),
                  if (secondaryActionLabel != null && onSecondaryAction != null)
                    OutlinedButton(
                      onPressed: onSecondaryAction,
                      child: Text(secondaryActionLabel!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArControlsPanel extends StatelessWidget {
  final bool collapsed;
  final double opacity;
  final bool locked;
  final bool transparent;
  final bool transparentLocked;
  final bool showGrid;
  final bool showOutline;
  final ArOverlayStylePreset stylePreset;
  final ArQualityPreset qualityPreset;
  final String currentModuleLabel;
  final bool isAnchored;
  final VoidCallback? onBeginAnchoring;

  final ValueChanged<bool> onCollapsedChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<bool> onLockedChanged;
  final VoidCallback onCenterOverlay;
  final VoidCallback onResetOverlay;
  final ValueChanged<bool> onTransparentChanged;
  final ValueChanged<bool> onGridChanged;
  final ValueChanged<bool> onOutlineChanged;
  final ValueChanged<ArOverlayStylePreset> onStyleChanged;
  final ValueChanged<ArQualityPreset> onQualityChanged;
  final VoidCallback? onExportOverlay;
  final VoidCallback? onExportBaked;
  final VoidCallback? onExportVideo;
  final VoidCallback? onSwitchToArCore;

  const _ArControlsPanel({
    required this.collapsed,
    required this.opacity,
    required this.locked,
    required this.transparent,
    required this.transparentLocked,
    required this.showGrid,
    required this.showOutline,
    required this.stylePreset,
    required this.qualityPreset,
    required this.currentModuleLabel,
    required this.isAnchored,
    required this.onBeginAnchoring,
    required this.onCollapsedChanged,
    required this.onOpacityChanged,
    required this.onLockedChanged,
    required this.onCenterOverlay,
    required this.onResetOverlay,
    required this.onTransparentChanged,
    required this.onGridChanged,
    required this.onOutlineChanged,
    required this.onStyleChanged,
    required this.onQualityChanged,
    required this.onExportOverlay,
    required this.onExportBaked,
    required this.onExportVideo,
    this.onSwitchToArCore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget collapsedBar() {
      // Keep this *very* small — users should see the scene.
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.tooltipExpand,
                onPressed: () => onCollapsedChanged(false),
                icon: const Icon(Icons.expand_less),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  currentModuleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: isAnchored ? l10n.arTooltipReAnchor : l10n.arTooltipAnchorToSurface,
                onPressed: onBeginAnchoring,
                icon: Icon(
                  isAnchored ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                ),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: l10n.paramLockOverlay,
                onPressed: () => onLockedChanged(!locked),
                icon:
                    Icon(locked ? Icons.lock_rounded : Icons.lock_open_rounded),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: l10n.arBakedScreenshotExport,
                onPressed: onExportBaked,
                icon: const Icon(Icons.photo_camera),
                visualDensity: VisualDensity.compact,
              ),
              // "Switch to AR Surface Anchoring" button — only on Android
              if (!kIsWeb && Platform.isAndroid)
                IconButton(
                  tooltip: l10n.arTooltipSwitchToSurfaceAnchoring,
                  icon: const Icon(Icons.view_in_ar_rounded),
                  color: Colors.cyanAccent,
                  onPressed: onSwitchToArCore,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      );
    }

    Widget expandedPanel() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.arTitle}: $currentModuleLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.tooltipCollapse,
                    onPressed: () => onCollapsedChanged(true),
                    icon: const Icon(Icons.expand_more),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // AR uses the currently selected viewer fractal.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isAnchored
                          ? l10n.arAnchoredToSurface
                          : l10n.arTapToAnchorFractal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onBeginAnchoring,
                    icon: const Icon(Icons.push_pin_rounded),
                    label: Text(isAnchored ? l10n.arButtonReAnchor : l10n.arButtonAnchor),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onCenterOverlay,
                    icon: const Icon(Icons.center_focus_strong),
                    label: Text(l10n.arCenter),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: Text(l10n.paramOpacity)),
                  Expanded(
                    child: Slider(
                      value: opacity,
                      min: 0.2,
                      max: 1.0,
                      onChanged: onOpacityChanged,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text(l10n.paramLockOverlay),
                      value: locked,
                      onChanged: onLockedChanged,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onResetOverlay,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l10n.resetView),
                  ),
                ],
              ),

              // Advanced options in a collapsible section
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(l10n.arMoreOptions),
                children: [
                  SwitchListTile(
                    title: Text(l10n.paramTransparentBg),
                    value: transparent,
                    onChanged: transparentLocked ? null : onTransparentChanged,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text(l10n.arShowGrid),
                    value: showGrid,
                    onChanged: onGridChanged,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text(l10n.arShowOutline),
                    value: showOutline,
                    onChanged: onOutlineChanged,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.arStyleTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ArOverlayStylePreset.values.map((preset) {
                      return ChoiceChip(
                        label: Text(preset.label(l10n)),
                        selected: preset == stylePreset,
                        onSelected: (_) => onStyleChanged(preset),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.arQualityPreset),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ArQualityPreset.values.map((preset) {
                      return ChoiceChip(
                        label: Text(preset.label(l10n)),
                        selected: preset == qualityPreset,
                        onSelected: (_) => onQualityChanged(preset),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Export actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExportOverlay,
                      child: Text(l10n.arOverlayOnlyExport),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExportBaked,
                      child: Text(l10n.arBakedScreenshotExport),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onExportVideo,
                  icon: const Icon(Icons.videocam),
                  label: Text(l10n.arVideoExport),
                ),
              ),
              // "Switch to AR Surface Anchoring" button — only on Android
              if (!kIsWeb && Platform.isAndroid) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSwitchToArCore,
                    icon: const Icon(Icons.view_in_ar_rounded,
                        color: Colors.cyanAccent),
                    label: Text(l10n.arSwitchToSurfaceAnchoring),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return AnimatedCrossFade(
      crossFadeState:
          collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 180),
      firstChild: collapsedBar(),
      secondChild: expandedPanel(),
    );
  }
}
