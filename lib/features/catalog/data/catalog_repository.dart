import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time/catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/features/catalog/data/performance_fractal_catalog.dart';

/// Catalog data source for the Explore screen.
///
/// Phase 1: derives entries from currently implemented modules while assigning
/// stable catalog IDs. This keeps IDs future-proof for PRD-200 ingest.
class CatalogRepository {
  final List<CatalogEntry> entries;

  const CatalogRepository({required this.entries});

  factory CatalogRepository.fromRegistry(ModuleRegistry registry) {
    return CatalogRepository.fromFamilies(
      coreModules: registry.modules,
      performanceModules: PerformanceFractalCatalog.buildModules(),
    );
  }

  factory CatalogRepository.fromFamilies({
    required Iterable<FractalModule> coreModules,
    Iterable<FractalModule> performanceModules = const [],
  }) {
    final categoriesById = {
      for (final config in escapeTimeCatalog) config.id: config.category,
      for (final config in raymarched3DCatalog) config.id: config.category,
    };
    final performanceIds =
        performanceModules.map((module) => module.id).toSet();
    final entries = <CatalogEntry>[
      for (final module in coreModules)
        if (!performanceIds.contains(module.id))
          _entryForModule(
            module,
            family: CatalogFamily.core,
            categoriesById: categoriesById,
          ),
      for (final module in performanceModules)
        _entryForModule(
          module,
          family: CatalogFamily.performance,
          categoriesById: categoriesById,
        ),
    ];

    return CatalogRepository(entries: List.unmodifiable(entries));
  }

  static CatalogEntry _entryForModule(
    FractalModule module, {
    required CatalogFamily family,
    required Map<String, String> categoriesById,
  }) {
    return CatalogEntry(
      // Stable prefix to decouple future module refactors from IDs.
      catalogId: family.catalogIdFor(module),
      module: module,
      category: family.forcedCategory ??
          categoriesById[module.id] ??
          _categoryForModule(module),
      family: family,
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
