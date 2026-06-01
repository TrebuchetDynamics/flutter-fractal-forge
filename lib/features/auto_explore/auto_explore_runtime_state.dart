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
          !pausedByUserCorrection ||
              (isExploring && !isPaused && isUserInteracting),
          'pausedByUserCorrection is only valid during an active user interaction',
        );

  /// A new auto-zoom leg can start only when auto-explore owns motion.
  bool get canScheduleZoomLeg => isExploring && !isPaused && !isUserInteracting;

  /// An in-flight animation must stop as soon as auto-explore loses motion.
  bool get shouldInterruptAnimation => !canScheduleZoomLeg;
}
