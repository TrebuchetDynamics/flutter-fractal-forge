import 'package:flutter_fractals/features/catalog/catalog_thumbnail_plan.dart';

/// Canonical launch-critical modules used for first-impression visual audits.
///
/// Keep this set small and deterministic. It is the app-facing slice for
/// screenshots, thumbnail QA, and browser-preview smoke checks; it is not a
/// ranking of the full catalog.
const List<String> kFeaturedLaunchSetModuleIds = [
  'mandelbrot',
  'julia',
  'burning_ship',
  'phoenix',
  'nova',
  'newton_z3',
  'koch_snowflake',
  'barnsley_fern',
  'lorenz_2d',
];

/// Catalog IDs corresponding to [kFeaturedLaunchSetModuleIds].
final List<String> kFeaturedLaunchSetCatalogIds =
    kFeaturedLaunchSetModuleIds.map((id) => 'core.$id').toList(growable: false);

/// Thumbnail asset paths corresponding to [kFeaturedLaunchSetModuleIds].
final List<String> kFeaturedLaunchSetThumbnailAssetPaths =
    kFeaturedLaunchSetCatalogIds
        .map((id) => CatalogThumbnailPlan.fromCatalogId(id).assetPath)
        .toList(growable: false);
