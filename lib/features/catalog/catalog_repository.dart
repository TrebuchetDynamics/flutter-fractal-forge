import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
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
    };

    return CatalogRepository(
      entries: registry.modules
          .map(
            (module) => CatalogEntry(
              // Stable prefix to decouple future module refactors from IDs.
              catalogId: 'core.${module.id}',
              module: module,
              category: categoriesById[module.id] ??
                  (module.dimension == FractalDimension.threeD
                      ? '3D Fractals'
                      : 'Other'),
            ),
          )
          .toList(growable: false),
    );
  }

  CatalogEntry byCatalogId(String catalogId) {
    return entries.firstWhere((entry) => entry.catalogId == catalogId);
  }

  @visibleForTesting
  Set<String> allIds() => entries.map((e) => e.catalogId).toSet();
}
