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
  static const _defaultRescanDelay = Duration(milliseconds: 700);

  final ViewerEffectsController _effects;
  final Future<FractalMusicScanFrame?> Function() _captureFrame;
  final void Function(bool enabled) _syncAnimation;
  final VoidCallback _notifyState;
  final Duration _rescanDelay;
  final Duration _loopRefreshDelay;

  Timer? _rescanTimer;
  Timer? _loopRefreshTimer;
  int? _lastScanSignature;

  ViewerMusicCoordinator({
    required ViewerEffectsController effects,
    required Future<FractalMusicScanFrame?> Function() captureFrame,
    required void Function(bool enabled) syncAnimation,
    required VoidCallback notifyState,
    @visibleForTesting Duration rescanDelay = _defaultRescanDelay,
    @visibleForTesting Duration loopRefreshDelay = fractalMusicLoopDuration,
  })  : _effects = effects,
        _captureFrame = captureFrame,
        _syncAnimation = syncAnimation,
        _notifyState = notifyState,
        _rescanDelay = rescanDelay,
        _loopRefreshDelay = loopRefreshDelay;

  /// Arms a debounced restart. No-op when music is currently disabled.
  void scheduleRescan(FractalController controller) {
    if (!_effects.fractalMusicEnabled) return;
    _loopRefreshTimer?.cancel();
    _rescanTimer?.cancel();
    _rescanTimer = Timer(_rescanDelay, () => _doRestart(controller));
  }

  /// Starts periodic loop-refresh after the initial user-triggered play.
  void startLoopRefresh(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) {
    _lastScanSignature = scanFrame?.visualSignature;
    _armLoopRefresh(controller, retryMissingScan: scanFrame == null);
  }

  /// Cancels any pending debounced restart (called when music is disabled).
  void cancelRescan() {
    _rescanTimer?.cancel();
    _loopRefreshTimer?.cancel();
    _lastScanSignature = null;
  }

  Future<void> _doRestart(
    FractalController controller, {
    bool skipMissingScan = false,
  }) async {
    if (!_effects.fractalMusicEnabled) return;
    final scanFrame = await _captureFrame();
    if (!_effects.fractalMusicEnabled) return;
    final signature = scanFrame?.visualSignature;
    if (signature == null && skipMissingScan) {
      // Capture can race rendering or fail transiently. Do not restart fallback
      // audio for a missing loop-refresh frame, but keep the refresh loop alive
      // so animated visuals can re-sync on the next successful capture.
      _armLoopRefresh(controller, retryMissingScan: _lastScanSignature == null);
      return;
    }
    if (signature != null && signature == _lastScanSignature) {
      _syncAnimation(true);
      _armLoopRefresh(controller);
      return;
    }
    final result =
        await _effects.restartFractalMusic(controller, scanFrame: scanFrame);
    if (result.failed || !result.enabled) {
      _notifyState();
      _syncAnimation(false);
      return;
    }
    _lastScanSignature = signature;
    _syncAnimation(true);
    _armLoopRefresh(controller, retryMissingScan: signature == null);
  }

  void _armLoopRefresh(
    FractalController controller, {
    bool retryMissingScan = false,
  }) {
    _loopRefreshTimer?.cancel();
    if (!_effects.fractalMusicEnabled) return;
    if (_lastScanSignature == null && !retryMissingScan) return;
    _loopRefreshTimer = Timer(
      _loopRefreshDelay,
      () => _doRestart(controller, skipMissingScan: true),
    );
  }

  void dispose() {
    _rescanTimer?.cancel();
    _loopRefreshTimer?.cancel();
    _lastScanSignature = null;
  }
}
