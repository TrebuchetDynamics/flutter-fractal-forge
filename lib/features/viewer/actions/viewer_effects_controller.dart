import 'dart:io';

import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';

class ViewerMusicToggleResult {
  final bool enabled;
  final Object? error;

  const ViewerMusicToggleResult._({required this.enabled, this.error});

  const ViewerMusicToggleResult.enabled() : this._(enabled: true);
  const ViewerMusicToggleResult.disabled() : this._(enabled: false);
  const ViewerMusicToggleResult.failed(
    Object error, {
    bool enabled = false,
  }) : this._(enabled: enabled, error: error);

  bool get failed => error != null;
}

class ViewerEffectsController {
  static const defaultReportTags = FractalReportService.defaultTags;

  final FractalMusicService _musicService;
  final FractalReportService _reportService;
  final AppLogger _log;

  bool fractalMusicEnabled = false;
  bool _disposed = false;
  Future<void> _musicQueue = Future.value();

  ViewerEffectsController({
    FractalMusicService? musicService,
    FractalReportService? reportService,
    AppLogger? log,
  })  : _musicService = musicService ?? FractalMusicService(),
        _reportService = reportService ?? const FractalReportService(),
        _log = log ?? AppLogger.instance;

  Future<ViewerMusicToggleResult> toggleFractalMusic(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) {
    return _enqueueMusicOperation(
      () => _toggleFractalMusicNow(controller, scanFrame: scanFrame),
    );
  }

  Future<ViewerMusicToggleResult> _toggleFractalMusicNow(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) async {
    final next = !fractalMusicEnabled;
    try {
      if (next) {
        await _musicService.play(controller, scanFrame: scanFrame);
      } else {
        await _musicService.stop();
      }
      if (_disposed) {
        fractalMusicEnabled = false;
        if (next) await _stopAfterDisposedPlay();
        return const ViewerMusicToggleResult.disabled();
      }
      fractalMusicEnabled = next;
      return next
          ? const ViewerMusicToggleResult.enabled()
          : const ViewerMusicToggleResult.disabled();
    } catch (error) {
      fractalMusicEnabled = !next;
      _log.warn('audio', 'Fractal Music unavailable',
          data: {'error': '$error'});
      return ViewerMusicToggleResult.failed(
        error,
        enabled: fractalMusicEnabled,
      );
    }
  }

  Future<ViewerMusicToggleResult> restartFractalMusic(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) {
    return _enqueueMusicOperation(
      () => _restartFractalMusicNow(controller, scanFrame: scanFrame),
    );
  }

  Future<ViewerMusicToggleResult> _restartFractalMusicNow(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) async {
    if (_disposed || !fractalMusicEnabled) {
      return const ViewerMusicToggleResult.disabled();
    }
    try {
      await _musicService.play(controller, scanFrame: scanFrame);
      if (_disposed) {
        fractalMusicEnabled = false;
        await _stopAfterDisposedPlay();
        return const ViewerMusicToggleResult.disabled();
      }
      return const ViewerMusicToggleResult.enabled();
    } catch (error) {
      fractalMusicEnabled = error is FractalMusicStopFailure;
      _log.warn('audio', 'Fractal Music restart failed',
          data: {'error': '$error'});
      return ViewerMusicToggleResult.failed(
        error,
        enabled: fractalMusicEnabled,
      );
    }
  }

  Future<ViewerMusicToggleResult> _enqueueMusicOperation(
    Future<ViewerMusicToggleResult> Function() operation,
  ) {
    final result = _musicQueue.then((_) async {
      if (_disposed) return const ViewerMusicToggleResult.disabled();
      return operation();
    });
    _musicQueue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<void> _stopAfterDisposedPlay() async {
    try {
      await _musicService.stop();
    } catch (error) {
      _log.warn('audio', 'Fractal Music dispose cleanup failed',
          data: {'error': '$error'});
    }
  }

  Future<File> saveFractalReport({
    required FractalController controller,
    required String moduleName,
    required String shareUrl,
    required List<String> tags,
    String notes = '',
  }) {
    return _reportService.save(
      moduleId: controller.module.id,
      moduleName: moduleName,
      tags: List<String>.from(tags)..sort(),
      params: controller.params,
      view: controller.view,
      shareUrl: shareUrl,
      notes: notes,
      visualState: _reportVisualState(controller),
    );
  }

  String buildFractalReportJson({
    required FractalController controller,
    required String moduleName,
    required String shareUrl,
    required List<String> tags,
    String notes = '',
  }) {
    return _reportService.buildJson(
      moduleId: controller.module.id,
      moduleName: moduleName,
      tags: List<String>.from(tags)..sort(),
      params: controller.params,
      view: controller.view,
      shareUrl: shareUrl,
      notes: notes,
      visualState: _reportVisualState(controller),
    );
  }

  Map<String, Object?> _reportVisualState(FractalController controller) => {
        'transparentBackground': controller.transparentBackground,
        'rotationLocked': controller.rotationLocked,
        'glowEnabled': controller.glowEnabled,
        'glowSigma': controller.glowSigma,
        'glowIntensity': controller.glowIntensity,
        'kaleidoscopeEnabled': controller.kaleidoscopeEnabled,
        'kaleidoscopeSectors': controller.kaleidoscopeSectors,
        'kaleidoscopeMirror': controller.kaleidoscopeMirror,
        'kaleidoscopeRotation': controller.kaleidoscopeRotation,
        'kaleidoscopeMirrorMode': controller.kaleidoscopeMirrorMode,
      };

  void dispose() {
    _disposed = true;
    fractalMusicEnabled = false;
    _musicService.dispose();
  }
}
