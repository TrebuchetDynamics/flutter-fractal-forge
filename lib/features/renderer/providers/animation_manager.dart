import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Callback type for logging changes.
typedef LogChangeCallback = void Function(
  String type,
  String category,
  String message, {
  Map<String, dynamic>? metadata,
});

/// Manages all animation-related state for fractal transitions.
///
/// Responsibilities:
/// - Morph transitions between fractal modules
/// - Celebration effects triggered by discoveries
/// - Animation timer lifecycle
///
/// Extracted from FractalController to follow Single Responsibility Principle.
class AnimationManager {
  bool _isMorphing = false;
  double _morphProgress = 1.0;
  String? _previousModuleId;
  Timer? _morphTimer;
  bool _isCelebrating = false;
  Timer? _celebrationTimer;
  final StreamController<void> _celebrationController =
      StreamController<void>.broadcast();

  // Dependencies
  final bool _isTest;
  final void Function() _notifyListeners;
  final LogChangeCallback _logChange;

  AnimationManager({
    required bool isTest,
    required void Function() notifyListeners,
    required LogChangeCallback logChange,
  })  : _isTest = isTest,
        _notifyListeners = notifyListeners,
        _logChange = logChange;

  // Getters
  bool get isMorphing => _isMorphing;
  double get morphProgress => _morphProgress;
  String? get previousModuleId => _previousModuleId;
  bool get isCelebrating => _isCelebrating;
  Stream<void> get onCelebration => _celebrationController.stream;

  /// Starts a morph transition animation between fractal types.
  void startMorphTransition(String fromModuleId) {
    // Skip timer-based animations in test mode
    if (_isTest) {
      _morphProgress = 1.0;
      _isMorphing = false;
      return;
    }

    _previousModuleId = fromModuleId;
    _isMorphing = true;
    _morphProgress = 0.0;

    HapticFeedback.lightImpact();

    _morphTimer?.cancel();

    const duration = AppAnimations.morphDuration;
    const fps = 60;
    final steps = (duration.inMilliseconds / (1000 / fps)).round();
    var step = 0;

    _morphTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ fps),
      (timer) {
        step++;
        // Use ease-out cubic curve
        final t = step / steps;
        _morphProgress = 1.0 - pow(1.0 - t, 3);
        _notifyListeners();

        if (step >= steps) {
          timer.cancel();
          _morphProgress = 1.0;
          _isMorphing = false;
          _previousModuleId = null;
          _notifyListeners();
        }
      },
    );
  }

  /// Manually triggers a celebration effect.
  void celebrate() {
    if (_isCelebrating) return;

    _isCelebrating = true;
    if (!_isTest) {
      HapticFeedback.mediumImpact();
    }
    _celebrationController.add(null);
    _notifyListeners();

    // Skip timer in test mode
    if (_isTest) {
      _isCelebrating = false;
      return;
    }

    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(AppAnimations.gpuCelebration, () {
      _isCelebrating = false;
      _notifyListeners();
    });

    _logChange('event', 'celebration', 'Celebration triggered');
  }

  /// Cleans up all animation resources.
  void dispose() {
    _morphTimer?.cancel();
    _celebrationTimer?.cancel();
    _celebrationController.close();
  }
}
