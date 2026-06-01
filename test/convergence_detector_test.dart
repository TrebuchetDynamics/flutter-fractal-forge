import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/convergence_detector.dart';

void main() {
  group('ConvergenceResult', () {
    test('hashCode is compatible with approximate changeRatio equality', () {
      const base = ConvergenceResult(
        converged: true,
        changeRatio: 0.123456789,
        suggestedIterations: 100,
      );
      const approximatelyEqual = ConvergenceResult(
        converged: true,
        changeRatio: 0.1234567895,
        suggestedIterations: 100,
      );

      expect(base, approximatelyEqual);
      expect(base.hashCode, approximatelyEqual.hashCode);
      expect({base}, contains(approximatelyEqual));
    });
  });

  group('ConvergenceComparisonStats', () {
    test('exposes replayable change ratio from sampled counts', () {
      const stats = ConvergenceComparisonStats(
        changedPixels: 2,
        totalPixels: 8,
      );

      expect(stats.changeRatio, 0.25);
    });
  });

  group('ConvergenceIterationRecommendation', () {
    test('keeps iterations for minor changes and rejects invalid counts', () {
      expect(
        ConvergenceIterationRecommendation.forChangeRatio(
          changeRatio: ConvergenceDetector.changeThreshold,
          currentIterations: 100,
        ),
        100,
      );
      expect(
        () => ConvergenceIterationRecommendation.forChangeRatio(
          changeRatio: 0.0,
          currentIterations: 0,
        ),
        throwsArgumentError,
      );
    });

    test('increases iterations above the significant-change threshold', () {
      expect(
        ConvergenceIterationRecommendation.forChangeRatio(
          changeRatio: ConvergenceDetector.changeThreshold + 0.001,
          currentIterations: 100,
        ),
        150,
      );
    });
  });

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

    test('compareFrames exposes sampled counts before convergence policy', () {
      final previous = Uint8List(4 * 4 * 4);
      final current = Uint8List.fromList(previous);
      current[0] = 10;
      current[(3 * 4 + 3) * 4] = 10;

      final stats = detector.compareFrames(
        previous: previous,
        current: current,
        width: 4,
        height: 4,
      );

      expect(stats.changedPixels, 2);
      expect(stats.totalPixels, 16);
      expect(stats.changeRatio, 0.125);
    });

    test('compareFrames ignores alpha-only changes', () {
      final previous = Uint8List(4 * 4 * 4);
      final current = Uint8List.fromList(previous);
      current[3] = 255;

      final stats = detector.compareFrames(
        previous: previous,
        current: current,
        width: 4,
        height: 4,
      );

      expect(stats.changedPixels, 0);
      expect(stats.changeRatio, 0.0);
    });

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

    test('throws domain error for negative pixel difference threshold', () {
      final previous = Uint8List(64 * 64 * 4);
      final current = Uint8List(64 * 64 * 4);
      const invalidDetector = ConvergenceDetector(pixelDifferenceThreshold: -1);

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
