part of 'fractal_viewer_screen.dart';

/// Mixin that owns export/wallpaper action state and orchestration.
///
/// Apply to `State<FractalViewerScreen>`.
mixin _ExportActionsMixin on State<FractalViewerScreen> {
  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  ExportService get _exportService;
  AutoExploreService? get _autoExploreService;
  FractalController _activeController(BuildContext context);
  GlobalKey _activeBoundaryKey();

  ViewerExportSession _exportSession = const ViewerExportSession();

  bool get _exporting => _exportSession.isExporting;
  bool get _freezeFrameForExport => _exportSession.freezeFrame;
  double? get _exportProgress => _exportSession.progress;

  bool _pauseAutoExploreForExportFlow() {
    final svc = _autoExploreService;
    if (svc == null) {
      return false;
    }

    final shouldResume = svc.isExploring && !svc.isPaused;
    if (shouldResume) {
      svc.pause();
    }
    return shouldResume;
  }

  void _resumeAutoExploreAfterExportFlowIfNeeded(bool shouldResume) {
    final svc = _autoExploreService;
    if (svc == null) return;

    if (shouldResume && svc.isExploring && svc.isPaused) {
      svc.resume();
    }
  }

  void _finishExportFlow() {
    final shouldResume = _exportSession.resumeAutoExploreWhenFinished;
    _resumeAutoExploreAfterExportFlowIfNeeded(shouldResume);
    _exportSession = _exportSession.finish();
  }

  Future<void> _openExport(BuildContext context) async {
    _log.info('action', 'Open export');
    final controller = _activeController(context);
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
    setState(() {
      _exportSession = _exportSession.openSheet(
        resumeAutoExploreWhenFinished: shouldResumeAutoExplore,
      );
    });

    final submission = await ExportOptionsSheet.show(
      context,
      initialOptions: const ExportOptions(),
      fractalType: controller.module.id,
    );

    if (!mounted) return;

    if (submission == null) {
      setState(() {
        _finishExportFlow();
      });
      return;
    }

    await _performExport(
      context,
      submission.options,
      shareAfterSave: submission.action == ExportAction.saveAndShare,
    );
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
      _exportSession = _exportSession.startExport();
    });

    try {
      if (options.transparentBackground) {
        controller.setTransparentBackground(true);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      ExportResult result;
      var usedFallback = false;

      try {
        result = await _exportService.exportWithOptions(
          boundaryKey,
          options: options,
          screenWidth: size.width,
          screenHeight: size.height,
          fractalType: controller.module.id,
          parameters: controller.params,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _exportSession = _exportSession.updateProgress(progress);
              });
            }
          },
        );
      } catch (primaryError) {
        _log.error(
          'export',
          'Primary export failed, trying PNG fallback',
          data: {'error': primaryError.toString()},
        );
        usedFallback = true;
        result = await _performFallbackPngExport(
          boundaryKey: boundaryKey,
          options: options,
          screenWidth: size.width,
          screenHeight: size.height,
          fractalType: controller.module.id,
        );
      }

      if (mounted) {
        await HapticService.heavy();
        context.read<ExplorationStatsService?>()?.recordScreenshot();

        if (shareAfterSave) {
          await _exportService.shareFile(result.file, text: l10n.exportTitle);
        }

        final formatLabel =
            usedFallback ? 'PNG (fallback)' : result.format.displayName;

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
                        '${result.resolution} • $formatLabel • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
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
          _finishExportFlow();
        });
      }
    }
  }

  Future<ExportResult> _performFallbackPngExport({
    required GlobalKey boundaryKey,
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required String fractalType,
  }) async {
    final pixelRatio =
        options.calculatePixelRatio(screenWidth, screenHeight).clamp(1.0, 8.0);
    final bytes = await _exportService.capturePng(
      boundaryKey,
      pixelRatio: pixelRatio,
    );

    final codec = await ui.instantiateImageCodec(bytes);
    late final int width;
    late final int height;
    try {
      final frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      frame.image.dispose();
    } finally {
      codec.dispose();
    }

    final filename = _exportService.generateFilename(
      format: ExportFormat.png,
      fractalType: fractalType,
    );
    final file = await _exportService.saveBytes(bytes, filename: filename);

    return ExportResult(
      file: file,
      format: ExportFormat.png,
      width: width,
      height: height,
      fileSize: bytes.length,
    );
  }
}
