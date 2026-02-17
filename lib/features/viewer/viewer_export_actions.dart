part of 'fractal_viewer_screen.dart';

/// Mixin that owns export/wallpaper action state and orchestration.
///
/// Apply to `State<FractalViewerScreen>`.
mixin _ExportActionsMixin on State<FractalViewerScreen> {
  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  ExportService get _exportService;
  WallpaperService get _wallpaperService;
  AutoExploreService? get _autoExploreService;
  FractalController _activeController(BuildContext context);
  GlobalKey _activeBoundaryKey();

  bool _exporting = false;
  double? _exportProgress;

  // Freeze renderer while export sheet is open.
  bool _freezeFrameForExport = false;
  bool _resumeAutoExploreAfterExportSheet = false;

  void _pauseAutoExploreForExportSheet() {
    final svc = _autoExploreService;
    if (svc == null) {
      _resumeAutoExploreAfterExportSheet = false;
      return;
    }

    _resumeAutoExploreAfterExportSheet = svc.isExploring && !svc.isPaused;
    if (_resumeAutoExploreAfterExportSheet) {
      svc.pause();
    }
  }

  void _resumeAutoExploreAfterExportSheetIfNeeded() {
    final svc = _autoExploreService;
    if (svc == null) return;

    if (_resumeAutoExploreAfterExportSheet && svc.isExploring && svc.isPaused) {
      svc.resume();
    }
    _resumeAutoExploreAfterExportSheet = false;
  }

  void _openExport(BuildContext context) {
    _log.info('action', 'Open export');
    final controller = _activeController(context);
    _pauseAutoExploreForExportSheet();
    setState(() {
      _freezeFrameForExport = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportOptionsSheet(
        initialOptions: const ExportOptions(),
        fractalType: controller.module.id,
        onExport: (options, action) => _performExport(
          context,
          options,
          shareAfterSave: action == ExportAction.saveAndShare,
        ),
      ),
    ).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _freezeFrameForExport = false;
      });
      _resumeAutoExploreAfterExportSheetIfNeeded();
    });
  }

  Future<void> _performExport(
    BuildContext context,
    ExportOptions options, {
    required bool shareAfterSave,
  }) async {
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final previousTransparency = controller.transparentBackground;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    try {
      if (options.transparentBackground) {
        controller.setTransparentBackground(true);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final result = await _exportService.exportWithOptions(
        boundaryKey,
        options: options,
        screenWidth: size.width,
        screenHeight: size.height,
        fractalType: controller.module.id,
        parameters: controller.params,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _exportProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        await HapticService.heavy();
        context.read<ExplorationStatsService?>()?.recordScreenshot();

        if (shareAfterSave) {
          await _exportService.shareFile(result.file, text: l10n.exportTitle);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.exportSaved),
                      Text(
                        '${result.resolution} • ${result.format.displayName} • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      controller.setTransparentBackground(previousTransparency);
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _performVideoExport(
      BuildContext context, VideoExportOptions options) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    const videoService = VideoExportService();
    final startView = controller.view;
    final startParams = Map<String, Object>.from(controller.params);

    try {
      final result = await videoService.exportVideo(
        options: options,
        startView: startView,
        startParams: startParams,
        fractalType: controller.module.id,
        updateView: (view, params) {
          controller.updateZoom(view.zoom);
          controller.updatePan(view.pan);
          controller.updateRotation(view.rotation);
          if (params != null) {
            for (final entry in params.entries) {
              controller.updateParam(entry.key, entry.value);
            }
          }
        },
        captureFrame: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return await videoService.captureWidget(_activeBoundaryKey(),
              pixelRatio: 2.0);
        },
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _exportProgress = progress;
            });
          }
        },
      );

      // Restore original view and params
      controller.updateZoom(startView.zoom);
      controller.updatePan(startView.pan);
      controller.updateRotation(startView.rotation);
      for (final entry in startParams.entries) {
        controller.updateParam(entry.key, entry.value);
      }

      if (mounted) {
        await _exportService.shareFile(result.file,
            text: l10n.videoExportTitle);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.videoExportComplete),
                      Text(
                        '${result.resolution} • ${result.format.displayName} • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Restore original view and params on error
      controller.updateZoom(startView.zoom);
      controller.updatePan(startView.pan);
      controller.updateRotation(startView.rotation);
      for (final entry in startParams.entries) {
        controller.updateParam(entry.key, entry.value);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.videoExportFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
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

  Future<void> _applyWallpaper(
      BuildContext context, WallpaperOptions options) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final dpr = mq.devicePixelRatio;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    try {
      final exportOptions = ExportOptions(
        format: ExportFormat.png,
        resolution: ExportResolution.custom,
        customWidth: (size.width * dpr).round(),
        customHeight: (size.height * dpr).round(),
        embedMetadata: false,
      );

      final bytes = await _exportService.captureWithOptions(
        _activeBoundaryKey(),
        options: exportOptions,
        screenWidth: size.width,
        screenHeight: size.height,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _exportProgress = p * 0.9);
        },
      );

      final styledBytes = _exportService.applyWallpaperStyle(
        bytes,
        style: options.style.name,
      );

      final ok = await _wallpaperService.setWallpaper(
        styledBytes,
        target: options.target,
      );

      if (options.saveCopy) {
        final filename = _exportService.generateFilename(
          prefix: 'wallpaper',
          format: ExportFormat.png,
          fractalType: controller.module.id,
        );
        final file =
            await _exportService.saveBytes(styledBytes, filename: filename);
        context.read<ExplorationStatsService?>()?.recordScreenshot();
        await _exportService.shareFile(file, text: l10n.wallpaperTitle);
      }

      if (mounted) {
        await HapticService.heavy();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? l10n.wallpaperApplied : l10n.wallpaperFailed),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wallpaperFailedWithError(e.toString())),
            backgroundColor: AppColors.error,
          ),
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
