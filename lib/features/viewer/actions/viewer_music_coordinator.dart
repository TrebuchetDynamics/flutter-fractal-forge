import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_fractals/features/viewer/audio/fourier_music_features.dart';

/// Owns the music rescan debounce timer and the on-change restart policy.
///
/// Widget-coupled concerns (AnimationController, mounted, context) are injected
/// as callbacks so the coordination logic is testable without a widget tree.
class ViewerMusicCoordinator {
  static const _defaultRescanDelay = Duration(milliseconds: 180);
  static const _defaultMaxContinuousRescanDelay = Duration(milliseconds: 900);

  final ViewerEffectsController _effects;
  final Future<FractalMusicScanFrame?> Function() _captureFrame;
  final void Function(bool enabled) _syncAnimation;
  final VoidCallback _notifyState;
  final double Function() _scanProgress;
  final FourierMusicFeatures? Function()? _currentFourierFeatures;
  final Duration _rescanDelay;
  final Duration _maxContinuousRescanDelay;
  final Duration _loopRefreshDelay;

  Timer? _rescanTimer;
  DateTime? _rescanBurstStartedAt;
  Timer? _loopRefreshTimer;
  FractalMusicFeatures? _lastFeatures;
  double? _lastScanZoom;
  int _rescanGeneration = 0;
  int _restartOperations = 0;
  bool _moduleRescanPending = false;
  FractalController? _deferredRescanController;
  FractalController? _queuedMotionController;
  bool _deferredRescanAlignToBar = false;
  bool _queuedMotionAlignToBar = false;

  ViewerMusicCoordinator({
    required ViewerEffectsController effects,
    required Future<FractalMusicScanFrame?> Function() captureFrame,
    required void Function(bool enabled) syncAnimation,
    required VoidCallback notifyState,
    required double Function() scanProgress,
    FourierMusicFeatures? Function()? currentFourierFeatures,
    @visibleForTesting Duration rescanDelay = _defaultRescanDelay,
    @visibleForTesting
    Duration maxContinuousRescanDelay = _defaultMaxContinuousRescanDelay,
    @visibleForTesting Duration loopRefreshDelay = fractalMusicLoopDuration,
  })  : _effects = effects,
        _captureFrame = captureFrame,
        _syncAnimation = syncAnimation,
        _notifyState = notifyState,
        _scanProgress = scanProgress,
        _currentFourierFeatures = currentFourierFeatures,
        _rescanDelay = rescanDelay,
        _maxContinuousRescanDelay = maxContinuousRescanDelay,
        _loopRefreshDelay = loopRefreshDelay;

  /// Arms a debounced restart. No-op when music is currently disabled.
  void scheduleRescan(
    FractalController controller, {
    bool moduleChanged = false,
    bool skipMissingScan = false,
    bool alignToBar = false,
  }) {
    if (!_effects.fractalMusicEnabled) return;
    if (!moduleChanged && _moduleRescanPending) {
      _deferredRescanController = controller;
      _deferredRescanAlignToBar |= alignToBar;
      return;
    }
    _loopRefreshTimer?.cancel();
    final now = DateTime.now();
    final burstStartedAt = _rescanBurstStartedAt ??= now;
    _rescanTimer?.cancel();
    if (_restartOperations > 0 && !moduleChanged) {
      _queuedMotionController = controller;
      _queuedMotionAlignToBar |= alignToBar;
      return;
    }
    final generation = ++_rescanGeneration;
    if (_restartOperations > 0) {
      unawaited(_effects.cancelPendingFractalMusicPlayback());
    }
    if (moduleChanged) {
      _moduleRescanPending = true;
      _deferredRescanController = null;
    }
    final elapsed = now.difference(burstStartedAt);
    final remainingDeadline = _maxContinuousRescanDelay - elapsed;
    final delay = moduleChanged
        ? Duration.zero
        : remainingDeadline <= Duration.zero
            ? Duration.zero
            : remainingDeadline < _rescanDelay
                ? remainingDeadline
                : _rescanDelay;
    _rescanTimer = Timer(
      delay,
      () async {
        _rescanBurstStartedAt = null;
        await _doRestart(
          controller,
          generation: generation,
          skipMissingScan: skipMissingScan,
          alignToBar: alignToBar,
        );
        if (!moduleChanged || generation != _rescanGeneration) return;
        _moduleRescanPending = false;
        final deferred = _deferredRescanController;
        final deferredAlignToBar = _deferredRescanAlignToBar;
        _deferredRescanController = null;
        _deferredRescanAlignToBar = false;
        if (deferred != null) {
          scheduleRescan(deferred, alignToBar: deferredAlignToBar);
        }
      },
    );
  }

  /// Starts periodic loop-refresh after the initial user-triggered play.
  void startLoopRefresh(
    FractalController controller, {
    FractalMusicScanFrame? scanFrame,
  }) {
    _rescanGeneration++;
    _moduleRescanPending = false;
    _deferredRescanController = null;
    _deferredRescanAlignToBar = false;
    final hasValidScan = scanFrame != null && scanFrame.isValid;
    _lastFeatures = hasValidScan ? fractalMusicFeaturesOf(scanFrame) : null;
    _lastScanZoom = hasValidScan ? controller.view.zoom : null;
    scheduleRescan(controller, skipMissingScan: true);
  }

  /// Cancels any pending debounced restart (called when music is disabled).
  void cancelRescan() {
    _rescanGeneration++;
    if (_restartOperations > 0) {
      unawaited(_effects.cancelPendingFractalMusicPlayback());
    }
    _moduleRescanPending = false;
    _deferredRescanController = null;
    _queuedMotionController = null;
    _deferredRescanAlignToBar = false;
    _queuedMotionAlignToBar = false;
    _rescanTimer?.cancel();
    _rescanBurstStartedAt = null;
    _loopRefreshTimer?.cancel();
    _lastFeatures = null;
    _lastScanZoom = null;
  }

  Future<void> _doRestart(
    FractalController controller, {
    required int generation,
    bool skipMissingScan = false,
    bool alignToBar = false,
  }) async {
    if (!_effects.fractalMusicEnabled) return;
    final scanFrame = await _captureFrame();
    if (generation != _rescanGeneration || !_effects.fractalMusicEnabled) {
      return;
    }
    final features = scanFrame != null && scanFrame.isValid
        ? fractalMusicFeaturesOf(scanFrame)
        : null;
    final scanZoom = controller.view.zoom;
    if (features == null && skipMissingScan) {
      // Capture can race rendering or fail transiently. Do not restart fallback
      // audio for a missing loop-refresh frame, but keep the refresh loop alive
      // so animated visuals can re-sync on the next successful capture.
      _armLoopRefresh(controller, retryMissingScan: _lastFeatures == null);
      return;
    }
    // Compare what the music actually depends on. A per-pixel hash restarts the
    // piece for one antialiased edge pixel; the collapsed features do not move
    // for a nudge that cannot change a note.
    final previousFeatures = _lastFeatures;
    if (features != null &&
        previousFeatures != null &&
        !features.differsFrom(previousFeatures) &&
        scanZoom == _lastScanZoom) {
      _armLoopRefresh(controller);
      return;
    }
    _restartOperations++;
    late final ViewerMusicToggleResult result;
    try {
      result = await _effects.restartFractalMusic(
        controller,
        scanFrame: scanFrame,
        fourierFeatures: _currentFourierFeatures?.call(),
        startProgressProvider: _scanProgress,
        shouldCommit: () =>
            generation == _rescanGeneration && _effects.fractalMusicEnabled,
        beforeCommit:
            alignToBar ? () => _waitForNextBarBoundary(generation) : null,
      );
    } finally {
      _restartOperations--;
      if (_restartOperations == 0) {
        final queued = _queuedMotionController;
        final queuedAlignToBar = _queuedMotionAlignToBar;
        _queuedMotionController = null;
        _queuedMotionAlignToBar = false;
        if (queued != null && _effects.fractalMusicEnabled) {
          scheduleRescan(queued, alignToBar: queuedAlignToBar);
        }
      }
    }
    if (generation != _rescanGeneration) return;
    if (result.failed) {
      _notifyState();
      if (result.enabled) {
        _armLoopRefresh(
          controller,
          retryMissingScan: _lastFeatures == null,
        );
      } else {
        _syncAnimation(false);
      }
      return;
    }
    if (!result.enabled) {
      _notifyState();
      _syncAnimation(false);
      return;
    }
    _lastFeatures = features;
    _lastScanZoom = features == null ? null : scanZoom;
    // Playback is rotated to the current beam phase, so the visible scanner
    // keeps moving instead of jumping back to twelve o'clock.
    _armLoopRefresh(controller, retryMissingScan: features == null);
  }

  Future<void> _waitForNextBarBoundary(int generation) async {
    final initialBar = _barAt(_scanProgress());
    while (generation == _rescanGeneration && _effects.fractalMusicEnabled) {
      await Future<void>.delayed(const Duration(milliseconds: 8));
      if (_barAt(_scanProgress()) != initialBar) return;
    }
  }

  int _barAt(double progress) {
    if (!progress.isFinite) return 0;
    final wrapped = ((progress % 1) + 1) % 1;
    return (wrapped * 4).floor().clamp(0, 3);
  }

  void _armLoopRefresh(
    FractalController controller, {
    bool retryMissingScan = false,
  }) {
    _loopRefreshTimer?.cancel();
    if (!_effects.fractalMusicEnabled) return;
    if (_lastFeatures == null && !retryMissingScan) return;
    final generation = _rescanGeneration;
    _loopRefreshTimer = Timer(
      _loopRefreshDelay,
      () => _doRestart(
        controller,
        generation: generation,
        skipMissingScan: true,
      ),
    );
  }

  void dispose() {
    _rescanGeneration++;
    _moduleRescanPending = false;
    _deferredRescanController = null;
    _queuedMotionController = null;
    _deferredRescanAlignToBar = false;
    _queuedMotionAlignToBar = false;
    _rescanTimer?.cancel();
    _rescanBurstStartedAt = null;
    _loopRefreshTimer?.cancel();
    _lastFeatures = null;
    _lastScanZoom = null;
  }
}
