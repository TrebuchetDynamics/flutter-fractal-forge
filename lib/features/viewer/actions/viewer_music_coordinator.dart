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
  double? _lastScanZoom;
  int _rescanGeneration = 0;
  bool _moduleRescanPending = false;
  FractalController? _deferredRescanController;

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
  void scheduleRescan(
    FractalController controller, {
    bool moduleChanged = false,
    bool skipMissingScan = false,
  }) {
    if (!_effects.fractalMusicEnabled) return;
    if (!moduleChanged && _moduleRescanPending) {
      _deferredRescanController = controller;
      return;
    }
    _loopRefreshTimer?.cancel();
    _rescanTimer?.cancel();
    final generation = ++_rescanGeneration;
    if (moduleChanged) {
      _moduleRescanPending = true;
      _deferredRescanController = null;
    }
    _rescanTimer = Timer(
      moduleChanged ? Duration.zero : _rescanDelay,
      () async {
        await _doRestart(
          controller,
          generation: generation,
          skipMissingScan: skipMissingScan,
        );
        if (!moduleChanged || generation != _rescanGeneration) return;
        _moduleRescanPending = false;
        final deferred = _deferredRescanController;
        _deferredRescanController = null;
        if (deferred != null) scheduleRescan(deferred);
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
    final hasValidScan = scanFrame != null && scanFrame.isValid;
    _lastScanSignature = hasValidScan ? scanFrame.visualSignature : null;
    _lastScanZoom = hasValidScan ? controller.view.zoom : null;
    scheduleRescan(controller, skipMissingScan: true);
  }

  /// Cancels any pending debounced restart (called when music is disabled).
  void cancelRescan() {
    _rescanGeneration++;
    _moduleRescanPending = false;
    _deferredRescanController = null;
    _rescanTimer?.cancel();
    _loopRefreshTimer?.cancel();
    _lastScanSignature = null;
    _lastScanZoom = null;
  }

  Future<void> _doRestart(
    FractalController controller, {
    required int generation,
    bool skipMissingScan = false,
  }) async {
    if (!_effects.fractalMusicEnabled) return;
    final scanFrame = await _captureFrame();
    if (generation != _rescanGeneration || !_effects.fractalMusicEnabled) {
      return;
    }
    final signature = scanFrame != null && scanFrame.isValid
        ? scanFrame.visualSignature
        : null;
    final scanZoom = controller.view.zoom;
    if (signature == null && skipMissingScan) {
      // Capture can race rendering or fail transiently. Do not restart fallback
      // audio for a missing loop-refresh frame, but keep the refresh loop alive
      // so animated visuals can re-sync on the next successful capture.
      _armLoopRefresh(controller, retryMissingScan: _lastScanSignature == null);
      return;
    }
    if (signature != null &&
        signature == _lastScanSignature &&
        scanZoom == _lastScanZoom) {
      _armLoopRefresh(controller);
      return;
    }
    final result =
        await _effects.restartFractalMusic(controller, scanFrame: scanFrame);
    if (generation != _rescanGeneration) return;
    if (result.failed) {
      _notifyState();
      if (result.enabled) {
        _armLoopRefresh(
          controller,
          retryMissingScan: _lastScanSignature == null,
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
    _lastScanSignature = signature;
    _lastScanZoom = signature == null ? null : scanZoom;
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
    _rescanTimer?.cancel();
    _loopRefreshTimer?.cancel();
    _lastScanSignature = null;
    _lastScanZoom = null;
  }
}
