import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_plan.dart';
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

    test('maps generated Life-like rule IDs to a shared CA family thumbnail',
        () {
      final first = CatalogThumbnailPlan.fromCatalogId('life_like_b000_s000');
      final later = CatalogThumbnailPlan.fromCatalogId('life_like_b103_s008');

      expect(first.assetId, 'maze_ca');
      expect(later.assetId, 'maze_ca');
      expect(later.assetPath, 'assets/catalog_thumbs/maze_ca.png');
    });
  });

  group('CatalogThumbnailAvailability', () {
    test('centralizes asset path and state from manifest evidence', () {
      final thumbnail = CatalogThumbnailAvailability.fromCatalogId(
        catalogId: 'core.mandelbrot',
        availableThumbnailIds: const {'mandelbrot'},
        manifestFailed: false,
        imageLoaded: false,
        imageError: false,
      );

      expect(thumbnail.assetPath, 'assets/catalog_thumbs/mandelbrot.png');
      expect(thumbnail.shouldLoadImage, isTrue);
      expect(thumbnail.showsLoadingPlaceholder, isTrue);
      expect(thumbnail.isApproximatePreview, isFalse);
    });

    test('uses fallback preview when manifest lacks an exact asset', () {
      final thumbnail = CatalogThumbnailAvailability.fromCatalogId(
        catalogId: 'core.mandelbrot',
        availableThumbnailIds: const <String>{},
        manifestFailed: false,
        imageLoaded: false,
        imageError: false,
      );

      expect(thumbnail.shouldLoadImage, isFalse);
      expect(thumbnail.showsFallbackPreview, isTrue);
      expect(thumbnail.isApproximatePreview, isTrue);
    });
  });

  group('CatalogThumbnailLoadState', () {
    test('does not mark pending exact thumbnails approximate before error', () {
      const loading = CatalogThumbnailLoadState(
        imageLoaded: false,
        imageError: false,
      );
      const loaded = CatalogThumbnailLoadState(
        imageLoaded: true,
        imageError: false,
      );

      expect(loading.isApproximatePreview, isFalse);
      expect(loading.showsLoadingPlaceholder, isTrue);
      expect(loaded.isApproximatePreview, isFalse);
      expect(loaded.showsFallbackPreview, isFalse);
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
