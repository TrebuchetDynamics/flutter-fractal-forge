import 'package:flutter_fractals/features/auto_explore/auto_explore_control_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoExploreControlStatus', () {
    test('does not present user-correction yield as active auto-motion', () {
      const status = AutoExploreControlStatus(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: true,
      );

      expect(status.isMotionActive, isFalse);
      expect(status.isTemporarilyYielded, isTrue);
      expect(
        status.tooltip(
          startLabel: 'Start auto-explore',
          pauseLabel: 'Pause auto-explore',
          yieldedLabel: 'Auto-pilot paused',
        ),
        'Auto-pilot paused',
      );
    });

    test('presents only non-yielding running state as active motion', () {
      const running = AutoExploreControlStatus(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: false,
      );
      const yielded = AutoExploreControlStatus(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: true,
      );
      const paused = AutoExploreControlStatus(
        isExploring: true,
        isPaused: true,
        pausedByUserCorrection: false,
      );
      const stopped = AutoExploreControlStatus(
        isExploring: false,
        isPaused: false,
        pausedByUserCorrection: false,
      );

      expect(running.isMotionActive, isTrue);
      expect(yielded.isMotionActive, isFalse);
      expect(paused.isMotionActive, isFalse);
      expect(stopped.isMotionActive, isFalse);
      expect(
        running.tooltip(
          startLabel: 'Start auto-explore',
          pauseLabel: 'Pause auto-explore',
          yieldedLabel: 'Auto-pilot paused',
        ),
        'Pause auto-explore',
      );
      expect(
        paused.tooltip(
          startLabel: 'Start auto-explore',
          pauseLabel: 'Pause auto-explore',
          yieldedLabel: 'Auto-pilot paused',
        ),
        'Start auto-explore',
      );
    });

    test('uses active motion, not armed state, for the primary action', () {
      const running = AutoExploreControlStatus(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: false,
      );
      const yielded = AutoExploreControlStatus(
        isExploring: true,
        isPaused: false,
        pausedByUserCorrection: true,
      );

      expect(running.showsPauseAction, isTrue);
      expect(yielded.showsPauseAction, isFalse);
    });
  });
}
