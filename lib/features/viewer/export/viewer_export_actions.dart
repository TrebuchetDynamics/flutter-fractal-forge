part of '../fractal_viewer_screen.dart';

Uint8List _buildLooperMusicWav(
  (List<FractalMusicScanFrame>, List<double>, double) input,
) {
  final (frames, zoomSamples, seconds) = input;
  final zoom = zoomSamples.isEmpty
      ? 1.0
      : math.exp(
          zoomSamples
                  .map((sample) => math.log(sample.clamp(1e-12, 1e12)))
                  .reduce((a, b) => a + b) /
              zoomSamples.length,
        );
  return buildFractalMusicScanWav(
    scanFrame: weaveFractalMusicScanFrames(frames),
    zoom: zoom,
    seconds: seconds,
  );
}

Uint8List _encodeLooperGifFrames((List<Uint8List>, int) input) {
  final (pngFrames, frameDurationMs) = input;
  final encoder = img.GifEncoder(samplingFactor: 12);
  for (final pngBytes in pngFrames) {
    var frame = img.decodePng(pngBytes);
    if (frame == null) throw StateError('Failed to decode loop frame');
    if (frame.width > 480 || frame.height > 480) {
      frame = img.copyResize(
        frame,
        width: frame.width >= frame.height ? 480 : null,
        height: frame.height > frame.width ? 480 : null,
        interpolation: img.Interpolation.average,
      );
    }
    encoder.addFrame(frame, duration: frameDurationMs ~/ 10);
  }
  final bytes = encoder.finish();
  if (bytes == null) throw StateError('No loop frames captured');
  return Uint8List.fromList(bytes);
}

/// Mixin that owns export/wallpaper action state and orchestration.
///
/// Apply to `State<FractalViewerScreen>`.
mixin _ExportActionsMixin on State<FractalViewerScreen> {
  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  ExportService get _exportService;
  WallpaperService get _wallpaperService;
  AutoExploreService? get _autoExploreService;
  LooperController? get _looperController;
  FractalController _activeController(BuildContext context);
  GlobalKey _activeBoundaryKey();
  Future<FractalMusicScanFrame?> captureFractalMusicScanFrame();

  ViewerExportSession _exportSession = const ViewerExportSession();

  String? get _activeQuoteText;
  bool get _exporting => _exportSession.isExporting;
  bool get _exportFlowActive => _exportSession.phase != ViewerExportPhase.idle;
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

  Future<void> _exportLooperMp4(BuildContext context) async {
    final looper = _looperController;
    final plan = looper?.plan;
    if (looper == null || plan == null) return;

    _log.info('action', 'Export looper MP4 with music');
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final originalView = controller.view;
    final originalParams = controller.params;
    final originalTransparency = controller.transparentBackground;
    looper.stop();
    try {
      if (!await _exportService.chooseLinuxExportDirectory()) return;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(appFeedbackSnackBar(
          message: l10n.looperExportMp4Failed(error.toString()),
          success: false,
        ));
      }
      return;
    }
    if (!mounted) return;
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
    setState(() {
      _exportSession = _exportSession
          .openSheet(resumeAutoExploreWhenFinished: shouldResumeAutoExplore)
          .startExport();
    });

    try {
      await _exportService.coordinator.run<File>(
        ExportKind.looper,
        (token) async {
          final pngFrames = <Uint8List>[];
          final musicFrames = <FractalMusicScanFrame>[];
          final zoomSamples = <double>[];
          for (var i = 0; i < plan.frameCount; i++) {
            token.throwIfCancelled();
            final point = plan.stateAtFrame(i);
            controller.loadState(
              params: point.params,
              view: point.view,
              transparentBackground: controller.transparentBackground,
            );
            await WidgetsBinding.instance.endOfFrame;
            token.throwIfCancelled();
            pngFrames.add(await _exportService.capturePng(
              boundaryKey,
              pixelRatio: 1.0,
            ));
            final scan = await captureFractalMusicScanFrame();
            if (scan != null && scan.isValid) {
              musicFrames.add(scan);
              zoomSamples.add(point.view.zoom);
            }
            if (mounted) {
              setState(() => _exportSession = _exportSession.updateProgress(
                    (i + 1) / plan.frameCount * 0.8,
                  ));
            }
          }

          token.throwIfCancelled();
          Uint8List? musicWav;
          if (musicFrames.isNotEmpty) {
            musicWav = await _exportService.worker.runWithInput<
                (List<FractalMusicScanFrame>, List<double>, double), Uint8List>(
              _buildLooperMusicWav,
              (
                musicFrames,
                zoomSamples,
                plan.duration.inMilliseconds / 1000,
              ),
              token: token,
            );
          }
          final bytes = await LooperMp4Encoder().encode(
            pngFrames: pngFrames,
            fps: LooperPlan.exportFps,
            wavAudio: musicWav,
            token: token,
          );
          token.throwIfCancelled();
          if (mounted) {
            setState(
                () => _exportSession = _exportSession.updateProgress(0.95));
          }
          final savedFile = await _exportService.saveBytes(
            bytes,
            filename:
                'looper_${controller.module.id}_${DateTime.now().millisecondsSinceEpoch}.mp4',
          );
          final file = await token.retainSavedFileUnlessCancelled(savedFile);
          try {
            await _exportService.shareFile(file);
          } catch (_) {
            // The file is already durable; users can share it manually.
          }
          await token.retainSavedFileUnlessCancelled(file);
          return file;
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.looperExportMp4Success)),
        );
      }
    } on ExportCancelledException {
      _log.info('export', 'Looper MP4 export cancelled');
    } catch (error, stackTrace) {
      _log.error(
        'export',
        'Looper MP4 export failed',
        data: {'error': '$error', 'stackTrace': '$stackTrace'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(appFeedbackSnackBar(
          message: l10n.looperExportMp4Failed(error.toString()),
          success: false,
        ));
      }
    } finally {
      controller.loadState(
        params: originalParams,
        view: originalView,
        transparentBackground: originalTransparency,
      );
      if (mounted) setState(_finishExportFlow);
    }
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
    final originalParams = controller.params;
    final originalTransparency = controller.transparentBackground;
    looper.stop();
    try {
      if (!await _exportService.chooseLinuxExportDirectory()) return;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          appFeedbackSnackBar(
            message: l10n.looperExportFailed(error.toString()),
            success: false,
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();

    setState(() {
      _exportSession = _exportSession
          .openSheet(resumeAutoExploreWhenFinished: shouldResumeAutoExplore)
          .startExport();
    });

    try {
      final shareFailed = await _exportService.coordinator.run<bool>(
        ExportKind.looper,
        (token) async {
          final pngFrames = <Uint8List>[];
          for (var i = 0; i < plan.frameCount; i++) {
            token.throwIfCancelled();
            final point = plan.stateAtFrame(i);
            controller.loadState(
              params: point.params,
              view: point.view,
              transparentBackground: controller.transparentBackground,
            );
            await WidgetsBinding.instance.endOfFrame;
            token.throwIfCancelled();
            pngFrames.add(await _exportService.capturePng(
              boundaryKey,
              pixelRatio: 1.0,
            ));
            if (mounted) {
              setState(() {
                _exportSession = _exportSession.updateProgress(
                  (i + 1) / plan.frameCount,
                );
              });
            }
          }

          final frameMs = (1000 / LooperPlan.exportFps).round();
          final bytes = await _exportService.worker
              .runWithInput<(List<Uint8List>, int), Uint8List>(
            _encodeLooperGifFrames,
            (pngFrames, frameMs),
            token: token,
          );
          token.throwIfCancelled();
          final file = await _exportService.saveBytes(
            bytes,
            filename:
                'looper_${controller.module.id}_${DateTime.now().millisecondsSinceEpoch}.gif',
          );
          token.throwIfCancelled();

          try {
            await _exportService.shareFile(
              file,
              text: ViewerShareCaption.build(
                fractalName: controller.module.displayName(l10n),
                shareUrl: DeepLinkService.buildWebUri(
                  moduleId: controller.module.id,
                  params: originalParams,
                  view: originalView,
                  transparentBackground: originalTransparency,
                  rotationLocked: controller.rotationLocked,
                  glowEnabled: controller.glowEnabled,
                  glowSigma: controller.glowSigma,
                  glowIntensity: controller.glowIntensity,
                  kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
                  kaleidoscopeSectors: controller.kaleidoscopeSectors,
                  kaleidoscopeMirror: controller.kaleidoscopeMirror,
                  kaleidoscopeRotation: controller.kaleidoscopeRotation,
                  kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
                ).toString(),
              ),
            );
            token.throwIfCancelled();
            return false;
          } catch (_) {
            token.throwIfCancelled();
            return true;
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shareFailed
                ? l10n.looperExportSavedShareFailed
                : l10n.looperExportSuccess),
          ),
        );
      }
    } on ExportCancelledException {
      _log.info('export', 'Looper export cancelled');
    } catch (error, stackTrace) {
      _log.error(
        'export',
        'Looper export failed',
        data: {'error': '$error', 'stackTrace': '$stackTrace'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          appFeedbackSnackBar(
            message: l10n.looperExportFailed(error.toString()),
            success: false,
          ),
        );
      }
    } finally {
      controller.loadState(
        params: originalParams,
        view: originalView,
        transparentBackground: originalTransparency,
      );
      if (mounted) {
        setState(() {
          _finishExportFlow();
        });
      }
    }
  }

  Future<void> _shareCurrentImage(BuildContext context) async {
    if (_exportSession.phase != ViewerExportPhase.idle) return;
    _log.info('action', 'Quick share image');
    final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
    setState(() {
      _exportSession = _exportSession.openSheet(
        resumeAutoExploreWhenFinished: shouldResumeAutoExplore,
      );
    });

    await _performExport(
      context,
      const ExportOptions(
        format: ExportFormat.jpg,
        resolution: ExportResolution.twitter,
        quality: 90,
      ).copyWith(
        quoteText: _activeQuoteText,
      ),
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
      initialOptions: const ExportOptions().copyWith(
        quoteText: _activeQuoteText,
      ),
      fractalType: controller.module.id,
    );

    if (!mounted) return;

    if (submission == null) {
      setState(() {
        _finishExportFlow();
      });
      return;
    }

    if (submission.action == ExportAction.setWallpaper) {
      await _openWallpaper(context);
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
    final boundarySize = MediaQuery.of(context).size;
    final physicalScreenSize = View.of(context).physicalSize;
    final previousTransparency = controller.transparentBackground;

    if (!await _exportService.chooseLinuxExportDirectory()) {
      if (!mounted) return;
      setState(() {
        _finishExportFlow();
      });
      return;
    }

    setState(() {
      _exportSession = _exportSession.startExport();
    });

    try {
      if (options.transparentBackground) {
        controller.setTransparentBackground(true);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final (result, usedFallback, shareError) =
          await _exportService.coordinator.run<(ExportResult, bool, Object?)>(
        ExportKind.image,
        (token) async {
          late final ExportResult result;
          var usedFallback = false;
          try {
            result = await _exportService.exportWithOptions(
              boundaryKey,
              options: options,
              screenWidth: boundarySize.width,
              screenHeight: boundarySize.height,
              physicalScreenWidth: physicalScreenSize.width,
              physicalScreenHeight: physicalScreenSize.height,
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
          } on ExportCancelledException {
            rethrow;
          } catch (primaryError) {
            _log.error(
              'export',
              'Primary export failed, trying PNG fallback',
              data: {'error': primaryError.toString()},
            );
            result = await _performFallbackPngExport(
              boundaryKey: boundaryKey,
              options: options,
              screenWidth: boundarySize.width,
              screenHeight: boundarySize.height,
              physicalScreenWidth: physicalScreenSize.width,
              physicalScreenHeight: physicalScreenSize.height,
              fractalType: controller.module.id,
              cancellationToken: token,
            );
            usedFallback = true;
          }

          token.throwIfCancelled();
          Object? shareError;
          if (shareAfterSave) {
            try {
              await _exportService.shareExportResult(
                result,
                text: ViewerShareCaption.build(
                  fractalName: controller.module.displayName(l10n),
                  shareUrl: DeepLinkService.buildWebUri(
                    moduleId: controller.module.id,
                    params: controller.params,
                    view: controller.view,
                    transparentBackground: controller.transparentBackground,
                    rotationLocked: controller.rotationLocked,
                    glowEnabled: controller.glowEnabled,
                    glowSigma: controller.glowSigma,
                    glowIntensity: controller.glowIntensity,
                    kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
                    kaleidoscopeSectors: controller.kaleidoscopeSectors,
                    kaleidoscopeMirror: controller.kaleidoscopeMirror,
                    kaleidoscopeRotation: controller.kaleidoscopeRotation,
                    kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
                  ).toString(),
                ),
              );
            } on ExportCancelledException {
              rethrow;
            } catch (error) {
              shareError = error;
              _log.warn(
                'export',
                'Share failed after export saved',
                data: {'error': error.toString()},
              );
            }
          } else {
            await _exportService.saveExportResult(result);
          }
          token.throwIfCancelled();
          return (result, usedFallback, shareError);
        },
      );

      if (mounted) {
        await HapticService.heavy();
        context.read<ExplorationStatsService?>()?.recordScreenshot();

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
    } on ExportCancelledException {
      _log.info('export', 'Image export cancelled');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          appFeedbackSnackBar(
            message: l10n.exportFailed(e.toString()),
            success: false,
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
    final canSetWallpaper = ExportActionAvailability.canSetWallpaper(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
    if (!canSetWallpaper) {
      if (mounted && _exportSession.freezeFrame) {
        setState(_finishExportFlow);
      }
      return;
    }

    if (!_exportSession.freezeFrame) {
      final shouldResumeAutoExplore = _pauseAutoExploreForExportFlow();
      setState(() {
        _exportSession = _exportSession.openSheet(
          resumeAutoExploreWhenFinished: shouldResumeAutoExplore,
        );
      });
    }

    final options = await WallpaperOptionsSheet.show(
      context,
      initial: const WallpaperOptions(),
    );
    if (!mounted) return;

    if (options == null) {
      setState(_finishExportFlow);
      return;
    }

    await _applyWallpaper(context, options);
  }

  Future<void> _applyWallpaper(
    BuildContext context,
    WallpaperOptions options,
  ) async {
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    setState(() {
      _exportSession = _exportSession.startExport();
    });

    try {
      final saveCopy =
          options.saveCopy && await _exportService.chooseLinuxExportDirectory();
      if (!mounted) return;

      final (ok, copyFailed) =
          await _exportService.coordinator.run<(bool, bool)>(
        ExportKind.image,
        (token) async {
          token.throwIfCancelled();
          // Capture the current frame at the device's native resolution
          // (capped), apply the legibility overlay, then hand it to the
          // platform while retaining the global image-export lease.
          final pngBytes = await _exportService.capturePng(
            boundaryKey,
            pixelRatio: devicePixelRatio.clamp(1.0, 3.0).toDouble(),
          );
          token.throwIfCancelled();
          final styled = _exportService.applyWallpaperStyle(
            pngBytes,
            style: options.style.name,
          );
          token.throwIfCancelled();

          // Tracked, not just logged. The copy is something the user asked
          // for, so a failure has to reach them rather than only the log.
          var copyFailed = false;
          if (saveCopy) {
            final filename = _exportService.generateFilename(
              format: ExportFormat.png,
              fractalType: controller.module.id,
            );
            try {
              await _exportService.saveBytes(styled, filename: filename);
            } catch (error) {
              copyFailed = true;
              _log.warn(
                'wallpaper',
                'Save wallpaper copy failed',
                data: {'error': error.toString()},
              );
            }
            token.throwIfCancelled();
          }

          token.throwIfCancelled();
          final ok = await _wallpaperService.setWallpaper(
            styled,
            target: options.target,
          );
          token.throwIfCancelled();
          return (ok, copyFailed);
        },
      );

      if (!mounted) return;
      await HapticService.heavy();
      // iOS can't set wallpaper programmatically — the image was saved to
      // Photos instead, so report that rather than claiming it was applied.
      final savedToPhotosOnly = !kIsWeb && Platform.isIOS;
      final applied = savedToPhotosOnly
          ? l10n.wallpaperSavedToPhotos
          : l10n.wallpaperApplied;
      final successMessage =
          copyFailed ? l10n.wallpaperAppliedCopyFailed : applied;
      ScaffoldMessenger.of(context).showSnackBar(
        appFeedbackSnackBar(
          message: ok ? successMessage : l10n.wallpaperFailed,
          success: ok,
        ),
      );
    } on ExportCancelledException {
      _log.info('wallpaper', 'Wallpaper export cancelled');
    } catch (e) {
      _log.warn('wallpaper', 'Set wallpaper failed',
          data: {'error': e.toString()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        appFeedbackSnackBar(
          message: l10n.wallpaperFailedWithError(e.toString()),
          success: false,
        ),
      );
    } finally {
      if (mounted) {
        setState(_finishExportFlow);
      }
    }
  }

  Future<ExportResult> _performFallbackPngExport({
    required GlobalKey boundaryKey,
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required double physicalScreenWidth,
    required double physicalScreenHeight,
    required String fractalType,
    required ExportCancellationToken cancellationToken,
  }) async {
    cancellationToken.throwIfCancelled();
    final pixelRatio = options
        .calculatePixelRatio(
          screenWidth,
          screenHeight,
          physicalScreenWidth: physicalScreenWidth,
          physicalScreenHeight: physicalScreenHeight,
        )
        .clamp(1.0, 8.0);
    var bytes = await _exportService.capturePng(
      boundaryKey,
      pixelRatio: pixelRatio,
    );
    cancellationToken.throwIfCancelled();
    final targetDims = options.getTargetDimensions(
      screenWidth,
      screenHeight,
      physicalScreenWidth: physicalScreenWidth,
      physicalScreenHeight: physicalScreenHeight,
    );
    bytes = _exportService.resizePngToTargetDimensions(
      bytes,
      width: targetDims.$1,
      height: targetDims.$2,
      quoteText: options.quoteText,
    );
    cancellationToken.throwIfCancelled();

    final filename = _exportService.generateFilename(
      format: ExportFormat.png,
      fractalType: fractalType,
    );
    cancellationToken.throwIfCancelled();
    return _exportService.saveExportBytes(
      bytes,
      filename: filename,
      format: ExportFormat.png,
      width: targetDims.$1,
      height: targetDims.$2,
    );
  }
}
