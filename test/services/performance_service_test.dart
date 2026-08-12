import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/diagnostics/performance_service.dart';

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

  group('PerformanceMetricsCalculator', () {
    test('uses nearest-rank percentile indices without one-based drift', () {
      final samples = [
        for (var i = 1; i <= 100; i++)
          FrameSample(
            timestamp: Duration(milliseconds: i),
            frameTimeMs: i.toDouble(),
            wasDropped: false,
          ),
      ];

      final metrics = PerformanceMetricsCalculator.fromSamples(
        samples: samples,
        shaderCompilations: 0,
        durationSeconds: 1.0,
      );

      expect(metrics.p95FrameTimeMs, 95.0);
      expect(metrics.p99FrameTimeMs, 99.0);
    });

    test('ignores malformed frame timings before computing metrics', () {
      const samples = [
        FrameSample(
          timestamp: Duration(milliseconds: 1),
          frameTimeMs: double.nan,
          wasDropped: true,
        ),
        FrameSample(
          timestamp: Duration(milliseconds: 2),
          frameTimeMs: double.infinity,
          wasDropped: true,
        ),
        FrameSample(
          timestamp: Duration(milliseconds: 3),
          frameTimeMs: -5,
          wasDropped: true,
        ),
        FrameSample(
          timestamp: Duration(milliseconds: 4),
          frameTimeMs: 16,
          wasDropped: false,
        ),
        FrameSample(
          timestamp: Duration(milliseconds: 5),
          frameTimeMs: 33,
          wasDropped: true,
        ),
      ];

      final sampleWindow = PerformanceFrameSampleWindow.fromSamples(samples);
      final metrics = PerformanceMetricsCalculator.fromSamples(
        samples: samples,
        shaderCompilations: 0,
        durationSeconds: 1.0,
      );

      expect(sampleWindow.rejectedSampleCount, 3);
      expect(sampleWindow.acceptedSamples.map((sample) => sample.frameTimeMs), [
        16,
        33,
      ]);
      expect(metrics.frameCount, 2);
      expect(metrics.droppedFrames, 1);
      expect(metrics.avgFrameTimeMs, 24.5);
      expect(metrics.minFrameTimeMs, 16);
      expect(metrics.maxFrameTimeMs, 33);
      expect(metrics.p95FrameTimeMs, 33);
      expect(metrics.p99FrameTimeMs, 33);
      expect(metrics.fps, predicate<double>((value) => value.isFinite));
    });
  });

  group('PerformanceSampleCadence', () {
    test('keeps update cadence tied to total frames after sample window caps',
        () {
      expect(
        const PerformanceSampleCadence(
          retainedSampleCount: 300,
          totalSamplesRecorded: 300,
        ).shouldUpdateMetrics,
        isTrue,
      );
      expect(
        const PerformanceSampleCadence(
          retainedSampleCount: 300,
          totalSamplesRecorded: 301,
        ).shouldUpdateMetrics,
        isFalse,
      );
      expect(
        const PerformanceSampleCadence(
          retainedSampleCount: 300,
          totalSamplesRecorded: 330,
        ).shouldUpdateMetrics,
        isTrue,
      );
      expect(
        const PerformanceSampleCadence(
          retainedSampleCount: 300,
          totalSamplesRecorded: 301,
        ).shouldLogSnapshot,
        isFalse,
      );
      expect(
        const PerformanceSampleCadence(
          retainedSampleCount: 300,
          totalSamplesRecorded: 360,
        ).shouldLogSnapshot,
        isTrue,
      );
    });
  });

  group('PerformanceService', () {
    test(
        'retains every frame but samples memory metrics and listeners at cadence',
        () {
      final timingSource = _FakeFrameTimingSource();
      var memoryReads = 0;
      final service = PerformanceService(
        frameTimingSource: timingSource,
        memoryReader: () {
          memoryReads++;
          return 64 * 1024 * 1024;
        },
      );
      var notifications = 0;
      service.addListener(() => notifications++);

      service.start();
      timingSource.emit([
        for (var index = 0; index < 29; index++)
          _timing(
            vsyncStartUs: index * 20000,
            buildUs: 1000,
            rasterUs: 2000,
            totalUs: 5000,
          ),
      ]);

      expect(service.samples, hasLength(29));
      expect(service.metrics.frameCount, 0);
      expect(memoryReads, 0);
      expect(notifications, 1, reason: 'start notification only');

      timingSource.emit([
        _timing(
          vsyncStartUs: 29 * 20000,
          buildUs: 1000,
          rasterUs: 2000,
          totalUs: 5000,
        ),
      ]);

      expect(service.samples, hasLength(30));
      expect(service.metrics.frameCount, 30);
      expect(service.metrics.memoryUsageMb, 64);
      expect(memoryReads, 1);
      expect(notifications, 2);
    });

    test('pause excludes background time and resume starts a new FPS interval',
        () {
      final timingSource = _FakeFrameTimingSource();
      var now = DateTime(2026);
      final service = PerformanceService(
        frameTimingSource: timingSource,
        memoryReader: () => null,
        now: () => now,
      );

      service.start();
      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(
            vsyncStartUs: index * 20000,
            buildUs: 1000,
            rasterUs: 2000,
            totalUs: 5000,
          ),
      ]);
      now = now.add(const Duration(seconds: 2));
      service.pause();

      now = now.add(const Duration(hours: 1));
      service.resume();
      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(
            vsyncStartUs: 3600000000 + index * 20000,
            buildUs: 1000,
            rasterUs: 2000,
            totalUs: 5000,
          ),
      ]);
      now = now.add(const Duration(seconds: 3));
      service.pause();

      expect(service.metrics.fps, closeTo(50, 0.001));
      expect(service.metrics.durationSeconds, 5);
      expect(timingSource.callbackCount, 0);
      expect(service.isRunning, isFalse);
    });

    test('aggregates engine build raster and total frame timings', () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(frameTimingSource: timingSource);

      service.start();
      timingSource.emit([
        for (var index = 0; index < 15; index++) ...[
          _timing(buildUs: 4000, rasterUs: 6000, totalUs: 12000),
          _timing(buildUs: 18000, rasterUs: 8000, totalUs: 30000),
        ],
      ]);

      expect(service.metrics.frameCount, 30);
      expect(service.metrics.avgBuildTimeMs, 11);
      expect(service.metrics.avgRasterTimeMs, 7);
      expect(service.metrics.avgFrameTimeMs, 21);
      expect(service.metrics.longFrames, 15);
      expect(service.metrics.slowBuildFrames, 15);
      expect(service.metrics.slowRasterFrames, 0);
      expect(service.samples.first.buildTimeMs, 4);
      expect(service.samples.first.rasterTimeMs, 6);
      expect(service.samples.first.frameTimeMs, 12);
    });

    test('derives FPS from engine vsync cadence instead of workload duration',
        () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(frameTimingSource: timingSource);

      service.start();
      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(
            vsyncStartUs: 100000 + index * 20000,
            buildUs: 1000,
            rasterUs: 2000,
            totalUs: 5000,
          ),
      ]);

      expect(service.metrics.fps, 50);
    });

    test('owns exactly one scheduler callback across start stop and dispose',
        () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(frameTimingSource: timingSource);

      service.start();
      service.start();
      expect(timingSource.addedCallbacks, 1);
      expect(timingSource.callbackCount, 1);

      service.stop();
      service.stop();
      expect(timingSource.removedCallbacks, 1);
      expect(timingSource.callbackCount, 0);

      service.start();
      service.dispose();
      expect(timingSource.addedCallbacks, 2);
      expect(timingSource.removedCallbacks, 2);
      expect(timingSource.callbackCount, 0);
    });

    test('retains only the configured number of real frame samples', () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(
        frameTimingSource: timingSource,
        maxSamples: 2,
      );

      service.start();
      timingSource.emit([
        for (var index = 0; index < 28; index++)
          _timing(buildUs: 1000, rasterUs: 2000, totalUs: 5000),
        _timing(buildUs: 2000, rasterUs: 3000, totalUs: 7000),
        _timing(buildUs: 3000, rasterUs: 4000, totalUs: 9000),
      ]);

      expect(service.samples.map((sample) => sample.frameTimeMs), [7, 9]);
      expect(service.metrics.frameCount, 2);
    });

    test('reports injected process memory and tracks its observed peak', () {
      final timingSource = _FakeFrameTimingSource();
      final readings = <int?>[100 * 1024 * 1024, 120 * 1024 * 1024];
      final service = PerformanceService(
        frameTimingSource: timingSource,
        memoryReader: () => readings.removeAt(0),
      );

      service.start();
      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(buildUs: 1000, rasterUs: 2000, totalUs: 5000),
      ]);
      expect(service.metrics.memoryUsageMb, 100);
      expect(service.metrics.peakMemoryMb, 100);

      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(buildUs: 1000, rasterUs: 2000, totalUs: 5000),
      ]);
      expect(service.metrics.memoryUsageMb, 120);
      expect(service.metrics.peakMemoryMb, 120);
    });

    test('keeps unavailable process memory explicitly null', () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(
        frameTimingSource: timingSource,
        memoryReader: () => null,
      );

      service.start();
      timingSource.emit([
        _timing(buildUs: 1000, rasterUs: 2000, totalUs: 5000),
      ]);

      expect(service.metrics.memoryUsageMb, isNull);
      expect(service.metrics.peakMemoryMb, isNull);
      expect(service.getSummary(), contains('Memory: Unavailable'));
    });

    test('presents unsupported shader compilation metric as unavailable', () {
      final timingSource = _FakeFrameTimingSource();
      final service = PerformanceService(frameTimingSource: timingSource);

      service.start();
      timingSource.emit([
        for (var index = 0; index < 30; index++)
          _timing(buildUs: 1000, rasterUs: 2000, totalUs: 5000),
      ]);

      expect(
        service.getSummary(),
        contains('Shader Compilations: Unavailable'),
      );
      expect(service.getSummary(), isNot(contains('Shader Compilations: 0')));
    });

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

    test('disposed service ignores stale control calls', () {
      final service = PerformanceService();
      service.dispose();

      expect(() => service.reset(), returnsNormally);
      expect(() => service.stop(), returnsNormally);
      expect(() => service.start(TestVSync()), returnsNormally);
      expect(service.isRunning, isFalse);
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

FrameTiming _timing({
  int vsyncStartUs = 0,
  required int buildUs,
  required int rasterUs,
  required int totalUs,
}) {
  return FrameTiming(
    vsyncStart: vsyncStartUs,
    buildStart: vsyncStartUs + 1000,
    buildFinish: vsyncStartUs + 1000 + buildUs,
    rasterStart: vsyncStartUs + totalUs - rasterUs,
    rasterFinish: vsyncStartUs + totalUs,
    rasterFinishWallTime: vsyncStartUs + totalUs,
  );
}

class _FakeFrameTimingSource implements FrameTimingSource {
  final List<TimingsCallback> _callbacks = [];
  int addedCallbacks = 0;
  int removedCallbacks = 0;

  int get callbackCount => _callbacks.length;

  @override
  void addTimingsCallback(TimingsCallback callback) {
    addedCallbacks++;
    _callbacks.add(callback);
  }

  @override
  void removeTimingsCallback(TimingsCallback callback) {
    removedCallbacks++;
    _callbacks.remove(callback);
  }

  void emit(List<FrameTiming> timings) {
    for (final callback in List<TimingsCallback>.of(_callbacks)) {
      callback(timings);
    }
  }
}
