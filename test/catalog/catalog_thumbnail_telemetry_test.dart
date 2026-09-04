import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('measures first thumbnail and visible render batch completion', () {
    var now = DateTime.utc(2026, 9, 2);
    final events = <String>[];
    final telemetry = CatalogThumbnailTelemetry(
      now: () => now,
      log: (message, data) => events.add(message),
    );

    telemetry.beginSession();
    telemetry.recordCacheLookup('a', hit: false);
    telemetry.recordCacheLookup('b', hit: false);
    telemetry.recordVisibleRenderQueued('a');
    telemetry.recordVisibleRenderQueued('b');
    now = now.add(const Duration(milliseconds: 200));
    telemetry.recordDisplayed('a', source: CatalogThumbnailSource.render);
    now = now.add(const Duration(milliseconds: 100));
    telemetry.recordDisplayed('b', source: CatalogThumbnailSource.render);

    final snapshot = telemetry.snapshot;
    expect(snapshot.requestCount, 2);
    expect(snapshot.cacheHitCount, 0);
    expect(snapshot.cacheHitRate, 0);
    expect(snapshot.renderFailureCount, 0);
    expect(snapshot.timeToFirstThumbnail, const Duration(milliseconds: 200));
    expect(
      snapshot.visibleGridCompletionTime,
      const Duration(milliseconds: 300),
    );
    expect(
      events,
      containsAllInOrder([
        'session_started',
        'first_thumbnail_displayed',
        'visible_grid_complete',
      ]),
    );
  });

  test('deduplicates cache lookups and does not report failed grids complete',
      () {
    var now = DateTime.utc(2026, 9, 2);
    final events = <String>[];
    final telemetry = CatalogThumbnailTelemetry(
      now: () => now,
      log: (message, data) => events.add(message),
    );

    telemetry.beginSession();
    telemetry.recordCacheLookup('cached', hit: true);
    telemetry.recordCacheLookup('cached', hit: true);
    now = now.add(const Duration(milliseconds: 15));
    telemetry.recordDisplayed(
      'cached',
      source: CatalogThumbnailSource.memoryCache,
    );
    telemetry.recordVisibleRenderQueued('failed');
    telemetry.recordRenderFailure('failed', reason: 'readback_timeout');

    final snapshot = telemetry.snapshot;
    expect(snapshot.requestCount, 1);
    expect(snapshot.cacheHitCount, 1);
    expect(snapshot.cacheHitRate, 1);
    expect(snapshot.renderFailureCount, 1);
    expect(snapshot.timeToFirstThumbnail, const Duration(milliseconds: 15));
    expect(snapshot.visibleGridCompletionTime, isNull);
    expect(events, contains('render_failure'));
    expect(events, isNot(contains('visible_grid_complete')));
  });
}
