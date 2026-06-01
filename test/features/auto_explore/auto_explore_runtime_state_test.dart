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
