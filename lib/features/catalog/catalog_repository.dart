import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time/catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';

/// Catalog data source for the Explore screen.
///
/// Phase 1: derives entries from currently implemented modules while assigning
/// stable catalog IDs. This keeps IDs future-proof for PRD-200 ingest.
class CatalogRepository {
  final List<CatalogEntry> entries;

  const CatalogRepository({required this.entries});

  factory CatalogRepository.fromRegistry(ModuleRegistry registry) {
    final categoriesById = {
      for (final config in escapeTimeCatalog) config.id: config.category,
      for (final config in raymarched3DCatalog) config.id: config.category,
    };

    return CatalogRepository(
      entries: registry.modules
          .map(
            (module) => CatalogEntry(
              // Stable prefix to decouple future module refactors from IDs.
              catalogId: 'core.${module.id}',
              module: module,
              category: categoriesById[module.id] ?? _categoryForModule(module),
            ),
          )
          .toList(growable: false),
    );
  }

  static String _categoryForModule(FractalModule module) {
    if (module.id.startsWith('life_like_b')) {
      return 'Cellular & Stochastic';
    }
    if (const {'julia', 'julia_dual', 'phoenix', 'nova'}.contains(module.id)) {
      return 'Escape-Time';
    }
    return module.dimension == FractalDimension.threeD
        ? '3D Fractals'
        : 'Other';
  }

  CatalogEntry byCatalogId(String catalogId) {
    return entries.firstWhere((entry) => entry.catalogId == catalogId);
  }

  @visibleForTesting
  Set<String> allIds() => entries.map((e) => e.catalogId).toSet();
}
