import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Replayable decision for [AnimatedFractalController.animateParameter].
///
/// Parameter animation only supports finite numeric interpolation. Keeping that
/// contract explicit prevents unsupported boolean/string/non-finite changes from
/// arming a transition that no animation can ever complete.
enum AnimatedParameterTransitionKind {
  unchanged,
  numeric,
  unsupported,
}

/// Finite scalar endpoints for one numeric animation.
///
/// Flutter curves and shader uniforms need replayable finite values; NaN or
/// Infinity would poison every interpolated frame. Keep that guard at the
/// transition boundary instead of relying on callers to sanitize values first.
final class AnimatedScalarTransitionEndpoints {
  final double fromValue;
  final double toValue;

  const AnimatedScalarTransitionEndpoints._({
    required this.fromValue,
    required this.toValue,
  });

  static AnimatedScalarTransitionEndpoints? tryFromValues(
    Object from,
    Object to,
  ) {
    final fromValue = _tryFiniteScalar(from);
    final toValue = _tryFiniteScalar(to);
    if (fromValue == null || toValue == null) return null;

    return AnimatedScalarTransitionEndpoints._(
      fromValue: fromValue,
      toValue: toValue,
    );
  }

  static double? _tryFiniteScalar(Object value) {
    if (value is! num) return null;
    final parsed = value.toDouble();
    return parsed.isFinite ? parsed : null;
  }
}

/// Finite Vector2 endpoints for one pan animation.
final class AnimatedVector2TransitionEndpoints {
  final Vector2 fromValue;
  final Vector2 toValue;

  AnimatedVector2TransitionEndpoints._({
    required Vector2 fromValue,
    required Vector2 toValue,
  })  : fromValue = fromValue.clone(),
        toValue = toValue.clone();

  static AnimatedVector2TransitionEndpoints? tryFromValues(
    Vector2 from,
    Vector2 to,
  ) {
    if (!_isFiniteVector(from) || !_isFiniteVector(to)) return null;
    return AnimatedVector2TransitionEndpoints._(
      fromValue: from,
      toValue: to,
    );
  }

  bool get isUnchanged => fromValue.x == toValue.x && fromValue.y == toValue.y;

  static bool _isFiniteVector(Vector2 value) {
    return value.x.isFinite && value.y.isFinite;
  }
}

/// Finite Vector3 endpoints for one rotation animation.
final class AnimatedVector3TransitionEndpoints {
  final Vector3 fromValue;
  final Vector3 toValue;

  AnimatedVector3TransitionEndpoints._({
    required Vector3 fromValue,
    required Vector3 toValue,
  })  : fromValue = fromValue.clone(),
        toValue = toValue.clone();

  static AnimatedVector3TransitionEndpoints? tryFromValues(
    Vector3 from,
    Vector3 to,
  ) {
    if (!_isFiniteVector(from) || !_isFiniteVector(to)) return null;
    return AnimatedVector3TransitionEndpoints._(
      fromValue: from,
      toValue: to,
    );
  }

  bool get isUnchanged =>
      fromValue.x == toValue.x &&
      fromValue.y == toValue.y &&
      fromValue.z == toValue.z;

  static bool _isFiniteVector(Vector3 value) {
    return value.x.isFinite && value.y.isFinite && value.z.isFinite;
  }
}

/// Pure parameter-transition plan derived from two parameter values.
final class AnimatedParameterTransitionPlan {
  final AnimatedParameterTransitionKind kind;
  final double? fromValue;
  final double? toValue;

  const AnimatedParameterTransitionPlan._({
    required this.kind,
    this.fromValue,
    this.toValue,
  });

  factory AnimatedParameterTransitionPlan.fromValues(Object from, Object to) {
    final scalarEndpoints = AnimatedScalarTransitionEndpoints.tryFromValues(
      from,
      to,
    );
    if (from is num || to is num) {
      if (scalarEndpoints == null) {
        return const AnimatedParameterTransitionPlan._(
          kind: AnimatedParameterTransitionKind.unsupported,
        );
      }
      if (scalarEndpoints.fromValue == scalarEndpoints.toValue) {
        return const AnimatedParameterTransitionPlan._(
          kind: AnimatedParameterTransitionKind.unchanged,
        );
      }
      return AnimatedParameterTransitionPlan._(
        kind: AnimatedParameterTransitionKind.numeric,
        fromValue: scalarEndpoints.fromValue,
        toValue: scalarEndpoints.toValue,
      );
    }

    if (from == to) {
      return const AnimatedParameterTransitionPlan._(
        kind: AnimatedParameterTransitionKind.unchanged,
      );
    }

    return const AnimatedParameterTransitionPlan._(
      kind: AnimatedParameterTransitionKind.unsupported,
    );
  }

  bool get startsTransition => kind == AnimatedParameterTransitionKind.numeric;
}

/// Replayable frame plan for timer-driven animations.
///
/// Morph timers derive curve input from a duration and frame cadence. Keeping
/// that conversion explicit prevents sub-frame durations from producing zero
/// total steps and sending Infinity/NaN into Flutter curves.
final class AnimatedTimelinePlan {
  static const int defaultFramesPerSecond = 60;

  final Duration duration;
  final int framesPerSecond;
  final Duration frameInterval;
  final int totalFrames;

  const AnimatedTimelinePlan._({
    required this.duration,
    required this.framesPerSecond,
    required this.frameInterval,
    required this.totalFrames,
  })  : assert(framesPerSecond > 0, 'framesPerSecond must be positive'),
        assert(frameInterval > Duration.zero, 'frameInterval must be positive'),
        assert(totalFrames > 0, 'totalFrames must be positive');

  factory AnimatedTimelinePlan.forDuration(
    Duration duration, {
    int framesPerSecond = defaultFramesPerSecond,
  }) {
    final safeFramesPerSecond =
        framesPerSecond > 0 ? framesPerSecond : defaultFramesPerSecond;
    final frameIntervalMs = 1000 ~/ safeFramesPerSecond;
    final rawFrames = duration.inMicroseconds <= 0
        ? 1
        : (duration.inMicroseconds *
                safeFramesPerSecond /
                Duration.microsecondsPerSecond)
            .round();

    return AnimatedTimelinePlan._(
      duration: duration,
      framesPerSecond: safeFramesPerSecond,
      frameInterval: Duration(
        milliseconds: frameIntervalMs > 0 ? frameIntervalMs : 1,
      ),
      totalFrames: rawFrames > 0 ? rawFrames : 1,
    );
  }

  bool get isImmediate => duration <= Duration.zero;

  double progressForFrame(int frame) {
    if (frame <= 0) return 0.0;
    return (frame / totalFrames).clamp(0.0, 1.0).toDouble();
  }

  bool isCompleteFrame(int frame) => frame >= totalFrames;
}

/// Replayable progress contract for elapsed timer animations.
///
/// Parameter/view animations are driven by wall-clock elapsed time. A
/// non-positive duration is an immediate transition, matching morph timelines;
/// otherwise a negative duration can leave an animation permanently at 0%.
final class AnimatedElapsedProgress {
  final Duration duration;
  final Duration elapsed;

  const AnimatedElapsedProgress({
    required this.duration,
    required this.elapsed,
  });

  double get value {
    if (duration <= Duration.zero) return 1.0;
    if (elapsed <= Duration.zero) return 0.0;
    return (elapsed.inMicroseconds / duration.inMicroseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool get isComplete => value >= 1.0;
}

/// Service that manages smooth animated transitions for fractal parameters.
///
/// This service provides interpolated values for parameters during transitions,
/// enabling smooth morphing effects when changing fractal settings.
class AnimatedFractalController extends ChangeNotifier {
  /// Animation duration for parameter changes.
  final Duration parameterDuration;

  /// Animation duration for module (fractal type) changes.
  final Duration morphDuration;

  /// Animation curve for transitions.
  final Curve curve;

  // Internal state
  final Map<String, _AnimatedValue> _animatedParams = {};
  _AnimatedValue<double>? _animatedZoom;
  _AnimatedValue<Vector2>? _animatedPan;
  _AnimatedValue<Vector3>? _animatedRotation;

  String? _previousModuleId;
  String? _currentModuleId;
  double _morphProgress = 1.0;
  Timer? _morphTimer;
  Timer? _celebrationTimer;

  bool _isCelebrating = false;
  bool _isTransitioning = false;

  // Interesting spot detection
  int _interestingSpotCount = 0;
  DateTime? _lastInterestingSpotTime;
  final _interestingSpotController = StreamController<void>.broadcast();

  AnimatedFractalController({
    this.parameterDuration = const Duration(milliseconds: 250),
    this.morphDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  /// Stream that emits when an interesting spot is found.
  Stream<void> get onInterestingSpot => _interestingSpotController.stream;

  /// Whether a celebration effect should be shown.
  bool get isCelebrating => _isCelebrating;

  /// Whether the controller is currently transitioning between states.
  bool get isTransitioning => _isTransitioning;

  /// Progress of the current morph transition (0.0 to 1.0).
  double get morphProgress => _morphProgress;

  /// The previous module ID during a morph transition.
  String? get previousModuleId => _previousModuleId;

  /// The current module ID.
  String? get currentModuleId => _currentModuleId;

  /// Start a parameter transition.
  void animateParameter(String id, Object from, Object to) {
    final plan = AnimatedParameterTransitionPlan.fromValues(from, to);
    if (!plan.startsTransition) return;

    _isTransitioning = true;
    notifyListeners();

    _animatedParams[id] = _AnimatedValue<double>(
      from: plan.fromValue!,
      to: plan.toValue!,
      duration: parameterDuration,
      curve: curve,
      onComplete: () {
        _animatedParams.remove(id);
        _checkTransitionComplete();
      },
    );

    notifyListeners();
  }

  /// Animate zoom level transition.
  void animateZoom(double from, double to) {
    final scalarEndpoints = AnimatedScalarTransitionEndpoints.tryFromValues(
      from,
      to,
    );
    if (scalarEndpoints == null ||
        scalarEndpoints.fromValue == scalarEndpoints.toValue) {
      return;
    }

    _isTransitioning = true;
    _animatedZoom = _AnimatedValue<double>(
      from: scalarEndpoints.fromValue,
      to: scalarEndpoints.toValue,
      duration: parameterDuration,
      curve: curve,
      onComplete: () {
        _animatedZoom = null;
        _checkTransitionComplete();
      },
    );
    notifyListeners();
  }

  /// Animate pan transition.
  void animatePan(Vector2 from, Vector2 to) {
    final vectorEndpoints = AnimatedVector2TransitionEndpoints.tryFromValues(
      from,
      to,
    );
    if (vectorEndpoints == null || vectorEndpoints.isUnchanged) return;

    _isTransitioning = true;
    _animatedPan = _AnimatedValue<Vector2>(
      from: vectorEndpoints.fromValue,
      to: vectorEndpoints.toValue,
      duration: parameterDuration,
      curve: curve,
      onComplete: () {
        _animatedPan = null;
        _checkTransitionComplete();
      },
    );
    notifyListeners();
  }

  /// Animate rotation transition.
  void animateRotation(Vector3 from, Vector3 to) {
    final vectorEndpoints = AnimatedVector3TransitionEndpoints.tryFromValues(
      from,
      to,
    );
    if (vectorEndpoints == null || vectorEndpoints.isUnchanged) return;

    _isTransitioning = true;
    _animatedRotation = _AnimatedValue<Vector3>(
      from: vectorEndpoints.fromValue,
      to: vectorEndpoints.toValue,
      duration: parameterDuration,
      curve: curve,
      onComplete: () {
        _animatedRotation = null;
        _checkTransitionComplete();
      },
    );
    notifyListeners();
  }

  /// Start a module morph transition.
  void startMorph(String fromModuleId, String toModuleId) {
    if (fromModuleId == toModuleId) return;

    _previousModuleId = fromModuleId;
    _currentModuleId = toModuleId;
    _morphProgress = 0.0;
    _isTransitioning = true;

    _morphTimer?.cancel();

    final timeline = AnimatedTimelinePlan.forDuration(morphDuration);
    if (timeline.isImmediate) {
      _finishMorphTransition();
      notifyListeners();
      return;
    }

    var step = 0;

    _morphTimer = Timer.periodic(
      timeline.frameInterval,
      (timer) {
        step++;
        _morphProgress = curve.transform(timeline.progressForFrame(step));
        notifyListeners();

        if (timeline.isCompleteFrame(step)) {
          timer.cancel();
          _finishMorphTransition();
          notifyListeners();
        }
      },
    );

    notifyListeners();
  }

  /// Get the interpolated value for a parameter.
  Object? getInterpolatedValue(String id, Object currentValue) {
    final animated = _animatedParams[id];
    if (animated == null) return null;

    if (animated is _AnimatedValue<double>) {
      return animated.currentValue;
    }
    return null;
  }

  /// Get the interpolated zoom value.
  double? get interpolatedZoom => _animatedZoom?.currentValue;

  /// Get the interpolated pan value.
  Vector2? get interpolatedPan => _animatedPan?.currentValue;

  /// Get the interpolated rotation value.
  Vector3? get interpolatedRotation => _animatedRotation?.currentValue;

  /// Record when the user finds an interesting spot.
  ///
  /// Triggers celebration effects when multiple interesting spots
  /// are found in quick succession.
  void recordInterestingSpot() {
    final now = DateTime.now();

    if (_lastInterestingSpotTime != null) {
      final elapsed = now.difference(_lastInterestingSpotTime!);
      if (elapsed.inSeconds < 30) {
        _interestingSpotCount++;

        // Trigger celebration after finding 3 interesting spots quickly
        if (_interestingSpotCount >= 3) {
          _triggerCelebration();
          _interestingSpotCount = 0;
        }
      } else {
        _interestingSpotCount = 1;
      }
    } else {
      _interestingSpotCount = 1;
    }

    _lastInterestingSpotTime = now;
    _interestingSpotController.add(null);
  }

  void _triggerCelebration() {
    _isCelebrating = true;
    notifyListeners();

    // Reset celebration after animation. Keep the timer cancellable so a
    // disposed controller cannot receive a delayed notifyListeners callback.
    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(const Duration(milliseconds: 2500), () {
      _celebrationTimer = null;
      _isCelebrating = false;
      notifyListeners();
    });
  }

  /// Manually trigger a celebration effect.
  void celebrate() {
    _triggerCelebration();
  }

  void _finishMorphTransition() {
    _morphProgress = 1.0;
    _previousModuleId = null;
    _checkTransitionComplete();
  }

  void _checkTransitionComplete() {
    if (_animatedParams.isEmpty &&
        _animatedZoom == null &&
        _animatedPan == null &&
        _animatedRotation == null &&
        _morphProgress >= 1.0) {
      _isTransitioning = false;
      notifyListeners();
    }
  }

  /// Update all animations for the current frame.
  void tick() {
    var needsUpdate = false;

    if (_tickAnimatedParameters()) needsUpdate = true;

    if (_animatedZoom?.tick() == true) needsUpdate = true;
    if (_animatedPan?.tick() == true) needsUpdate = true;
    if (_animatedRotation?.tick() == true) needsUpdate = true;

    if (needsUpdate) {
      notifyListeners();
    }
  }

  bool _tickAnimatedParameters() {
    var needsUpdate = false;

    // Completion callbacks remove entries from [_animatedParams]. Snapshot the
    // values first so a completed parameter does not mutate the map currently
    // being iterated.
    for (final animated in _animatedParams.values.toList(growable: false)) {
      if (animated.tick()) {
        needsUpdate = true;
      }
    }

    return needsUpdate;
  }

  @override
  void dispose() {
    _morphTimer?.cancel();
    _celebrationTimer?.cancel();

    // Close stream controller before disposing
    if (!_interestingSpotController.isClosed) {
      _interestingSpotController.close();
    }

    super.dispose();
  }
}

/// Internal animated value helper.
class _AnimatedValue<T> {
  final T from;
  final T to;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  final DateTime _startTime = DateTime.now();
  bool _completed = false;

  _AnimatedValue({
    required this.from,
    required this.to,
    required this.duration,
    required this.curve,
    this.onComplete,
  });

  AnimatedElapsedProgress get _elapsedProgress => AnimatedElapsedProgress(
        duration: duration,
        elapsed: DateTime.now().difference(_startTime),
      );

  double get _progress => _elapsedProgress.value;

  double get _curvedProgress => curve.transform(_progress);

  bool get isComplete => _elapsedProgress.isComplete;

  T get currentValue {
    final t = _curvedProgress;

    if (T == double) {
      return _lerpDouble(from as double, to as double, t) as T;
    } else if (T == Vector2) {
      return _lerpVector2(from as Vector2, to as Vector2, t) as T;
    } else if (T == Vector3) {
      return _lerpVector3(from as Vector3, to as Vector3, t) as T;
    }
    return to;
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  Vector2 _lerpVector2(Vector2 a, Vector2 b, double t) {
    return Vector2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
    );
  }

  Vector3 _lerpVector3(Vector3 a, Vector3 b, double t) {
    return Vector3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }

  /// Returns true if the animation is still running.
  bool tick() {
    if (_completed) return false;

    if (isComplete && !_completed) {
      _completed = true;
      onComplete?.call();
      return false;
    }

    return !_completed;
  }
}

/// Mixin to add animation capabilities to FractalController.
mixin AnimatedFractalMixin on ChangeNotifier {
  AnimatedFractalController? _animationController;

  /// The animation controller for smooth transitions.
  AnimatedFractalController get animationController {
    _animationController ??= AnimatedFractalController();
    return _animationController!;
  }

  /// Set a custom animation controller.
  set animationController(AnimatedFractalController controller) {
    _animationController = controller;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
