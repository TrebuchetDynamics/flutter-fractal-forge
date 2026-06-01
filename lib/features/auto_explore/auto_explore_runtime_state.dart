/// Pure playback-state contract for [AutoExploreService].
///
/// The service owns timers and controller side effects, but scheduling decisions
/// depend only on these flags. Keeping that contract replayable makes hidden
/// state-order assumptions testable without a wall-clock timer.
class AutoExploreRuntimeState {
  final bool isExploring;
  final bool isPaused;
  final bool isUserInteracting;
  final bool pausedByUserCorrection;

  const AutoExploreRuntimeState({
    required this.isExploring,
    required this.isPaused,
    required this.isUserInteracting,
    required this.pausedByUserCorrection,
  }) : assert(
          !pausedByUserCorrection || (isExploring && !isPaused),
          'pausedByUserCorrection is only valid while auto-explore is armed',
        );

  /// A new auto-zoom leg can start only when auto-explore owns motion.
  ///
  /// Treat [pausedByUserCorrection] as its own motion blocker instead of
  /// relying on [isUserInteracting] to also be true. That keeps release builds
  /// safe if timer callbacks observe a transient flag-order mismatch.
  bool get canScheduleZoomLeg =>
      isExploring && !isPaused && !isUserInteracting && !pausedByUserCorrection;

  /// An in-flight animation must stop as soon as auto-explore loses motion.
  bool get shouldInterruptAnimation => !canScheduleZoomLeg;
}

/// Pure gate for one-shot user corrections such as mouse-wheel zooms.
///
/// Continuous gestures are already represented by [isUserInteracting] and use
/// [AutoExploreService.onUserInteractionEnd] to adopt the final zoom once. A
/// wheel/keyboard correction delivered during that gesture must not clear the
/// temporary user-correction pause early.
class AutoExploreUserCorrectionPolicy {
  const AutoExploreUserCorrectionPolicy._();

  static bool shouldAdoptOneShotCorrection(AutoExploreRuntimeState state) {
    return state.isExploring && !state.isPaused && !state.isUserInteracting;
  }
}
