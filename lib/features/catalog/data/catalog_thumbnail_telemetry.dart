import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';

enum CatalogThumbnailSource { memoryCache, diskCache, render, asset }

@immutable
class CatalogThumbnailTelemetrySnapshot {
  final int requestCount;
  final int cacheHitCount;
  final int renderFailureCount;
  final Duration? timeToFirstThumbnail;
  final Duration? visibleGridCompletionTime;

  const CatalogThumbnailTelemetrySnapshot({
    required this.requestCount,
    required this.cacheHitCount,
    required this.renderFailureCount,
    required this.timeToFirstThumbnail,
    required this.visibleGridCompletionTime,
  });

  double get cacheHitRate =>
      requestCount == 0 ? 0 : cacheHitCount / requestCount;
}

typedef CatalogThumbnailTelemetryLog = void Function(
  String message,
  Map<String, Object?> data,
);

/// Local-only catalog thumbnail timing and reliability metrics.
///
/// A session starts whenever the catalog screen is created. Requests are
/// deduplicated by render signature so sliver recycling does not inflate the
/// cache-hit rate. The visible-grid metric covers the first batch of visible
/// runtime cache misses; a failed render prevents that batch from being
/// reported as complete.
class CatalogThumbnailTelemetry {
  CatalogThumbnailTelemetry({
    DateTime Function()? now,
    CatalogThumbnailTelemetryLog? log,
  })  : _now = now ?? DateTime.now,
        _log = log ?? _logToAppLogger;

  static final CatalogThumbnailTelemetry instance = CatalogThumbnailTelemetry();

  final DateTime Function() _now;
  final CatalogThumbnailTelemetryLog _log;
  final Set<String> _requested = <String>{};
  final Set<String> _cacheHits = <String>{};
  final Set<String> _displayed = <String>{};
  final Set<String> _visibleRenderPending = <String>{};
  DateTime? _startedAt;
  Duration? _timeToFirstThumbnail;
  Duration? _visibleGridCompletionTime;
  int _renderFailureCount = 0;
  bool _visibleBatchStarted = false;
  bool _visibleBatchFailed = false;

  CatalogThumbnailTelemetrySnapshot get snapshot =>
      CatalogThumbnailTelemetrySnapshot(
        requestCount: _requested.length,
        cacheHitCount: _cacheHits.length,
        renderFailureCount: _renderFailureCount,
        timeToFirstThumbnail: _timeToFirstThumbnail,
        visibleGridCompletionTime: _visibleGridCompletionTime,
      );

  void beginSession() {
    _requested.clear();
    _cacheHits.clear();
    _displayed.clear();
    _visibleRenderPending.clear();
    _startedAt = _now();
    _timeToFirstThumbnail = null;
    _visibleGridCompletionTime = null;
    _renderFailureCount = 0;
    _visibleBatchStarted = false;
    _visibleBatchFailed = false;
    _log('session_started', const <String, Object?>{});
  }

  void recordCacheLookup(String signature, {required bool hit}) {
    if (!_requested.add(signature)) return;
    if (hit) _cacheHits.add(signature);
  }

  void recordVisibleRenderQueued(String signature) {
    if (_visibleGridCompletionTime != null || _visibleBatchFailed) return;
    _visibleBatchStarted = true;
    _visibleRenderPending.add(signature);
  }

  void recordNoLongerVisible(String signature) {
    _visibleRenderPending.remove(signature);
  }

  void recordDisplayed(
    String signature, {
    required CatalogThumbnailSource source,
  }) {
    if (!_displayed.add(signature)) return;
    final elapsed = _elapsed;
    if (_timeToFirstThumbnail == null) {
      _timeToFirstThumbnail = elapsed;
      _log('first_thumbnail_displayed', {
        'elapsed_ms': elapsed.inMilliseconds,
        'source': source.name,
      });
    }
    final wasPending = _visibleRenderPending.remove(signature);
    if (wasPending &&
        _visibleBatchStarted &&
        !_visibleBatchFailed &&
        _visibleRenderPending.isEmpty &&
        _visibleGridCompletionTime == null) {
      _visibleGridCompletionTime = elapsed;
      final current = snapshot;
      _log('visible_grid_complete', {
        'elapsed_ms': elapsed.inMilliseconds,
        'requests': current.requestCount,
        'cache_hits': current.cacheHitCount,
        'cache_hit_rate': current.cacheHitRate,
      });
    }
  }

  void recordRenderFailure(String signature, {required String reason}) {
    _renderFailureCount++;
    if (_visibleRenderPending.remove(signature)) _visibleBatchFailed = true;
    _log('render_failure', {
      'catalog_signature': signature,
      'reason': reason,
      'failure_count': _renderFailureCount,
    });
  }

  Duration get _elapsed {
    final startedAt = _startedAt;
    if (startedAt == null) {
      beginSession();
      return Duration.zero;
    }
    return _now().difference(startedAt);
  }

  static void _logToAppLogger(
    String message,
    Map<String, Object?> data,
  ) {
    AppLogger.instance.info(
      'catalog_thumbnail_performance',
      message,
      data: data,
    );
  }
}
