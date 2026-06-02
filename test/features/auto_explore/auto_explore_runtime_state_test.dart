import 'package:flutter_fractals/features/auto_explore/auto_explore_runtime_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoExploreRuntimeState', () {
    test('allows scheduling only while auto-explore owns motion', () {
      expect(
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ).canScheduleZoomLeg,
        isTrue,
      );

      for (final state in [
        const AutoExploreRuntimeState(
          isExploring: false,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ),
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: true,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ),
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: true,
          pausedByUserCorrection: true,
        ),
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: true,
        ),
      ]) {
        expect(state.canScheduleZoomLeg, isFalse);
        expect(state.shouldInterruptAnimation, isTrue);
      }
    });

    test('keeps user-correction pause as an explicit motion blocker', () {
      final yieldedWithoutInteraction = const AutoExploreRuntimeState(
        isExploring: true,
        isPaused: false,
        isUserInteracting: false,
        pausedByUserCorrection: true,
      );

      expect(yieldedWithoutInteraction.canScheduleZoomLeg, isFalse);
      expect(yieldedWithoutInteraction.shouldInterruptAnimation, isTrue);
    });

    test('adopts continuous interaction end only after a matching start', () {
      const matchingStart = AutoExploreRuntimeState(
        isExploring: true,
        isPaused: false,
        isUserInteracting: true,
        pausedByUserCorrection: true,
      );

      expect(matchingStart.hasContinuousInteractionYield, isTrue);
      expect(matchingStart.canAdoptContinuousInteractionEnd, isTrue);

      for (final state in [
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ),
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: true,
          pausedByUserCorrection: false,
        ),
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: true,
          isUserInteracting: true,
          pausedByUserCorrection: false,
        ),
        const AutoExploreRuntimeState(
          isExploring: false,
          isPaused: false,
          isUserInteracting: true,
          pausedByUserCorrection: false,
        ),
      ]) {
        expect(state.hasContinuousInteractionYield, isFalse);
        expect(state.canAdoptContinuousInteractionEnd, isFalse);
      }
    });

    test('exposes replayable toggle transitions', () {
      expect(
        const AutoExploreRuntimeState(
          isExploring: false,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ).toggleTransition,
        AutoExploreToggleTransition.start,
      );
      expect(
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ).toggleTransition,
        AutoExploreToggleTransition.pause,
      );
      expect(
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: true,
          isUserInteracting: false,
          pausedByUserCorrection: false,
        ).toggleTransition,
        AutoExploreToggleTransition.resume,
      );
      expect(
        const AutoExploreRuntimeState(
          isExploring: true,
          isPaused: false,
          isUserInteracting: true,
          pausedByUserCorrection: true,
        ).toggleTransition,
        AutoExploreToggleTransition.resume,
      );
    });

    test('gates one-shot corrections while continuous gestures own motion', () {
      final idleAutoExplore = const AutoExploreRuntimeState(
        isExploring: true,
        isPaused: false,
        isUserInteracting: false,
        pausedByUserCorrection: false,
      );
      final continuousGesture = const AutoExploreRuntimeState(
        isExploring: true,
        isPaused: false,
        isUserInteracting: true,
        pausedByUserCorrection: true,
      );

      expect(
        AutoExploreUserCorrectionPolicy.shouldAdoptOneShotCorrection(
          idleAutoExplore,
        ),
        isTrue,
      );
      expect(
        AutoExploreUserCorrectionPolicy.shouldAdoptOneShotCorrection(
          continuousGesture,
        ),
        isFalse,
      );
    });

    test('characterizes user-correction pause as armed auto-explore only', () {
      expect(
        () => AutoExploreRuntimeState(
          isExploring: true,
          isPaused: true,
          isUserInteracting: false,
          pausedByUserCorrection: true,
        ),
        throwsAssertionError,
      );
      expect(
        () => AutoExploreRuntimeState(
          isExploring: false,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: true,
        ),
        throwsAssertionError,
      );
    });
  });
}
