import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_runtime_state.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_zoom_planner.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

export 'auto_explore_zoom_planner.dart'
    show AutoExploreConfig, AutoExploreSpeed;

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
    _adoptCurrentZoomAsCycleBase();
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
    _adoptCurrentZoomAsCycleBase();
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
    if (!_runtimeState.canAdoptContinuousInteractionEnd) return;

    final referenceZoom = _interactionStartZoom;
    _isUserInteracting = false;
    _interactionStartZoom = null;

    _adoptUserViewAndContinue(referenceZoom: referenceZoom);
  }

  /// Called for one-shot user corrections (mouse wheel, keyboard, etc).
  void onUserCorrection() {
    if (!AutoExploreUserCorrectionPolicy.shouldAdoptOneShotCorrection(
      _runtimeState,
    )) {
      return;
    }
    _adoptUserViewAndContinue();
  }

  void _adoptUserViewAndContinue({double? referenceZoom}) {
    if (!_isExploring) return;

    final adoption = _adoptedZoom(referenceZoom: referenceZoom);
    _zoomingIn = adoption.zoomingIn;

    _cycleBaseZoom = adoption.currentZoom;
    _lastCorrectionZoom = adoption.currentZoom;
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

  AutoExploreRuntimeState get _runtimeState => AutoExploreRuntimeState(
        isExploring: _isExploring,
        isPaused: _isPaused,
        isUserInteracting: _isUserInteracting,
        pausedByUserCorrection: _pausedByUserCorrection,
      );

  AutoExploreZoomAdoption _adoptedZoom({double? referenceZoom}) {
    return AutoExploreZoomAdoption.fromSamples(
      bounds: AutoExploreZoomBounds.fromConfig(config),
      currentZoom: controller.view.zoom,
      referenceZoom: referenceZoom,
      lastCorrectionZoom: _lastCorrectionZoom,
      wasZoomingIn: _zoomingIn,
    );
  }

  void _adoptCurrentZoomAsCycleBase() {
    final currentZoom = _clampZoom(controller.view.zoom);
    _cycleBaseZoom = currentZoom;
    _lastCorrectionZoom = currentZoom;
  }

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
    if (!_runtimeState.canScheduleZoomLeg) return;

    // Continuous mode: no dwell/pause between zoom-in and zoom-out legs.
    _timer = Timer(Duration.zero, () async {
      if (!_runtimeState.canScheduleZoomLeg) return;

      final targetZoom = _nextTargetZoom();
      final reachedTarget = await _animateZoomTo(targetZoom);

      if (!_runtimeState.canScheduleZoomLeg) return;
      if (reachedTarget) {
        _zoomingIn = !_zoomingIn;
      }
      _scheduleNext();
    });
  }

  Future<bool> _animateZoomTo(double targetZoom) async {
    _anim?.cancel();

    final plan = _zoomPlanner.animationPlanForZoomLeg(
      startZoom: controller.view.zoom,
      endZoom: targetZoom,
      speed: _speed,
    );
    var step = 0;

    final completer = Completer<bool>();
    _anim = Timer.periodic(plan.frameInterval, (timer) {
      if (_runtimeState.shouldInterruptAnimation) {
        timer.cancel();
        _anim = null;
        if (!completer.isCompleted) completer.complete(false);
        return;
      }

      step++;
      final progress = plan.progressForFrame(step);
      final eased = _cinematicCurve.transform(progress.raw);

      controller.updateZoom(plan.interpolate(eased));
      _lastCorrectionZoom = _clampZoom(controller.view.zoom);

      if (progress.reachedEnd) {
        timer.cancel();
        _anim = null;
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
