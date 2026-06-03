import 'dart:io';

import 'package:flutter_fractals/features/catalog/catalog_thumbnail_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogThumbnailPlan', () {
    test('maps core catalog IDs to catalog thumbnail asset paths', () {
      final plan = CatalogThumbnailPlan.fromCatalogId('core.mandelbrot');

      expect(plan.catalogId, 'core.mandelbrot');
      expect(plan.assetId, 'mandelbrot');
      expect(plan.assetPath, 'assets/catalog_thumbs/mandelbrot.png');
    });

    test('preserves raw catalog IDs that are already asset IDs', () {
      final plan = CatalogThumbnailPlan.fromCatalogId('phoenix');

      expect(plan.assetId, 'phoenix');
      expect(plan.assetPath, 'assets/catalog_thumbs/phoenix.png');
    });
  });

  group('CatalogThumbnailLoadState', () {
    test('does not mark existing generated thumbnails approximate before error',
        () {
      for (final catalogId in ['core.nova', 'core.phoenix']) {
        final plan = CatalogThumbnailPlan.fromCatalogId(catalogId);
        expect(
          File(plan.assetPath).existsSync(),
          isTrue,
          reason: '${plan.assetPath} is the regression fixture',
        );

        const loading = CatalogThumbnailLoadState(
          imageLoaded: false,
          imageError: false,
        );
        const loaded = CatalogThumbnailLoadState(
          imageLoaded: true,
          imageError: false,
        );

        expect(loading.isApproximatePreview, isFalse, reason: catalogId);
        expect(loading.showsLoadingPlaceholder, isTrue, reason: catalogId);
        expect(loaded.isApproximatePreview, isFalse, reason: catalogId);
        expect(loaded.showsFallbackPreview, isFalse, reason: catalogId);
      }
    });

    test('marks only fallback thumbnails as approximate previews', () {
      const failed = CatalogThumbnailLoadState(
        imageLoaded: false,
        imageError: true,
      );

      expect(failed.showsLoadingPlaceholder, isFalse);
      expect(failed.showsFallbackPreview, isTrue);
      expect(failed.isApproximatePreview, isTrue);
    });
  });
}
