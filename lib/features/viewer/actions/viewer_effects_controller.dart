import 'dart:io';

import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';

class ViewerMusicToggleResult {
  final bool enabled;
  final Object? error;

  const ViewerMusicToggleResult._({required this.enabled, this.error});

  const ViewerMusicToggleResult.enabled() : this._(enabled: true);
  const ViewerMusicToggleResult.disabled() : this._(enabled: false);
  const ViewerMusicToggleResult.failed(Object error)
      : this._(enabled: false, error: error);

  bool get failed => error != null;
}

class ViewerEffectsController {
  static const defaultReportTags = FractalReportService.defaultTags;

  final FractalMusicService _musicService;
  final FractalReportService _reportService;
  final AppLogger _log;

  bool fractalMusicEnabled = false;

  ViewerEffectsController({
    FractalMusicService? musicService,
    FractalReportService? reportService,
    AppLogger? log,
  })  : _musicService = musicService ?? FractalMusicService(),
        _reportService = reportService ?? const FractalReportService(),
        _log = log ?? AppLogger.instance;

  Future<ViewerMusicToggleResult> toggleFractalMusic(
    FractalController controller,
  ) async {
    final next = !fractalMusicEnabled;
    try {
      if (next) {
        await _musicService.play(controller);
      } else {
        await _musicService.stop();
      }
      fractalMusicEnabled = next;
      return next
          ? const ViewerMusicToggleResult.enabled()
          : const ViewerMusicToggleResult.disabled();
    } catch (error) {
      fractalMusicEnabled = false;
      _log.warn('audio', 'Fractal Music unavailable',
          data: {'error': '$error'});
      return ViewerMusicToggleResult.failed(error);
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
      visualState: {
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
      },
    );
  }

  void dispose() {
    _musicService.dispose();
  }
}
