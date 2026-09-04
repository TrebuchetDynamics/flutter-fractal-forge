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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('rapid scrolling renders the visible Barnsley thumbnail grid',
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
    final scrollTimer = Stopwatch()..start();
    for (var attempt = 0;
        attempt < 20 && find.text('Barnsley Fern').evaluate().isEmpty;
        attempt++) {
      await tester.drag(catalog, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Barnsley Fern'), findsOneWidget);
    await tester.ensureVisible(find.text('Barnsley Fern'));

    const visibleCatalogIds = [
      'core.barnsley_fern',
      'core.barnsley_j1',
      'core.barnsley_j2',
      'core.barnsley_j3',
    ];
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      final rendered = visibleCatalogIds.where((catalogId) {
        return find
            .byKey(Key('catalogCachedThumbnail_$catalogId'))
            .evaluate()
            .isNotEmpty;
      }).length;
      if (rendered == visibleCatalogIds.length) break;
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
      '[catalog-thumbnail-gate] rapid_scroll_ms=${scrollTimer.elapsedMilliseconds} '
      'first_thumbnail_ms=${metrics.timeToFirstThumbnail!.inMilliseconds} '
      'visible_grid_ms=${metrics.visibleGridCompletionTime!.inMilliseconds} '
      'cache_hits=${metrics.cacheHitCount}/${metrics.requestCount} '
      'render_failures=${metrics.renderFailureCount}',
    );
  });
}
