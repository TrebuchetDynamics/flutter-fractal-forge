import 'dart:math' as math;
import 'dart:ui';

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
          1.1, 0, 0, 0, 0,
          0, 1.1, 0, 0, 0,
          0, 0, 1.1, 0, 0,
          0, 0, 0, 1.0, 0,
        ]);
      case ArOverlayStylePreset.soft:
        return const ColorFilter.matrix(<double>[
          1.0, 0, 0, 0, 0,
          0, 1.0, 0, 0, 0,
          0, 0, 1.0, 0, 0,
          0, 0, 0, 1.0, 0,
        ]);
      case ArOverlayStylePreset.mono:
        return const ColorFilter.matrix(<double>[
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0, 0, 0, 1.0, 0,
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
  late final FractalController _fractalController;
  bool _permissionDenied = false;
  bool _initializing = true;
  bool _exporting = false;
  double? _exportProgress;

  final GlobalKey _overlayKey = GlobalKey();
  final ExportService _exportService = const ExportService();
  late final ArExportService _arExportService = ArExportService(_exportService);
  final ArVideoExporter _videoExporter = const ArVideoExporter();

  Offset _overlayOffset = Offset.zero;
  double _overlayScale = 1.0;
  double _overlayRotation = 0.0;
  double _overlayOpacity = 0.75;
  bool _overlayLocked = false;
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

  @override
  void initState() {
    super.initState();
    _fractalController = context.read<FractalController>();
    _statsService = context.read<ExplorationStatsService?>();
    _sessionStart = DateTime.now();

    _lastZoom = _fractalController.view.zoom;
    _lastModuleId = _fractalController.module.id;
    _statsService?.recordFractalExplored(_fractalController.module.id);
    _fractalController.addListener(_onFractalChanged);

    _qualityPreset = context.read<ArQualityStore>().getPreset();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // AR overlay expects the fractal layer to have a transparent background.
      // Cache controller so dispose doesn't depend on context.
      _previousTransparency = _fractalController.transparentBackground;
      _fractalController.setTransparentBackground(true);
      _fractalController.applyArQualityPreset(_qualityPreset);

      // Sensible defaults per dimension.
      final dim = _fractalController.module.dimension;
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
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
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
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }

    if (cameras.isEmpty) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }

    try {
      dev.log('initCamera: creating controller', name: 'FF.AR');
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      dev.log('initCamera: initialized', name: 'FF.AR');
      setState(() {
        _cameraController = controller;
        _initializing = false;
      });
    } catch (e, st) {
      dev.log('initCamera: initialize failed: $e',
          name: 'FF.AR', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
    }
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
    if (prevZoom != null && prevZoom > 0 && currentZoom > 0 && prevZoom != currentZoom) {
      final delta = (math.log(currentZoom / prevZoom)).abs();
      _statsService?.addZoomDistance(delta);
      _lastZoom = currentZoom;
    }

    final id = _fractalController.module.id;
    if (_lastModuleId != id) {
      _lastModuleId = id;
      _statsService?.recordFractalExplored(id);
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
          setState(() => _initializing = true);
          _initCamera();
        },
      );
    }

    final dim = controller.module.dimension;
    final overlaySize = MediaQuery.of(context).size.shortestSide *
        (dim == FractalDimension.threeD ? 0.55 : 0.62);

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
                    onScaleStart: _overlayLocked
                        ? null
                        : (details) {
                            _startScale = _overlayScale;
                            _startRotation = _overlayRotation;
                          },
                    onScaleUpdate: _overlayLocked
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
                    child: Center(
                      child: Opacity(
                        opacity: _overlayOpacity,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translateByDouble(
                              _overlayOffset.dx,
                              _overlayOffset.dy,
                              0.0,
                              1.0,
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
                              gridColor: _stylePreset.gridColor(brightness),
                              outlineColor: _stylePreset.outlineColor(brightness),
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
                    ),
                  ),
                ),
              ],
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
            showGrid: _showGrid,
            showOutline: _showOutline,
            stylePreset: _stylePreset,
            qualityPreset: _qualityPreset,
            currentModuleLabel: controller.module.displayName(l10n),
            onSelectModule:
                _exporting ? null : () => _showModuleSelector(context),
            onCollapsedChanged: (value) =>
                setState(() => _panelCollapsed = value),
            onOpacityChanged: (value) =>
                setState(() => _overlayOpacity = value),
            onLockedChanged: (value) => setState(() => _overlayLocked = value),
            onTransparentChanged: (value) {
              setState(() => _transparentBackground = value);
              controller.setTransparentBackground(value);
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

  Future<void> _showModuleSelector(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<FractalController>();
    final modules = controller.registry.modules;

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final twoD =
            modules.where((m) => m.dimension == FractalDimension.twoD).toList();
        final threeD = modules
            .where((m) => m.dimension == FractalDimension.threeD)
            .toList();

        Widget buildSection(String title, List<FractalModule> items) {
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(title,
                    style: Theme.of(sheetContext).textTheme.titleSmall),
              ),
              ...items.map((module) {
                final isSelected = module.id == controller.module.id;
                return ListTile(
                  title: Text(module.displayName(l10n)),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(sheetContext).pop(module.id),
                );
              }),
            ],
          );
        }

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              buildSection(l10n.fractalSection2d, twoD),
              buildSection(l10n.fractalSection3d, threeD),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    final module = controller.registry.byId(selected);
    controller.selectModule(module);

    // Ensure AR mode always renders on transparent background and uses AR quality.
    final dim = module.dimension;
    setState(() {
      _transparentBackground = true;
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
    controller.setTransparentBackground(true);
    controller.applyArQualityPreset(_qualityPreset);
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
      dev.log('exportVideo: recording baked video (fallback gif)', name: 'FF.AR');
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
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 0.0,
                sigmaY: 0.0,
              ),
              child: child,
            ),
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
    final strongAlpha = ((color.a / 255.0) * 1.6).clamp(0.0, 1.0);
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
  final bool showGrid;
  final bool showOutline;
  final ArOverlayStylePreset stylePreset;
  final ArQualityPreset qualityPreset;
  final String currentModuleLabel;
  final VoidCallback? onSelectModule;

  final ValueChanged<bool> onCollapsedChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<bool> onLockedChanged;
  final ValueChanged<bool> onTransparentChanged;
  final ValueChanged<bool> onGridChanged;
  final ValueChanged<bool> onOutlineChanged;
  final ValueChanged<ArOverlayStylePreset> onStyleChanged;
  final ValueChanged<ArQualityPreset> onQualityChanged;
  final VoidCallback? onExportOverlay;
  final VoidCallback? onExportBaked;
  final VoidCallback? onExportVideo;

  const _ArControlsPanel({
    required this.collapsed,
    required this.opacity,
    required this.locked,
    required this.transparent,
    required this.showGrid,
    required this.showOutline,
    required this.stylePreset,
    required this.qualityPreset,
    required this.currentModuleLabel,
    required this.onSelectModule,
    required this.onCollapsedChanged,
    required this.onOpacityChanged,
    required this.onLockedChanged,
    required this.onTransparentChanged,
    required this.onGridChanged,
    required this.onOutlineChanged,
    required this.onStyleChanged,
    required this.onQualityChanged,
    required this.onExportOverlay,
    required this.onExportBaked,
    required this.onExportVideo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget collapsedBar() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.tooltipExpand,
                onPressed: () => onCollapsedChanged(false),
                icon: const Icon(Icons.expand_less),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${l10n.arTitle}: $currentModuleLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.arBakedScreenshotExport,
                onPressed: onExportBaked,
                icon: const Icon(Icons.photo_camera),
              ),
              IconButton(
                tooltip: l10n.arVideoExport,
                onPressed: onExportVideo,
                icon: const Icon(Icons.videocam),
              ),
            ],
          ),
        ),
      );
    }

    Widget expandedPanel() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.arTitle)),
                  IconButton(
                    tooltip: l10n.tooltipCollapse,
                    onPressed: () => onCollapsedChanged(true),
                    icon: const Icon(Icons.expand_more),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSelectModule,
                  icon: const Icon(Icons.grid_view),
                  label: Text('${l10n.arSelectFractal}: $currentModuleLabel'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(l10n.paramOpacity)),
                  Expanded(
                    child: Slider(
                      value: opacity,
                      min: 0.1,
                      max: 1.0,
                      onChanged: onOpacityChanged,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text(l10n.paramLockOverlay),
                value: locked,
                onChanged: onLockedChanged,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(l10n.paramTransparentBg),
                value: transparent,
                onChanged: onTransparentChanged,
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onExportVideo,
                  child: Text(l10n.arVideoExport),
                ),
              ),
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
