import 'package:flutter/services.dart';

/// Replayable thumbnail asset plan for one catalog entry.
///
/// Catalog IDs are stable public IDs such as `core.mandelbrot`, while asset
/// thumbnails are stored by raw module ID under `assets/catalog_thumbs/`.
/// Keeping that mapping pure makes thumbnail provenance testable without
/// pumping the catalog widget.
final class CatalogThumbnailPlan {
  final String catalogId;
  final String assetId;

  const CatalogThumbnailPlan._({
    required this.catalogId,
    required this.assetId,
  });

  factory CatalogThumbnailPlan.fromCatalogId(String catalogId) {
    return CatalogThumbnailPlan._(
      catalogId: catalogId,
      assetId: assetIdForCatalogId(catalogId),
    );
  }

  String get assetPath => 'assets/catalog_thumbs/$assetId.png';

  static String assetIdForCatalogId(String catalogId) {
    return catalogId.startsWith('core.') ? catalogId.substring(5) : catalogId;
  }
}

/// Replayable visibility state for catalog thumbnail provenance labels.
///
/// The catalog used to rely on a hand-maintained list of IDs that supposedly
/// had exact thumbnails. That list drifted behind generated assets, so real
/// PNG thumbnails could be shown with an incorrect "Preview approximate" label.
/// Treat image load success/failure as the source of truth instead.
Future<Set<String>>? _catalogThumbnailAssetIdsFuture;

/// Loads the available catalog thumbnail asset IDs from Flutter's asset manifest.
///
/// This lets web builds avoid constructing `AssetImage`s for missing thumbnails,
/// preventing browser-console 404 noise while still using every generated PNG
/// that is actually bundled.
Future<Set<String>> loadCatalogThumbnailAssetIds({AssetBundle? bundle}) {
  if (bundle != null) {
    return _loadCatalogThumbnailAssetIds(bundle);
  }
  return _catalogThumbnailAssetIdsFuture ??= _loadCatalogThumbnailAssetIds(
    rootBundle,
  );
}

Future<Set<String>> _loadCatalogThumbnailAssetIds(AssetBundle bundle) async {
  final manifest = await AssetManifest.loadFromAssetBundle(bundle);
  return manifest
      .listAssets()
      .where((asset) =>
          asset.startsWith('assets/catalog_thumbs/') && asset.endsWith('.png'))
      .map((asset) => asset.split('/').last.replaceAll('.png', ''))
      .toSet();
}

final class CatalogThumbnailLoadState {
  final bool assetManifestLoaded;
  final bool hasExactAsset;
  final bool imageLoaded;
  final bool imageError;

  const CatalogThumbnailLoadState({
    this.assetManifestLoaded = true,
    this.hasExactAsset = true,
    required this.imageLoaded,
    required this.imageError,
  });

  bool get showsLoadingPlaceholder =>
      !assetManifestLoaded || (hasExactAsset && !imageLoaded && !imageError);
  bool get showsFallbackPreview =>
      assetManifestLoaded && (!hasExactAsset || imageError);
  bool get shouldLoadImage => assetManifestLoaded && hasExactAsset;
  bool get isApproximatePreview => showsFallbackPreview;
}
