import 'dart:async';
import 'dart:math' show max;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_zoom_planner.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

export 'auto_explore_zoom_planner.dart' show AutoExploreConfig;

/// Auto navigation mode that performs zoom-only cinematic movement.
///
/// Behavior:
/// - Slowly zooms in from the current zoom to a smart module-aware peak.
/// - Then zooms back out to a smart floor.
/// - Repeats continuously.
///
/// Pan is never modified by this service, so the user can pan freely.
class AutoExploreService extends ChangeNotifier {
  static const Cubic _cinematicCurve = Cubic(0.22, 0.0, 0.15, 1.0);

  final FractalController controller;
  final AutoExploreConfig config;
  late final AutoExploreZoomPlanner _zoomPlanner = AutoExploreZoomPlanner(
    config: config,
  );

  bool _isExploring = false;
  bool _isPaused = false;
  bool _pausedByUserCorrection = false;
  bool _isUserInteracting = false;
  double _speed = 1.0;

  Timer? _timer;
  Timer? _anim;

  double? _cycleBaseZoom;
  double? _lastCorrectionZoom;
  double? _interactionStartZoom;
  bool _zoomingIn = true;

  AutoExploreService({
    required this.controller,
    this.config = const AutoExploreConfig(),
  });

  bool get isExploring => _isExploring;
  bool get isPaused => _isPaused;

  /// True while user interaction temporarily takes control.
  bool get pausedByUserCorrection => _pausedByUserCorrection;

  double get speed => _speed;
  set speed(double v) {
    _speed = AutoExploreSpeed.normalize(v);
    notifyListeners();
  }

  void start() {
    if (_isExploring && !_isPaused) return;

    _isExploring = true;
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _cycleBaseZoom = _clampZoom(controller.view.zoom);
    _lastCorrectionZoom = _cycleBaseZoom;
    _zoomingIn = true;

    _scheduleNext();
    notifyListeners();
  }

  void pause() {
    if (!_isExploring) return;

    _isPaused = true;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _timer?.cancel();
    _anim?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isExploring) {
      start();
      return;
    }

    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _scheduleNext();
    notifyListeners();
  }

  /// Called when user starts a continuous gesture (drag/pinch).
  ///
  /// Auto movement is temporarily suspended so manual pan/zoom is never fought.
  void onUserInteractionStart() {
    if (!_isExploring || _isPaused) return;
    if (_isUserInteracting) return;

    _isUserInteracting = true;
    _pausedByUserCorrection = true;
    _interactionStartZoom = _clampZoom(controller.view.zoom);

    _timer?.cancel();
    _anim?.cancel();
    notifyListeners();
  }

  /// Called when user ends a continuous gesture.
  ///
  /// The user-selected zoom becomes the new baseline and auto mode continues.
  void onUserInteractionEnd() {
    if (!_isExploring) return;

    final referenceZoom = _interactionStartZoom;
    _isUserInteracting = false;
    _interactionStartZoom = null;

    _adoptUserViewAndContinue(referenceZoom: referenceZoom);
  }

  /// Called for one-shot user corrections (mouse wheel, keyboard, etc).
  void onUserCorrection() {
    if (!_isExploring || _isPaused) return;
    _adoptUserViewAndContinue();
  }

  void _adoptUserViewAndContinue({double? referenceZoom}) {
    if (!_isExploring) return;

    final currentZoom = _clampZoom(controller.view.zoom);
    final previousZoom =
        _clampZoom(referenceZoom ?? _lastCorrectionZoom ?? currentZoom);

    const epsilon = 1e-4;
    if (currentZoom > previousZoom * (1.0 + epsilon)) {
      // User zoomed in: continue with zoom-in leg first.
      _zoomingIn = true;
    } else if (currentZoom < previousZoom * (1.0 - epsilon)) {
      // User zoomed out: continue with zoom-out leg first.
      _zoomingIn = false;
    }

    _cycleBaseZoom = currentZoom;
    _lastCorrectionZoom = currentZoom;
    _pausedByUserCorrection = false;

    // Restart leg planning from the user-selected zoom immediately.
    _timer?.cancel();
    _anim?.cancel();
    if (!_isPaused && !_isUserInteracting) {
      _scheduleNext();
    }

    notifyListeners();
  }

  void toggle() {
    if (!_isExploring) return start();
    if (_isPaused) return resume();
    return pause();
  }

  void stop() {
    _isExploring = false;
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _timer?.cancel();
    _anim?.cancel();
    _cycleBaseZoom = null;
    _lastCorrectionZoom = null;
    _zoomingIn = true;
    notifyListeners();
  }

  double _clampZoom(double z) => _zoomPlanner.clampZoom(z);

  double _nextTargetZoom() {
    final current = _clampZoom(controller.view.zoom);
    _cycleBaseZoom ??= current;

    // Direction is flipped only after a leg actually reaches its target.
    // This prevents user pan interruptions from resuming in the opposite
    // direction (the reported "reverse" behavior).
    return _zoomPlanner.nextTargetZoom(
      currentZoom: current,
      cycleBaseZoom: _cycleBaseZoom,
      zoomingIn: _zoomingIn,
      moduleId: controller.module.id,
    );
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (!_isExploring || _isPaused || _isUserInteracting) return;

    // Continuous mode: no dwell/pause between zoom-in and zoom-out legs.
    _timer = Timer(Duration.zero, () async {
      if (!_isExploring || _isPaused || _isUserInteracting) return;

      final targetZoom = _nextTargetZoom();
      final reachedTarget = await _animateZoomTo(targetZoom);

      if (!_isExploring || _isPaused || _isUserInteracting) return;
      if (reachedTarget) {
        _zoomingIn = !_zoomingIn;
      }
      _scheduleNext();
    });
  }

  Duration _durationForZoomLeg(double startZoom, double endZoom) {
    return _zoomPlanner.durationForZoomLeg(
      startZoom: startZoom,
      endZoom: endZoom,
      speed: _speed,
    );
  }

  Future<bool> _animateZoomTo(double targetZoom) async {
    _anim?.cancel();

    final startZoom = _clampZoom(controller.view.zoom);
    final endZoom = _clampZoom(targetZoom);

    final duration = _durationForZoomLeg(startZoom, endZoom);
    const frame = Duration(milliseconds: 16);
    final total =
        max(1, (duration.inMilliseconds / frame.inMilliseconds).round());
    var step = 0;

    final completer = Completer<bool>();
    _anim = Timer.periodic(frame, (timer) {
      if (!_isExploring || _isPaused || _isUserInteracting) {
        timer.cancel();
        _anim = null;
        if (!completer.isCompleted) completer.complete(false);
        return;
      }

      step++;
      final raw = (step / total).clamp(0.0, 1.0);
      final eased = _cinematicCurve.transform(raw);

      controller.updateZoom(_interpolateZoom(startZoom, endZoom, eased));
      _lastCorrectionZoom = _clampZoom(controller.view.zoom);

      if (raw >= 1.0) {
        timer.cancel();
        _anim = null;
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  double _interpolateZoom(double start, double end, double t) {
    return _zoomPlanner.interpolateZoom(start, end, t);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
