import 'package:flutter_fractals/features/renderer/widgets/renderer/input/gesture_tap_classification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RendererTwoFingerTapDecision', () {
    test('accepts quick two-finger pointer-up and exposes midpoint', () {
      final decision = RendererTwoFingerTapDecision.evaluate(
        isPointerUp: true,
        candidate: true,
        activePointerCount: 2,
        elapsed: const Duration(milliseconds: 120),
        activePositions: const [Offset(10, 20), Offset(30, 60)],
      );

      expect(decision.shouldTrigger, isTrue);
      expect(decision.midpoint, const Offset(20, 40));
    });

    test(
        'rejects pointer cancel even while the tap candidate is otherwise valid',
        () {
      final decision = RendererTwoFingerTapDecision.evaluate(
        isPointerUp: false,
        candidate: true,
        activePointerCount: 2,
        elapsed: const Duration(milliseconds: 120),
        activePositions: const [Offset(10, 20), Offset(30, 60)],
      );

      expect(decision.shouldTrigger, isFalse);
      expect(decision.midpoint, isNull);
    });

    test('rejects stale, incomplete, or inconsistent candidates', () {
      final stale = RendererTwoFingerTapDecision.evaluate(
        isPointerUp: true,
        candidate: true,
        activePointerCount: 2,
        elapsed: const Duration(milliseconds: 221),
        activePositions: const [Offset(10, 20), Offset(30, 60)],
      );
      final missingStart = RendererTwoFingerTapDecision.evaluate(
        isPointerUp: true,
        candidate: true,
        activePointerCount: 2,
        elapsed: null,
        activePositions: const [Offset(10, 20), Offset(30, 60)],
      );
      final inconsistentPositions = RendererTwoFingerTapDecision.evaluate(
        isPointerUp: true,
        candidate: true,
        activePointerCount: 2,
        elapsed: const Duration(milliseconds: 120),
        activePositions: const [Offset(10, 20)],
      );

      expect(stale.shouldTrigger, isFalse);
      expect(missingStart.shouldTrigger, isFalse);
      expect(inconsistentPositions.shouldTrigger, isFalse);
    });
  });
}
