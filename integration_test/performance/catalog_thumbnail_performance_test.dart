import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_telemetry.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('rapid scrolling renders every visible catalog thumbnail',
      (tester) async {
    binding.platformDispatcher.semanticsEnabledTestValue = false;
    SharedPreferences.setMockInitialValues({});
    CatalogRuntimeThumbnailCache.clearForTesting();
    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final catalog = find.byType(CustomScrollView);
    final scrollable = find
        .descendant(
          of: catalog,
          matching: find.byType(Scrollable),
        )
        .first;
    final position = tester.state<ScrollableState>(scrollable).position;
    final startOffset = position.pixels;
    final targetDistance = position.viewportDimension * 3;
    final scrollTimer = Stopwatch()..start();
    // Traverse three screens, independent of catalog size or alphabetical order.
    // Twenty gestures remains a safety bound, not the required workload.
    for (var attempt = 0;
        attempt < 20 && position.pixels - startOffset < targetDistance;
        attempt++) {
      await tester.drag(catalog, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(position.pixels - startOffset, greaterThanOrEqualTo(targetDistance));
    // Freeze identities before waiting for completion. Include partially visible
    // previews, but not off-screen children mounted in the sliver cache extent.
    final viewport = tester.getRect(scrollable);
    final visibleCatalogIds = <String>[];
    for (final element in catalogModuleCards().evaluate()) {
      final catalogId = (element.widget.key! as ValueKey<String>)
          .value
          .substring('catalogModuleCard_'.length);
      final preview = find.byWidgetPredicate((widget) =>
          widget.key == Key('catalogRuntimeThumbnail_$catalogId') ||
          widget.key == Key('catalogCachedThumbnail_$catalogId'));
      expect(preview, findsOneWidget);
      if (tester.getRect(preview).overlaps(viewport)) {
        visibleCatalogIds.add(catalogId);
      }
    }
    expect(visibleCatalogIds.length, greaterThanOrEqualTo(2));
    debugPrint(
      '[catalog-thumbnail-gate] scroll_ms=${scrollTimer.elapsedMilliseconds} '
      'distance_px=${position.pixels - startOffset} target_px=$targetDistance '
      'visible_cards=${visibleCatalogIds.length}',
    );
    while (scrollTimer.elapsed < const Duration(seconds: 5)) {
      final rendered = visibleCatalogIds.where((catalogId) {
        return find
            .byKey(Key('catalogCachedThumbnail_$catalogId'))
            .evaluate()
            .isNotEmpty;
      }).length;
      // Wait for both the snapshotted visible cards and full-grid telemetry.
      if (rendered == visibleCatalogIds.length &&
          CatalogThumbnailTelemetry
                  .instance.snapshot.visibleGridCompletionTime !=
              null) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    scrollTimer.stop();

    for (final catalogId in visibleCatalogIds) {
      expect(
        find.byKey(Key('catalogCachedThumbnail_$catalogId')),
        findsOneWidget,
        reason: '$catalogId did not replace its rapid-scroll placeholder',
      );
    }
    final metrics = CatalogThumbnailTelemetry.instance.snapshot;
    expect(metrics.renderFailureCount, 0);
    expect(metrics.timeToFirstThumbnail, isNotNull);
    expect(metrics.visibleGridCompletionTime, isNotNull);
    expect(scrollTimer.elapsed, lessThan(const Duration(seconds: 5)));
    debugPrint(
      '[catalog-thumbnail-gate] visible_cards=${visibleCatalogIds.length} '
      'rapid_scroll_ms=${scrollTimer.elapsedMilliseconds} '
      'first_thumbnail_ms=${metrics.timeToFirstThumbnail!.inMilliseconds} '
      'visible_grid_ms=${metrics.visibleGridCompletionTime!.inMilliseconds} '
      'cache_hits=${metrics.cacheHitCount}/${metrics.requestCount} '
      'render_failures=${metrics.renderFailureCount}',
    );
  });
}
