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

    test('waits for asset manifest before loading images', () {
      const loadingManifest = CatalogThumbnailLoadState(
        assetManifestLoaded: false,
        hasExactAsset: false,
        imageLoaded: false,
        imageError: false,
      );

      expect(loadingManifest.showsLoadingPlaceholder, isTrue);
      expect(loadingManifest.showsFallbackPreview, isFalse);
      expect(loadingManifest.shouldLoadImage, isFalse);
      expect(loadingManifest.isApproximatePreview, isFalse);
    });

    test('loads only thumbnails present in the asset manifest', () {
      const exactPending = CatalogThumbnailLoadState(
        assetManifestLoaded: true,
        hasExactAsset: true,
        imageLoaded: false,
        imageError: false,
      );
      const missingAsset = CatalogThumbnailLoadState(
        assetManifestLoaded: true,
        hasExactAsset: false,
        imageLoaded: false,
        imageError: false,
      );

      expect(exactPending.shouldLoadImage, isTrue);
      expect(exactPending.showsLoadingPlaceholder, isTrue);
      expect(exactPending.showsFallbackPreview, isFalse);

      expect(missingAsset.shouldLoadImage, isFalse);
      expect(missingAsset.showsLoadingPlaceholder, isFalse);
      expect(missingAsset.showsFallbackPreview, isTrue);
      expect(missingAsset.isApproximatePreview, isTrue);
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
