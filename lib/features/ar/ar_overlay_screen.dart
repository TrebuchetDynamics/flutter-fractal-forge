import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/ar_export_service.dart';
import 'package:flutter_fractals/core/services/ar_video_exporter.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class ArOverlayScreen extends StatefulWidget {
  const ArOverlayScreen({Key? key}) : super(key: key);

  @override
  State<ArOverlayScreen> createState() => _ArOverlayScreenState();
}

class _ArOverlayScreenState extends State<ArOverlayScreen> {
  CameraController? _cameraController;
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
  double _overlayOpacity = 0.85;
  bool _overlayLocked = false;
  bool _transparentBackground = true;
  late ArQualityPreset _qualityPreset;

  double _startScale = 1.0;
  double _startRotation = 0.0;

  bool _previousTransparency = false;

  @override
  void initState() {
    super.initState();
    _qualityPreset = context.read<ArQualityStore>().getPreset();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FractalController>();
      _previousTransparency = controller.transparentBackground;
      controller.setTransparentBackground(true);
      controller.applyArQualityPreset(_qualityPreset);
    });
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }

    try {
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
      setState(() {
        _cameraController = controller;
        _initializing = false;
      });
    } catch (_) {
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    // Restore prior viewer transparency. `mounted` is false during dispose.
    context.read<FractalController>().setTransparentBackground(_previousTransparency);
    super.dispose();
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

    final overlaySize = MediaQuery.of(context).size.shortestSide * 0.6;
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
                              _overlayRotation = _startRotation + details.rotation;
                              _overlayOffset += details.focalPointDelta;
                            });
                          },
                    child: Center(
                      child: Opacity(
                        opacity: _overlayOpacity,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(_overlayOffset.dx, _overlayOffset.dy)
                            ..rotateZ(_overlayRotation)
                            ..scale(_overlayScale),
                          child: SizedBox(
                            width: overlaySize,
                            height: overlaySize,
                            child: FractalRenderer(
                              boundaryKey: null,
                              gesturesEnabled: false,
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
            opacity: _overlayOpacity,
            locked: _overlayLocked,
            transparent: _transparentBackground,
            qualityPreset: _qualityPreset,
            onOpacityChanged: (value) => setState(() => _overlayOpacity = value),
            onLockedChanged: (value) => setState(() => _overlayLocked = value),
            onTransparentChanged: (value) {
              setState(() => _transparentBackground = value);
              controller.setTransparentBackground(value);
            },
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
                          child: LinearProgressIndicator(value: _exportProgress),
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
    setState(() {
      _exporting = true;
      _exportProgress = null;
    });
    try {
      final bytes = await _exportService.capturePng(_overlayKey, pixelRatio: 2.0);
      final file = await _exportService.saveBytes(
        bytes,
        filename: 'ar_overlay_${DateTime.now().millisecondsSinceEpoch}.png',
      );
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
    if (_cameraController == null) {
      return;
    }
    setState(() {
      _exporting = true;
      _exportProgress = null;
    });
    try {
      final overlayBytes = await _exportService.capturePng(_overlayKey, pixelRatio: 2.0);
      final file = await _arExportService.exportBakedScreenshot(
        cameraController: _cameraController!,
        overlayPng: overlayBytes,
        filename: 'ar_baked_${DateTime.now().millisecondsSinceEpoch}.png',
      );
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
    if (_cameraController == null) {
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
              onTap: () => Navigator.of(context).pop(const Duration(seconds: 5)),
            ),
            ListTile(
              title: Text(l10n.arDuration10),
              onTap: () => Navigator.of(context).pop(const Duration(seconds: 10)),
            ),
            ListTile(
              title: Text(l10n.arDuration15),
              onTap: () => Navigator.of(context).pop(const Duration(seconds: 15)),
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
      final result = await _videoExporter.recordBakedVideo(
        cameraController: _cameraController!,
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
  final double opacity;
  final bool locked;
  final bool transparent;
  final ArQualityPreset qualityPreset;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<bool> onLockedChanged;
  final ValueChanged<bool> onTransparentChanged;
  final ValueChanged<ArQualityPreset> onQualityChanged;
  final VoidCallback? onExportOverlay;
  final VoidCallback? onExportBaked;
  final VoidCallback? onExportVideo;

  const _ArControlsPanel({
    required this.opacity,
    required this.locked,
    required this.transparent,
    required this.qualityPreset,
    required this.onOpacityChanged,
    required this.onLockedChanged,
    required this.onTransparentChanged,
    required this.onQualityChanged,
    required this.onExportOverlay,
    required this.onExportBaked,
    required this.onExportVideo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ),
            SwitchListTile(
              title: Text(l10n.paramTransparentBg),
              value: transparent,
              onChanged: onTransparentChanged,
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
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
}
