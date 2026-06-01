import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/convergence_detector.dart';

void main() {
  group('ConvergenceSamplingPlan', () {
    test('keeps sampling grid dimensions replayable for non-square frames', () {
      final plan = ConvergenceSamplingPlan(width: 130, height: 65, target: 64);

      expect(plan.factor, 3);
      expect(plan.sampledWidth, 44);
      expect(plan.sampledHeight, 22);
    });

    test('rejects invalid downsample target before comparing frames', () {
      expect(
        () => ConvergenceSamplingPlan(width: 64, height: 64, target: 0),
        throwsArgumentError,
      );
    });
  });

  group('ConvergenceDetector', () {
    const detector = ConvergenceDetector();

    test('detects identical frames as converged', () {
      final buffer =
          Uint8List.fromList(List.generate(64 * 64 * 4, (i) => i % 256));

      final result = detector.detect(
        previous: buffer,
        current: buffer,
        width: 64,
        height: 64,
        currentIterations: 100,
      );

      expect(result.converged, isTrue);
      expect(result.changeRatio, closeTo(0.0, 0.001));
    });

    test('detects different frames as not converged', () {
      // Need to change by more than threshold (5) per channel.
      final previous =
          Uint8List.fromList(List.generate(64 * 64 * 4, (i) => i % 256));
      final current =
          Uint8List.fromList(List.generate(64 * 64 * 4, (i) => (i + 10) % 256));

      final result = detector.detect(
        previous: previous,
        current: current,
        width: 64,
        height: 64,
        currentIterations: 100,
      );

      // With 100% pixel change, definitely not converged.
      expect(result.converged, isFalse);
      expect(result.changeRatio, greaterThan(0.5));
    });

    test('suggests increased iterations for significantly changed frames', () {
      // Create 5% pixel change (above 1% threshold).
      final previous = Uint8List(64 * 64 * 4);
      final current = Uint8List.fromList(previous);
      for (int i = 0; i < 64 * 64 * 4; i += 20) {
        current[i] = (current[i] + 10) % 256;
      }

      final result = detector.detect(
        previous: previous,
        current: current,
        width: 64,
        height: 64,
        currentIterations: 100,
      );

      // 5% change > 1% threshold should suggest more iterations.
      expect(result.suggestedIterations, greaterThan(100));
    });

    test('throws domain error for invalid downsample target', () {
      final previous = Uint8List(64 * 64 * 4);
      final current = Uint8List(64 * 64 * 4);
      const invalidDetector = ConvergenceDetector(downsampleTarget: 0);

      expect(
        () => invalidDetector.detect(
          previous: previous,
          current: current,
          width: 64,
          height: 64,
          currentIterations: 100,
        ),
        throwsArgumentError,
      );
    });

    test('throws on buffer size mismatch', () {
      final previous = Uint8List(64 * 64 * 4);
      final current = Uint8List(32 * 32 * 4);

      expect(
        () => detector.detect(
          previous: previous,
          current: current,
          width: 64,
          height: 64,
          currentIterations: 100,
        ),
        throwsArgumentError,
      );
    });

    test('handles small change ratios below convergence threshold', () {
      // The convergence threshold is 0.1% - change fewer than that.
      final previous = Uint8List(64 * 64 * 4);
      final current = Uint8List.fromList(previous);
      // Change only 0.05% of pixels.
      for (int i = 0; i < 64 * 64 * 4; i += 2000) {
        current[i] = (current[i] + 10) % 256;
      }

      final result = detector.detect(
        previous: previous,
        current: current,
        width: 64,
        height: 64,
        currentIterations: 100,
      );

      // Very small changes (0.05%) should be below 0.1% threshold.
      expect(result.changeRatio, lessThan(0.005));
    });
  });
}
