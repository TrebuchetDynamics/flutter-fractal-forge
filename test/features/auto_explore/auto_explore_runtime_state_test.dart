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
      ]) {
        expect(state.canScheduleZoomLeg, isFalse);
        expect(state.shouldInterruptAnimation, isTrue);
      }
    });

    test('characterizes user-correction pause as active interaction only', () {
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
          isExploring: true,
          isPaused: false,
          isUserInteracting: false,
          pausedByUserCorrection: true,
        ),
        throwsAssertionError,
      );
    });
  });
}
