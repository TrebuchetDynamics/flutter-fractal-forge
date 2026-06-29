import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';

/// Owns the music rescan debounce timer and the on-change restart policy.
///
/// Widget-coupled concerns (AnimationController, mounted, context) are injected
/// as callbacks so the coordination logic is testable without a widget tree.
class ViewerMusicCoordinator {
  static const _defaultRescanDelay = Duration(milliseconds: 250);

  final ViewerEffectsController _effects;
  final Future<FractalMusicScanFrame?> Function() _captureFrame;
  final void Function(bool enabled) _syncAnimation;
  final VoidCallback _notifyState;
  final Duration _rescanDelay;

  Timer? _rescanTimer;

  ViewerMusicCoordinator({
    required ViewerEffectsController effects,
    required Future<FractalMusicScanFrame?> Function() captureFrame,
    required void Function(bool enabled) syncAnimation,
    required VoidCallback notifyState,
    @visibleForTesting Duration rescanDelay = _defaultRescanDelay,
  })  : _effects = effects,
        _captureFrame = captureFrame,
        _syncAnimation = syncAnimation,
        _notifyState = notifyState,
        _rescanDelay = rescanDelay;

  /// Arms a debounced restart. No-op when music is currently disabled.
  void scheduleRescan(FractalController controller) {
    if (!_effects.fractalMusicEnabled) return;
    _rescanTimer?.cancel();
    _rescanTimer = Timer(_rescanDelay, () => _doRestart(controller));
  }

  /// Cancels any pending debounced restart (called when music is disabled).
  void cancelRescan() {
    _rescanTimer?.cancel();
  }

  Future<void> _doRestart(FractalController controller) async {
    if (!_effects.fractalMusicEnabled) return;
    final scanFrame = await _captureFrame();
    if (!_effects.fractalMusicEnabled) return;
    final result =
        await _effects.restartFractalMusic(controller, scanFrame: scanFrame);
    if (result.failed || !result.enabled) {
      _notifyState();
      _syncAnimation(false);
      return;
    }
    _syncAnimation(true);
  }

  void dispose() {
    _rescanTimer?.cancel();
  }
}
