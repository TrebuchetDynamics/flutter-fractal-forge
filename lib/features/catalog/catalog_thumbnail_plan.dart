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
final class CatalogThumbnailLoadState {
  final bool imageLoaded;
  final bool imageError;

  const CatalogThumbnailLoadState({
    required this.imageLoaded,
    required this.imageError,
  });

  bool get showsLoadingPlaceholder => !imageLoaded && !imageError;
  bool get showsFallbackPreview => imageError;
  bool get isApproximatePreview => showsFallbackPreview;
}
