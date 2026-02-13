import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/performance_service.dart';

void main() {
  group('PerformanceMetrics', () {
    test('empty metrics have default values', () {
      const metrics = PerformanceMetrics.empty();
      
      expect(metrics.avgFrameTimeMs, 0);
      expect(metrics.fps, 0);
      expect(metrics.frameCount, 0);
      expect(metrics.droppedFrames, 0);
      expect(metrics.stabilityScore, 100);
      expect(metrics.isJanky, false);
    });

    test('calculates drop percentage correctly', () {
      const metrics = PerformanceMetrics(
        avgFrameTimeMs: 16.67,
        minFrameTimeMs: 15.0,
        maxFrameTimeMs: 20.0,
        p95FrameTimeMs: 18.0,
        p99FrameTimeMs: 19.0,
        frameCount: 100,
        droppedFrames: 10,
        fps: 60,
        shaderCompilations: 0,
        durationSeconds: 1.67,
        stabilityScore: 90,
      );

      expect(metrics.dropPercentage, 10.0);
    });

    test('isGood returns true for excellent performance', () {
      const metrics = PerformanceMetrics(
        avgFrameTimeMs: 16.0,
        minFrameTimeMs: 15.0,
        maxFrameTimeMs: 17.0,
        p95FrameTimeMs: 16.5,
        p99FrameTimeMs: 17.0,
        frameCount: 100,
        droppedFrames: 3,
        fps: 60,
        shaderCompilations: 0,
        durationSeconds: 1.67,
        stabilityScore: 95,
      );

      expect(metrics.isGood, true);
      expect(metrics.isAcceptable, true);
    });

    test('isGood returns false for poor performance', () {
      const metrics = PerformanceMetrics(
        avgFrameTimeMs: 40.0,
        minFrameTimeMs: 30.0,
        maxFrameTimeMs: 80.0,
        p95FrameTimeMs: 60.0,
        p99FrameTimeMs: 75.0,
        frameCount: 100,
        droppedFrames: 50,
        fps: 25,
        shaderCompilations: 2,
        durationSeconds: 4.0,
        stabilityScore: 40,
      );

      expect(metrics.isGood, false);
      expect(metrics.isAcceptable, false);
    });

    test('isAcceptable returns true for moderate performance', () {
      const metrics = PerformanceMetrics(
        avgFrameTimeMs: 25.0,
        minFrameTimeMs: 20.0,
        maxFrameTimeMs: 35.0,
        p95FrameTimeMs: 30.0,
        p99FrameTimeMs: 33.0,
        frameCount: 100,
        droppedFrames: 12,
        fps: 40,
        shaderCompilations: 1,
        durationSeconds: 2.5,
        stabilityScore: 75,
      );

      expect(metrics.isGood, false);
      expect(metrics.isAcceptable, true);
    });
  });

  group('FrameSample', () {
    test('creates sample with correct values', () {
      const sample = FrameSample(
        timestamp: Duration(milliseconds: 1000),
        frameTimeMs: 16.67,
        wasDropped: false,
        hadShaderCompile: false,
      );

      expect(sample.timestamp.inMilliseconds, 1000);
      expect(sample.frameTimeMs, 16.67);
      expect(sample.wasDropped, false);
      expect(sample.hadShaderCompile, false);
    });

    test('identifies dropped frames', () {
      const sample = FrameSample(
        timestamp: Duration(milliseconds: 1000),
        frameTimeMs: 33.34,
        wasDropped: true,
        hadShaderCompile: false,
      );

      expect(sample.wasDropped, true);
    });

    test('identifies shader compilation stalls', () {
      const sample = FrameSample(
        timestamp: Duration(milliseconds: 1000),
        frameTimeMs: 150.0,
        wasDropped: true,
        hadShaderCompile: true,
      );

      expect(sample.hadShaderCompile, true);
    });
  });

  group('PerformanceService', () {
    test('starts in stopped state', () {
      final service = PerformanceService();
      
      expect(service.isRunning, false);
      expect(service.metrics.frameCount, 0);
      expect(service.samples, isEmpty);
    });

    test('reset clears all data', () {
      final service = PerformanceService();
      
      // Add some dummy state (if we could run it)
      service.reset();
      
      expect(service.samples, isEmpty);
      expect(service.metrics.frameCount, 0);
      expect(service.metrics.shaderCompilations, 0);
    });

    test('getSummary returns formatted string', () {
      final service = PerformanceService();
      final summary = service.getSummary();
      
      expect(summary, contains('Performance Summary'));
      expect(summary, contains('FPS:'));
      expect(summary, contains('Frame Time:'));
      expect(summary, contains('Dropped Frames:'));
    });

    test('disposes cleanly', () {
      final service = PerformanceService();
      
      // Should not throw
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('DoubleExtension', () {
    test('sqrt works for positive numbers', () {
      expect(4.0.sqrt(), closeTo(2.0, 0.001));
      expect(9.0.sqrt(), closeTo(3.0, 0.001));
      expect(16.0.sqrt(), closeTo(4.0, 0.001));
    });

    test('sqrt returns 0 for negative numbers', () {
      expect((-4.0).sqrt(), 0);
      expect((-1.0).sqrt(), 0);
    });

    test('sqrt of zero is zero', () {
      expect(0.0.sqrt(), 0);
    });
  });
}
