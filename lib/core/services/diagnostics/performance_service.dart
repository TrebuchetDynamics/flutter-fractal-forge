import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/diagnostics/process_memory_reader.dart';

typedef ProcessMemoryReader = int? Function();
typedef PerformanceClock = DateTime Function();

/// Performance metrics aggregated from Flutter engine [FrameTiming] records.
@immutable
class PerformanceMetrics {
  final double avgFrameTimeMs;
  final double minFrameTimeMs;
  final double maxFrameTimeMs;
  final double p95FrameTimeMs;
  final double p99FrameTimeMs;
  final int frameCount;
  final int droppedFrames;
  final double fps;
  final int shaderCompilations;
  final double? memoryUsageMb;
  final double? peakMemoryMb;
  final bool isJanky;
  final double durationSeconds;
  final double stabilityScore;
  final double avgBuildTimeMs;
  final double avgRasterTimeMs;
  final int longFrames;
  final int slowBuildFrames;
  final int slowRasterFrames;

  const PerformanceMetrics({
    required this.avgFrameTimeMs,
    required this.minFrameTimeMs,
    required this.maxFrameTimeMs,
    required this.p95FrameTimeMs,
    required this.p99FrameTimeMs,
    required this.frameCount,
    required this.droppedFrames,
    required this.fps,
    required this.shaderCompilations,
    this.memoryUsageMb,
    this.peakMemoryMb,
    this.isJanky = false,
    required this.durationSeconds,
    required this.stabilityScore,
    this.avgBuildTimeMs = 0,
    this.avgRasterTimeMs = 0,
    this.longFrames = 0,
    this.slowBuildFrames = 0,
    this.slowRasterFrames = 0,
  });

  const PerformanceMetrics.empty()
      : avgFrameTimeMs = 0,
        minFrameTimeMs = 0,
        maxFrameTimeMs = 0,
        p95FrameTimeMs = 0,
        p99FrameTimeMs = 0,
        frameCount = 0,
        droppedFrames = 0,
        fps = 0,
        shaderCompilations = 0,
        memoryUsageMb = null,
        peakMemoryMb = null,
        isJanky = false,
        durationSeconds = 0,
        stabilityScore = 100,
        avgBuildTimeMs = 0,
        avgRasterTimeMs = 0,
        longFrames = 0,
        slowBuildFrames = 0,
        slowRasterFrames = 0;

  double get dropPercentage =>
      frameCount > 0 ? (droppedFrames / frameCount) * 100 : 0;

  bool get isGood => fps >= 55 && dropPercentage < 5;
  bool get isAcceptable => fps >= 30 && dropPercentage < 15;

  @override
  String toString() => 'PerformanceMetrics(fps: ${fps.toStringAsFixed(1)}, '
      'avg: ${avgFrameTimeMs.toStringAsFixed(2)}ms, '
      'long: $longFrames/$frameCount)';
}

/// One bounded, graphable engine frame sample.
@immutable
class FrameSample {
  final Duration timestamp;
  final double frameTimeMs;
  final double buildTimeMs;
  final double rasterTimeMs;
  final bool wasDropped;
  final bool hadShaderCompile;
  final bool startsNewCadence;

  const FrameSample({
    required this.timestamp,
    required this.frameTimeMs,
    this.buildTimeMs = 0,
    this.rasterTimeMs = 0,
    required this.wasDropped,
    this.hadShaderCompile = false,
    this.startsNewCadence = false,
  });
}

@visibleForTesting
class PerformanceFrameSampleWindow {
  final List<FrameSample> acceptedSamples;
  final int rejectedSampleCount;

  const PerformanceFrameSampleWindow._({
    required this.acceptedSamples,
    required this.rejectedSampleCount,
  });

  factory PerformanceFrameSampleWindow.fromSamples(
    Iterable<FrameSample> samples,
  ) {
    final accepted = <FrameSample>[];
    var rejected = 0;
    for (final sample in samples) {
      if (sample.frameTimeMs.isFinite && sample.frameTimeMs > 0) {
        accepted.add(sample);
      } else {
        rejected++;
      }
    }
    return PerformanceFrameSampleWindow._(
      acceptedSamples: List.unmodifiable(accepted),
      rejectedSampleCount: rejected,
    );
  }

  bool get isEmpty => acceptedSamples.isEmpty;

  List<double> sortedFrameTimes() => acceptedSamples
      .map((sample) => sample.frameTimeMs)
      .toList(growable: false)
    ..sort();

  Iterable<FrameSample> recentSamples({int limit = 10}) =>
      acceptedSamples.reversed.take(limit);
}

@visibleForTesting
class PerformanceMetricsCalculator {
  const PerformanceMetricsCalculator._();

  static PerformanceMetrics fromSamples({
    required Iterable<FrameSample> samples,
    required int shaderCompilations,
    required double durationSeconds,
    double? memoryUsageMb,
    double? peakMemoryMb,
    double targetFrameTimeMs = PerformanceService.targetFrameTimeMs,
  }) {
    final window = PerformanceFrameSampleWindow.fromSamples(samples);
    if (window.isEmpty) {
      return PerformanceMetrics(
        avgFrameTimeMs: 0,
        minFrameTimeMs: 0,
        maxFrameTimeMs: 0,
        p95FrameTimeMs: 0,
        p99FrameTimeMs: 0,
        frameCount: 0,
        droppedFrames: 0,
        fps: 0,
        shaderCompilations: shaderCompilations,
        memoryUsageMb: memoryUsageMb,
        peakMemoryMb: peakMemoryMb,
        durationSeconds: durationSeconds,
        stabilityScore: 100,
      );
    }

    final sampleList = window.acceptedSamples;
    final frameTimes = window.sortedFrameTimes();
    final avg = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
    final buildTimes = sampleList.map((sample) => sample.buildTimeMs);
    final rasterTimes = sampleList.map((sample) => sample.rasterTimeMs);
    final p95 = frameTimes[nearestRankPercentileIndex(
      sampleCount: frameTimes.length,
      percentile: 0.95,
    )];
    final p99 = frameTimes[nearestRankPercentileIndex(
      sampleCount: frameTimes.length,
      percentile: 0.99,
    )];
    final variance = frameTimes
            .map((time) => math.pow(time - avg, 2).toDouble())
            .reduce((a, b) => a + b) /
        frameTimes.length;
    final stability =
        (100 - (math.sqrt(variance) / targetFrameTimeMs * 100)).clamp(0, 100);
    final longFrames = sampleList
        .where((sample) => sample.frameTimeMs > targetFrameTimeMs)
        .length;
    final frameIntervalsMs = <double>[];
    for (var index = 1; index < sampleList.length; index++) {
      if (sampleList[index].startsNewCadence) continue;
      final intervalUs =
          (sampleList[index].timestamp - sampleList[index - 1].timestamp)
              .inMicroseconds;
      if (intervalUs > 0) frameIntervalsMs.add(intervalUs / 1000);
    }
    final fps = frameIntervalsMs.isEmpty
        ? 0.0
        : 1000 /
            (frameIntervalsMs.reduce((a, b) => a + b) /
                frameIntervalsMs.length);
    final recentLongFrames = window
        .recentSamples()
        .where((sample) => sample.frameTimeMs > targetFrameTimeMs)
        .length;

    return PerformanceMetrics(
      avgFrameTimeMs: avg,
      minFrameTimeMs: frameTimes.first,
      maxFrameTimeMs: frameTimes.last,
      p95FrameTimeMs: p95,
      p99FrameTimeMs: p99,
      frameCount: sampleList.length,
      droppedFrames: longFrames,
      fps: fps,
      shaderCompilations: shaderCompilations,
      memoryUsageMb: memoryUsageMb,
      peakMemoryMb: peakMemoryMb,
      isJanky: recentLongFrames > 3,
      durationSeconds: durationSeconds,
      stabilityScore: stability.toDouble(),
      avgBuildTimeMs: buildTimes.reduce((a, b) => a + b) / sampleList.length,
      avgRasterTimeMs: rasterTimes.reduce((a, b) => a + b) / sampleList.length,
      longFrames: longFrames,
      slowBuildFrames: sampleList
          .where((sample) => sample.buildTimeMs > targetFrameTimeMs)
          .length,
      slowRasterFrames: sampleList
          .where((sample) => sample.rasterTimeMs > targetFrameTimeMs)
          .length,
    );
  }

  @visibleForTesting
  static int nearestRankPercentileIndex({
    required int sampleCount,
    required double percentile,
  }) {
    assert(sampleCount > 0, 'sampleCount must be positive');
    assert(percentile > 0 && percentile <= 1,
        'percentile must be in the nearest-rank interval (0, 1]');
    return ((sampleCount * percentile).ceil() - 1)
        .clamp(0, sampleCount - 1)
        .toInt();
  }
}

@visibleForTesting
class PerformanceSampleCadence {
  static const int metricsIntervalSamples = 30;
  static const int snapshotLogIntervalSamples = 60;

  final int retainedSampleCount;
  final int totalSamplesRecorded;

  const PerformanceSampleCadence({
    required this.retainedSampleCount,
    required this.totalSamplesRecorded,
  })  : assert(retainedSampleCount >= 0),
        assert(totalSamplesRecorded >= 0),
        assert(retainedSampleCount <= totalSamplesRecorded);

  bool get retainedWindowIsCapped => totalSamplesRecorded > retainedSampleCount;
  bool get shouldUpdateMemoryUsage => _isIntervalHit(metricsIntervalSamples);
  bool get shouldUpdateMetrics => _isIntervalHit(metricsIntervalSamples);
  bool get shouldLogSnapshot => _isIntervalHit(snapshotLogIntervalSamples);

  bool _isIntervalHit(int interval) =>
      totalSamplesRecorded > 0 && totalSamplesRecorded % interval == 0;
}

/// Injectable owner of Flutter's frame timing callback API.
abstract interface class FrameTimingSource {
  void addTimingsCallback(TimingsCallback callback);
  void removeTimingsCallback(TimingsCallback callback);
}

class SchedulerFrameTimingSource implements FrameTimingSource {
  @override
  void addTimingsCallback(TimingsCallback callback) {
    SchedulerBinding.instance.addTimingsCallback(callback);
  }

  @override
  void removeTimingsCallback(TimingsCallback callback) {
    SchedulerBinding.instance.removeTimingsCallback(callback);
  }
}

/// Collects real engine frame telemetry with bounded ownership and storage.
class PerformanceService extends ChangeNotifier {
  static const int defaultMaxSamples = 300;
  static const double targetFrameTimeMs = 16.67;

  final FrameTimingSource _frameTimingSource;
  final ProcessMemoryReader _memoryReader;
  final PerformanceClock _now;
  final int _maxSamples;
  final Queue<FrameSample> _samples = Queue();
  TimingsCallback? _registeredCallback;
  DateTime? _activeStartedAt;
  Duration _activeDuration = Duration.zero;
  bool _isRunning = false;
  bool _disposed = false;
  int _totalSamplesRecorded = 0;
  int _lastMetricsCadence = 0;
  bool _canResume = false;
  bool _firstFrameAfterResume = true;
  double? _memoryUsageMb;
  double? _peakMemoryMb;
  PerformanceMetrics _currentMetrics = const PerformanceMetrics.empty();

  PerformanceService({
    FrameTimingSource? frameTimingSource,
    ProcessMemoryReader? memoryReader,
    PerformanceClock? now,
    int maxSamples = defaultMaxSamples,
  })  : assert(maxSamples > 0),
        _frameTimingSource = frameTimingSource ?? SchedulerFrameTimingSource(),
        _memoryReader = memoryReader ?? readProcessRssBytes,
        _now = now ?? DateTime.now,
        _maxSamples = maxSamples;

  bool get isRunning => _isRunning;
  PerformanceMetrics get metrics => _currentMetrics;
  List<FrameSample> get samples => List.unmodifiable(_samples);

  /// Starts collecting. The optional argument preserves the former ticker API.
  void start([TickerProvider? unusedVsync]) {
    if (_disposed || _isRunning) return;
    _samples.clear();
    _totalSamplesRecorded = 0;
    _lastMetricsCadence = 0;
    _memoryUsageMb = null;
    _peakMemoryMb = null;
    _currentMetrics = const PerformanceMetrics.empty();
    _activeDuration = Duration.zero;
    _activeStartedAt = _now();
    _canResume = true;
    _firstFrameAfterResume = true;
    final callback = _onTimings;
    _registeredCallback = callback;
    _frameTimingSource.addTimingsCallback(callback);
    _isRunning = true;
    _notifyIfAlive();
  }

  void stop() {
    if (_disposed || !_isRunning) return;
    _suspend(canResume: false);
  }

  void pause() {
    if (_disposed || !_isRunning) return;
    _suspend(canResume: true);
  }

  void resume() {
    if (_disposed || _isRunning || !_canResume) return;
    _activeStartedAt = _now();
    _firstFrameAfterResume = true;
    final callback = _onTimings;
    _registeredCallback = callback;
    _frameTimingSource.addTimingsCallback(callback);
    _isRunning = true;
    _notifyIfAlive();
  }

  void reset() {
    if (_disposed) return;
    _samples.clear();
    _totalSamplesRecorded = 0;
    _lastMetricsCadence = 0;
    _memoryUsageMb = null;
    _peakMemoryMb = null;
    _currentMetrics = const PerformanceMetrics.empty();
    _activeDuration = Duration.zero;
    _activeStartedAt = _isRunning ? _now() : null;
    _firstFrameAfterResume = true;
    _notifyIfAlive();
  }

  void _onTimings(List<FrameTiming> timings) {
    if (_disposed || !_isRunning) return;
    for (final timing in timings) {
      final totalMs = timing.totalSpan.inMicroseconds / 1000;
      final buildMs = timing.buildDuration.inMicroseconds / 1000;
      final rasterMs = timing.rasterDuration.inMicroseconds / 1000;
      if (!totalMs.isFinite || totalMs <= 0 || buildMs < 0 || rasterMs < 0) {
        continue;
      }
      _samples.addLast(FrameSample(
        timestamp: Duration(
          microseconds: timing.timestampInMicroseconds(FramePhase.vsyncStart),
        ),
        frameTimeMs: totalMs,
        buildTimeMs: buildMs,
        rasterTimeMs: rasterMs,
        wasDropped: totalMs > targetFrameTimeMs,
        startsNewCadence: _firstFrameAfterResume,
      ));
      _firstFrameAfterResume = false;
      _totalSamplesRecorded++;
      if (_samples.length > _maxSamples) _samples.removeFirst();
    }
    final cadence = PerformanceSampleCadence(
      retainedSampleCount: _samples.length,
      totalSamplesRecorded: _totalSamplesRecorded,
    );
    final metricsCadence = _totalSamplesRecorded ~/
        PerformanceSampleCadence.metricsIntervalSamples;
    if (metricsCadence > _lastMetricsCadence) {
      _lastMetricsCadence = metricsCadence;
      _readMemory();
      _updateMetrics();
      _notifyIfAlive();
    }
    if (cadence.shouldLogSnapshot) {
      _logPerformanceSnapshot();
    }
  }

  void _updateMetrics() {
    _currentMetrics = PerformanceMetricsCalculator.fromSamples(
      samples: _samples,
      shaderCompilations: 0,
      durationSeconds: _profilingDuration.inMicroseconds / 1000000,
      memoryUsageMb: _memoryUsageMb,
      peakMemoryMb: _peakMemoryMb,
    );
  }

  void _readMemory() {
    int? bytes;
    try {
      bytes = _memoryReader();
    } on Object {
      bytes = null;
    }
    if (bytes == null || bytes <= 0) {
      _memoryUsageMb = null;
      return;
    }
    final megabytes = bytes / (1024 * 1024);
    _memoryUsageMb = megabytes;
    final peak = _peakMemoryMb;
    if (peak == null || megabytes > peak) _peakMemoryMb = megabytes;
  }

  void _logPerformanceSnapshot() {
    final current = _currentMetrics;
    AppLogger.instance.debug('perf', 'fps_snapshot', data: {
      'fps': current.fps.toStringAsFixed(1),
      'build_ms': current.avgBuildTimeMs.toStringAsFixed(2),
      'raster_ms': current.avgRasterTimeMs.toStringAsFixed(2),
      'total_ms': current.avgFrameTimeMs.toStringAsFixed(2),
      'p95_ms': current.p95FrameTimeMs.toStringAsFixed(2),
      'long_frames': current.longFrames,
      'frames': current.frameCount,
    });
  }

  String getSummary() {
    final current = _currentMetrics;
    final memory = current.memoryUsageMb == null
        ? 'Unavailable'
        : '${current.memoryUsageMb!.toStringAsFixed(1)} MB';
    return '''=== Performance Summary ===
Duration: ${current.durationSeconds.toStringAsFixed(1)}s
FPS: ${current.fps.toStringAsFixed(1)} (${_getFpsRating(current.fps)})
Frame Time: ${current.avgFrameTimeMs.toStringAsFixed(2)}ms avg
  Build: ${current.avgBuildTimeMs.toStringAsFixed(2)}ms
  Raster: ${current.avgRasterTimeMs.toStringAsFixed(2)}ms
  Min: ${current.minFrameTimeMs.toStringAsFixed(2)}ms
  Max: ${current.maxFrameTimeMs.toStringAsFixed(2)}ms
  P95: ${current.p95FrameTimeMs.toStringAsFixed(2)}ms
  P99: ${current.p99FrameTimeMs.toStringAsFixed(2)}ms
Dropped Frames: ${current.droppedFrames}/${current.frameCount} (${current.dropPercentage.toStringAsFixed(1)}%)
Shader Compilations: Unavailable
Memory: $memory
Stability Score: ${current.stabilityScore.toStringAsFixed(0)}/100
''';
  }

  String _getFpsRating(double fps) {
    if (fps >= 58) return 'Excellent';
    if (fps >= 50) return 'Good';
    if (fps >= 30) return 'Acceptable';
    return 'Poor';
  }

  void _detachCallback() {
    final callback = _registeredCallback;
    if (callback != null) {
      _frameTimingSource.removeTimingsCallback(callback);
      _registeredCallback = null;
    }
  }

  Duration get _profilingDuration {
    final activeStartedAt = _activeStartedAt;
    if (!_isRunning || activeStartedAt == null) return _activeDuration;
    return _activeDuration + _now().difference(activeStartedAt);
  }

  void _suspend({required bool canResume}) {
    final activeStartedAt = _activeStartedAt;
    if (activeStartedAt != null) {
      _activeDuration += _now().difference(activeStartedAt);
    }
    _activeStartedAt = null;
    _detachCallback();
    _isRunning = false;
    _canResume = canResume;
    _updateMetrics();
    _notifyIfAlive();
  }

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _detachCallback();
    final activeStartedAt = _activeStartedAt;
    if (_isRunning && activeStartedAt != null) {
      _activeDuration += _now().difference(activeStartedAt);
    }
    _activeStartedAt = null;
    _isRunning = false;
    _canResume = false;
    _disposed = true;
    super.dispose();
  }
}

extension DoubleExtension on double {
  double sqrt() => this >= 0 ? math.sqrt(this) : 0;
}
