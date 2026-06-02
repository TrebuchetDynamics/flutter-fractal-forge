import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';

/// Performance metrics collected during rendering.
///
/// Contains frame timing, shader compilation, and memory usage data.
@immutable
class PerformanceMetrics {
  /// Average frame time in milliseconds.
  final double avgFrameTimeMs;

  /// Minimum frame time in milliseconds.
  final double minFrameTimeMs;

  /// Maximum frame time in milliseconds.
  final double maxFrameTimeMs;

  /// 95th percentile frame time in milliseconds.
  final double p95FrameTimeMs;

  /// 99th percentile frame time in milliseconds.
  final double p99FrameTimeMs;

  /// Number of frames rendered.
  final int frameCount;

  /// Number of dropped frames (> 16.67ms).
  final int droppedFrames;

  /// Current frames per second.
  final double fps;

  /// Number of shader compilations detected.
  final int shaderCompilations;

  /// Memory usage in megabytes (if available).
  final double? memoryUsageMb;

  /// Peak memory usage in megabytes.
  final double? peakMemoryMb;

  /// Whether the app is currently experiencing jank.
  final bool isJanky;

  /// Total profiling duration in seconds.
  final double durationSeconds;

  /// Frame time stability score (0-100, 100 = perfectly stable).
  final double stabilityScore;

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
  });

  /// Creates empty metrics.
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
        stabilityScore = 100;

  /// Frame drop percentage (0-100).
  double get dropPercentage =>
      frameCount > 0 ? (droppedFrames / frameCount) * 100 : 0;

  /// Whether performance is considered good (> 55 FPS, < 5% drops).
  bool get isGood => fps >= 55 && dropPercentage < 5;

  /// Whether performance is acceptable (> 30 FPS, < 15% drops).
  bool get isAcceptable => fps >= 30 && dropPercentage < 15;

  @override
  String toString() => 'PerformanceMetrics(fps: ${fps.toStringAsFixed(1)}, '
      'avg: ${avgFrameTimeMs.toStringAsFixed(2)}ms, '
      'dropped: $droppedFrames/$frameCount)';
}

/// A single frame timing sample.
@immutable
class FrameSample {
  final Duration timestamp;
  final double frameTimeMs;
  final bool wasDropped;
  final bool hadShaderCompile;

  const FrameSample({
    required this.timestamp,
    required this.frameTimeMs,
    required this.wasDropped,
    this.hadShaderCompile = false,
  });
}

/// Pure calculator for replayable frame-time metrics.
///
/// [PerformanceService] collects frame samples from a ticker. Keeping the
/// aggregation rules here makes percentile and jank assumptions testable
/// without a live scheduler.
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
    final sampleList = List<FrameSample>.of(samples);
    if (sampleList.isEmpty) {
      return const PerformanceMetrics.empty();
    }

    final frameTimes = sampleList.map((s) => s.frameTimeMs).toList()..sort();

    final avg = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
    final min = frameTimes.first;
    final max = frameTimes.last;

    final p95Index = nearestRankPercentileIndex(
      sampleCount: frameTimes.length,
      percentile: 0.95,
    );
    final p99Index = nearestRankPercentileIndex(
      sampleCount: frameTimes.length,
      percentile: 0.99,
    );
    final p95 = frameTimes[p95Index];
    final p99 = frameTimes[p99Index];

    final droppedFrames = sampleList.where((s) => s.wasDropped).length;
    final fps = avg > 0 ? 1000.0 / avg : 0.0;

    final variance =
        frameTimes.map((t) => (t - avg) * (t - avg)).reduce((a, b) => a + b) /
            frameTimes.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0;
    final stabilityScore =
        (100 - (stdDev / targetFrameTimeMs * 100)).clamp(0.0, 100.0);

    final recentSamples = sampleList.reversed.take(10);
    final recentDrops = recentSamples.where((s) => s.wasDropped).length;
    final isJanky = recentDrops > 3;

    return PerformanceMetrics(
      avgFrameTimeMs: avg,
      minFrameTimeMs: min,
      maxFrameTimeMs: max,
      p95FrameTimeMs: p95,
      p99FrameTimeMs: p99,
      frameCount: sampleList.length,
      droppedFrames: droppedFrames,
      fps: fps,
      shaderCompilations: shaderCompilations,
      memoryUsageMb: memoryUsageMb,
      peakMemoryMb:
          peakMemoryMb != null && peakMemoryMb > 0 ? peakMemoryMb : null,
      isJanky: isJanky,
      durationSeconds: durationSeconds,
      stabilityScore: stabilityScore,
    );
  }

  @visibleForTesting
  static int nearestRankPercentileIndex({
    required int sampleCount,
    required double percentile,
  }) {
    assert(sampleCount > 0, 'sampleCount must be positive');
    assert(
      percentile > 0.0 && percentile <= 1.0,
      'percentile must be in the nearest-rank interval (0, 1]',
    );

    final rank = (sampleCount * percentile).ceil();
    return (rank - 1).clamp(0, sampleCount - 1).toInt();
  }
}

/// Service for collecting and analyzing rendering performance.
///
/// Tracks frame times, detects shader compilation stalls, and monitors
/// memory usage to provide real-time performance metrics.
class PerformanceService extends ChangeNotifier {
  static const int _maxSamples = 300; // ~5 seconds at 60fps
  static const double _targetFrameTime = 16.67; // 60 FPS
  static const double _shaderStallThreshold =
      100.0; // 100ms suggests compilation

  @visibleForTesting
  static const double targetFrameTimeMs = _targetFrameTime;

  final Queue<FrameSample> _samples = Queue();
  Ticker? _ticker;
  Duration _lastFrameTime = Duration.zero;
  Stopwatch? _sessionStopwatch;

  bool _isRunning = false;
  int _shaderCompilations = 0;
  double _peakMemoryMb = 0;
  PerformanceMetrics _currentMetrics = const PerformanceMetrics.empty();

  /// Whether performance tracking is currently active.
  bool get isRunning => _isRunning;

  /// Current performance metrics.
  PerformanceMetrics get metrics => _currentMetrics;

  /// Most recent frame samples for graphing.
  List<FrameSample> get samples => _samples.toList();

  /// Starts performance tracking.
  ///
  /// Attaches to the scheduler's ticker to measure frame times.
  void start(TickerProvider vsync) {
    if (_isRunning) return;

    _isRunning = true;
    _samples.clear();
    _shaderCompilations = 0;
    _peakMemoryMb = 0;
    _lastFrameTime = Duration.zero;
    _sessionStopwatch = Stopwatch()..start();

    _ticker = vsync.createTicker(_onTick);
    _ticker!.start();

    notifyListeners();
  }

  /// Stops performance tracking.
  void stop() {
    if (!_isRunning) return;

    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _sessionStopwatch?.stop();
    _isRunning = false;

    _updateMetrics();
    notifyListeners();
  }

  /// Resets all collected metrics.
  void reset() {
    _samples.clear();
    _shaderCompilations = 0;
    _peakMemoryMb = 0;
    _currentMetrics = const PerformanceMetrics.empty();
    _sessionStopwatch?.reset();
    if (_isRunning) {
      _sessionStopwatch?.start();
    }
    notifyListeners();
  }

  void _onTick(Duration elapsed) {
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = elapsed;
      return;
    }

    final frameTimeMs = (elapsed - _lastFrameTime).inMicroseconds / 1000.0;
    _lastFrameTime = elapsed;

    // Detect shader compilation stalls
    final hadShaderCompile = frameTimeMs > _shaderStallThreshold;
    if (hadShaderCompile) {
      _shaderCompilations++;
    }

    final sample = FrameSample(
      timestamp: elapsed,
      frameTimeMs: frameTimeMs,
      wasDropped: frameTimeMs > _targetFrameTime,
      hadShaderCompile: hadShaderCompile,
    );

    _samples.addLast(sample);
    if (_samples.length > _maxSamples) {
      _samples.removeFirst();
    }

    // Update memory tracking periodically
    if (_samples.length % 30 == 0) {
      _updateMemoryUsage();
    }

    // Update metrics every ~0.5 seconds (30 frames)
    if (_samples.length % 30 == 0) {
      _updateMetrics();
      notifyListeners();
    }

    // Log performance snapshot every ~1 second (60 frames) — sampled to avoid noise
    if (_samples.length % 60 == 0) {
      _logPerformanceSnapshot();
    }
  }

  /// Logs a concise FPS/frame-time snapshot via [AppLogger].
  void _logPerformanceSnapshot() {
    final m = _currentMetrics;
    if (m.frameCount == 0) return;
    AppLogger.instance.debug('perf', 'fps_snapshot', data: {
      'fps': m.fps.toStringAsFixed(1),
      'avg_ms': m.avgFrameTimeMs.toStringAsFixed(2),
      'p95_ms': m.p95FrameTimeMs.toStringAsFixed(2),
      'dropped': m.droppedFrames,
      'frames': m.frameCount,
    });
  }

  void _updateMemoryUsage() {
    // Note: In Flutter, getting exact memory usage requires platform channels
    // or debug mode APIs. This is a simplified approach using heuristics.
    // For accurate memory profiling, use DevTools or platform-specific APIs.

    // Placeholder: In real app, use PlatformDispatcher.instance.onReportTimings
    // or implement platform channels for memory stats
  }

  void _updateMetrics() {
    _currentMetrics = PerformanceMetricsCalculator.fromSamples(
      samples: _samples,
      shaderCompilations: _shaderCompilations,
      durationSeconds: (_sessionStopwatch?.elapsedMilliseconds ?? 0) / 1000.0,
      memoryUsageMb: null, // Platform-specific
      peakMemoryMb: _peakMemoryMb,
    );
  }

  /// Gets a formatted summary of the current performance.
  String getSummary() {
    final m = _currentMetrics;
    final buffer = StringBuffer();

    buffer.writeln('=== Performance Summary ===');
    buffer.writeln('Duration: ${m.durationSeconds.toStringAsFixed(1)}s');
    buffer
        .writeln('FPS: ${m.fps.toStringAsFixed(1)} (${_getFpsRating(m.fps)})');
    buffer.writeln('Frame Time: ${m.avgFrameTimeMs.toStringAsFixed(2)}ms avg');
    buffer.writeln('  Min: ${m.minFrameTimeMs.toStringAsFixed(2)}ms');
    buffer.writeln('  Max: ${m.maxFrameTimeMs.toStringAsFixed(2)}ms');
    buffer.writeln('  P95: ${m.p95FrameTimeMs.toStringAsFixed(2)}ms');
    buffer.writeln('  P99: ${m.p99FrameTimeMs.toStringAsFixed(2)}ms');
    buffer.writeln(
        'Dropped Frames: ${m.droppedFrames}/${m.frameCount} (${m.dropPercentage.toStringAsFixed(1)}%)');
    buffer.writeln('Shader Compilations: ${m.shaderCompilations}');
    buffer
        .writeln('Stability Score: ${m.stabilityScore.toStringAsFixed(0)}/100');

    return buffer.toString();
  }

  String _getFpsRating(double fps) {
    if (fps >= 58) return 'Excellent';
    if (fps >= 50) return 'Good';
    if (fps >= 30) return 'Acceptable';
    return 'Poor';
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Extension for calculating square root on doubles.
extension DoubleExtension on double {
  double sqrt() => this >= 0 ? math.sqrt(this) : 0;
}
