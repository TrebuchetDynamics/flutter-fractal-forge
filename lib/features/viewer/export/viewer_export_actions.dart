part of '../fractal_viewer_screen.dart';

/// Mixin that owns export/wallpaper action state and orchestration.
///
/// Apply to `State<FractalViewerScreen>`.
mixin _ExportActionsMixin on State<FractalViewerScreen> {
  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  ExportService get _exportService;
  AutoExploreService? get _autoExploreService;
  LooperController? get _looperController;
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

    final plan = ViewerExportAutoExplorePausePlan.fromPlayback(
      ViewerExportAutoExplorePlayback(
        isExploring: svc.isExploring,
        isPaused: svc.isPaused,
        pausedByUserCorrection: svc.pausedByUserCorrection,
      ),
    );
    if (plan.pauseService) {
      svc.pause();
    }
    return plan.resumeWhenFinished;
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

  Future<void> _exportLooperGif(BuildContext context) async {
    final looper = _looperController;
    final plan = looper?.plan;
    if (looper == null || plan == null) return;

    _log.info('action', 'Export looper GIF');
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final originalView = controller.view;
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
    looper.stop();

    setState(() {
      _exportSession = _exportSession
          .openSheet(resumeAutoExploreWhenFinished: shouldResumeAutoExplore)
          .startExport();
    });

    try {
      final frameMs = (1000 / LooperPlan.exportFps).round();
      img.Image? animation;

      for (var i = 0; i < plan.frameCount; i++) {
        controller.updateView(plan.poseAtFrame(i).toView());
        await WidgetsBinding.instance.endOfFrame;

        final pngBytes = await _exportService.capturePng(
          boundaryKey,
          pixelRatio: 1.0,
        );
        var frame = img.decodePng(pngBytes);
        if (frame == null) throw StateError('Failed to decode loop frame');
        if (frame.width > 640) {
          frame = img.copyResize(
            frame,
            width: 640,
            interpolation: img.Interpolation.average,
          );
        }
        frame.frameDuration = frameMs;

        if (animation == null) {
          animation = frame
            ..frameType = img.FrameType.animation
            ..loopCount = 0;
        } else {
          animation.addFrame(frame).frameDuration = frameMs;
        }

        if (mounted) {
          setState(() {
            _exportSession = _exportSession.updateProgress(
              (i + 1) / plan.frameCount,
            );
          });
        }
      }

      final gif = animation;
      if (gif == null) throw StateError('No loop frames captured');
      final bytes = img.encodeGif(gif, samplingFactor: 12);
      final file = await _exportService.saveBytes(
        bytes,
        filename:
            'looper_${controller.module.id}_${DateTime.now().millisecondsSinceEpoch}.gif',
      );

      await _exportService.shareFile(
        file,
        text: ViewerShareCaption.build(
          fractalName: controller.module.displayName(l10n),
          shareUrl: DeepLinkService.buildWebUri(
            moduleId: controller.module.id,
            params: controller.params,
            view: controller.view,
          ).toString(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Looper GIF exported')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.videoExportFailed(error.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      controller.updateView(originalView);
      if (mounted) {
        setState(() {
          _finishExportFlow();
        });
      }
    }
  }

  Future<void> _shareCurrentImage(BuildContext context) async {
    _log.info('action', 'Quick share image');
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
    setState(() {
      _exportSession = _exportSession.openSheet(
        resumeAutoExploreWhenFinished: shouldResumeAutoExplore,
      );
    });

    await _performExport(
      context,
      const ExportOptions(resolution: ExportResolution.twitter),
      shareAfterSave: true,
    );
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

        Object? shareError;
        if (shareAfterSave) {
          try {
            await _exportService.shareFile(
              result.file,
              text: ViewerShareCaption.build(
                fractalName: controller.module.displayName(l10n),
                shareUrl: DeepLinkService.buildWebUri(
                  moduleId: controller.module.id,
                  params: controller.params,
                  view: controller.view,
                ).toString(),
              ),
            );
          } catch (error) {
            shareError = error;
            _log.warn(
              'export',
              'Share failed after export saved',
              data: {'error': error.toString()},
            );
          }
        }

        if (!mounted) return;
        _showExportCompletionSnackBar(
          context,
          l10n,
          ViewerExportFeedback(
            result: result,
            usedFallback: usedFallback,
            shareError: shareError,
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

  void _showExportCompletionSnackBar(
    BuildContext context,
    AppLocalizations l10n,
    ViewerExportFeedback feedback,
  ) {
    final icon = feedback.isWarning
        ? Icons.warning_amber_rounded
        : Icons.check_circle_rounded;
    final iconColor =
        feedback.isWarning ? AppColors.warning : AppColors.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feedback.title(l10n)),
                  Text(
                    feedback.detail(l10n),
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
        duration: Duration(seconds: feedback.isWarning ? 6 : 4),
      ),
    );
  }

  Future<void> _openWallpaper(BuildContext context) async {
    _log.info('action', 'Open wallpaper');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WallpaperOptionsSheet(
        initial: const WallpaperOptions(),
        onApply: (options) => _applyWallpaper(context, options),
      ),
    );
  }

  Future<void> _applyWallpaper(
    BuildContext context,
    WallpaperOptions options,
  ) async {
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    try {
      // Capture the current frame at the device's native resolution (capped),
      // apply the legibility overlay, then hand it to the platform.
      final pngBytes = await _exportService.capturePng(
        boundaryKey,
        pixelRatio: devicePixelRatio.clamp(1.0, 3.0).toDouble(),
      );
      final styled = _exportService.applyWallpaperStyle(
        pngBytes,
        style: options.style.name,
      );

      final ok = await const WallpaperService()
          .setWallpaper(styled, target: options.target);

      if (options.saveCopy) {
        final filename = _exportService.generateFilename(
          format: ExportFormat.png,
          fractalType: controller.module.id,
        );
        await _exportService.saveBytes(styled, filename: filename);
      }

      if (!mounted) return;
      await HapticService.heavy();
      // iOS can't set wallpaper programmatically — the image was saved to
      // Photos instead, so report that rather than claiming it was applied.
      final savedToPhotosOnly = !kIsWeb && Platform.isIOS;
      final successMessage = savedToPhotosOnly
          ? l10n.wallpaperSavedToPhotos
          : l10n.wallpaperApplied;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? successMessage : l10n.wallpaperFailed),
          backgroundColor: ok ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _log.warn('wallpaper', 'Set wallpaper failed',
          data: {'error': e.toString()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.wallpaperFailedWithError(e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
