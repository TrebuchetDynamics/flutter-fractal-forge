import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_runtime_state.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_zoom_planner.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';

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
  Completer<bool>? _animCompleter;

  double? _cycleBaseZoom;
  double? _lastCorrectionZoom;
  double? _interactionStartZoom;
  bool _zoomingIn = true;
  late String _lastModuleId;

  AutoExploreService({
    required this.controller,
    this.config = const AutoExploreConfig(),
  }) {
    _lastModuleId = controller.module.id;
    controller.addListener(_handleControllerChanged);
  }

  bool get isExploring => _isExploring;
  bool get isPaused => _isPaused;

  /// True while user interaction temporarily takes control.
  bool get pausedByUserCorrection => _pausedByUserCorrection;

  /// Test-only: whether a zoom-leg animation future is still unresolved.
  ///
  /// Used to assert that interrupting motion resolves the in-flight
  /// [_animateZoomTo] future instead of leaking a suspended async frame.
  @visibleForTesting
  bool get debugHasPendingAnimation => _animCompleter != null;

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
    _cancelScheduledMotion();
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

    _cancelScheduledMotion();
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
    _cancelScheduledMotion();
    if (!_isPaused && !_isUserInteracting) {
      _scheduleNext();
    }

    notifyListeners();
  }

  void toggle() {
    switch (_runtimeState.toggleTransition) {
      case AutoExploreToggleTransition.start:
        return start();
      case AutoExploreToggleTransition.resume:
        return resume();
      case AutoExploreToggleTransition.pause:
        return pause();
    }
  }

  void stop() {
    _transitionToStopped(notify: true);
  }

  void _transitionToStopped({required bool notify}) {
    _isExploring = false;
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _cancelScheduledMotion();
    _cycleBaseZoom = null;
    _lastCorrectionZoom = null;
    _zoomingIn = true;
    if (notify) notifyListeners();
  }

  void _handleControllerChanged() {
    final moduleId = controller.module.id;
    if (moduleId == _lastModuleId) return;

    _lastModuleId = moduleId;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _zoomingIn = true;
    _adoptCurrentZoomAsCycleBase();
    _cancelScheduledMotion();

    if (_isExploring && !_isPaused) {
      _scheduleNext();
    }
    notifyListeners();
  }

  void _cancelScheduledMotion() {
    _timer?.cancel();
    _timer = null;
    _anim?.cancel();
    _anim = null;
    // Cancelling the periodic timer stops it from ever ticking again, so the
    // in-flight _animateZoomTo() future would otherwise hang forever (its
    // completer only fires from inside the timer callback). Resolve it as "not
    // reached" so the awaiting _scheduleNext continuation unwinds instead of
    // leaking a suspended async frame on every interrupted leg.
    final pending = _animCompleter;
    _animCompleter = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete(false);
    }
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
    _timer = null;
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
    _anim = null;

    final plan = _zoomPlanner.animationPlanForZoomLeg(
      startZoom: controller.view.zoom,
      endZoom: targetZoom,
      speed: _speed,
    );
    var step = 0;

    final completer = Completer<bool>();
    _animCompleter = completer;
    _anim = Timer.periodic(plan.frameInterval, (timer) {
      if (_runtimeState.shouldInterruptAnimation) {
        timer.cancel();
        _anim = null;
        _animCompleter = null;
        if (!completer.isCompleted) completer.complete(false);
        return;
      }

      step++;
      final progress = plan.progressForFrame(step);
      final eased = _cinematicCurve.transform(progress.raw);

      controller.updateView(
        controller.view.copyWith(zoom: plan.interpolate(eased)),
        adaptIterationsForZoom: true,
      );
      _lastCorrectionZoom = _clampZoom(controller.view.zoom);

      if (progress.reachedEnd) {
        timer.cancel();
        _anim = null;
        _animCompleter = null;
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChanged);
    _transitionToStopped(notify: false);
    super.dispose();
  }
}
