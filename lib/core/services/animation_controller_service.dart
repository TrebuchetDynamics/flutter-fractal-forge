import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Replayable decision for [AnimatedFractalController.animateParameter].
///
/// Parameter animation only supports numeric interpolation. Keeping that
/// contract explicit prevents unsupported boolean/string changes from arming a
/// transition that no animation can ever complete.
enum AnimatedParameterTransitionKind {
  unchanged,
  numeric,
  unsupported,
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
    if (from == to) {
      return const AnimatedParameterTransitionPlan._(
        kind: AnimatedParameterTransitionKind.unchanged,
      );
    }

    if (from is num && to is num) {
      return AnimatedParameterTransitionPlan._(
        kind: AnimatedParameterTransitionKind.numeric,
        fromValue: from.toDouble(),
        toValue: to.toDouble(),
      );
    }

    return const AnimatedParameterTransitionPlan._(
      kind: AnimatedParameterTransitionKind.unsupported,
    );
  }

  bool get startsTransition => kind == AnimatedParameterTransitionKind.numeric;
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
    if (from == to) return;

    _isTransitioning = true;
    _animatedZoom = _AnimatedValue<double>(
      from: from,
      to: to,
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
    if (from.x == to.x && from.y == to.y) return;

    _isTransitioning = true;
    _animatedPan = _AnimatedValue<Vector2>(
      from: from.clone(),
      to: to.clone(),
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
    if (from.x == to.x && from.y == to.y && from.z == to.z) return;

    _isTransitioning = true;
    _animatedRotation = _AnimatedValue<Vector3>(
      from: from.clone(),
      to: to.clone(),
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

    const fps = 60;
    final steps = (morphDuration.inMilliseconds / (1000 / fps)).round();
    var step = 0;

    _morphTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ fps),
      (timer) {
        step++;
        _morphProgress = curve.transform(step / steps);
        notifyListeners();

        if (step >= steps) {
          timer.cancel();
          _morphProgress = 1.0;
          _previousModuleId = null;
          _checkTransitionComplete();
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

    // Reset celebration after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      _isCelebrating = false;
      notifyListeners();
    });
  }

  /// Manually trigger a celebration effect.
  void celebrate() {
    _triggerCelebration();
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

    for (final animated in _animatedParams.values) {
      if (animated.tick()) {
        needsUpdate = true;
      }
    }

    if (_animatedZoom?.tick() == true) needsUpdate = true;
    if (_animatedPan?.tick() == true) needsUpdate = true;
    if (_animatedRotation?.tick() == true) needsUpdate = true;

    if (needsUpdate) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _morphTimer?.cancel();

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

  double get _progress {
    final elapsed = DateTime.now().difference(_startTime);
    return (elapsed.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
  }

  double get _curvedProgress => curve.transform(_progress);

  bool get isComplete => _progress >= 1.0;

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
