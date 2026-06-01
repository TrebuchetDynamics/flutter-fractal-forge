/// Replayable presentation state for auto-explore controls.
///
/// The service can be exploring while user interaction temporarily owns motion.
/// Controls should not present that state as active auto-motion; otherwise the
/// pause icon/tooltip contradict the user-correction pause badge.
class AutoExploreControlStatus {
  final bool isExploring;
  final bool isPaused;
  final bool pausedByUserCorrection;

  const AutoExploreControlStatus({
    required this.isExploring,
    required this.isPaused,
    required this.pausedByUserCorrection,
  });

  /// True only while auto-explore is actively driving motion.
  bool get isMotionActive =>
      isExploring && !isPaused && !pausedByUserCorrection;

  /// True while auto-explore is armed but temporarily yielded to the user.
  bool get isTemporarilyYielded =>
      isExploring && !isPaused && pausedByUserCorrection;

  String tooltip({
    required String startLabel,
    required String pauseLabel,
    required String yieldedLabel,
  }) {
    if (isMotionActive) return pauseLabel;
    if (isTemporarilyYielded) return yieldedLabel;
    return startLabel;
  }
}
