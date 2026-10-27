import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/burning_ship_degrees.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time/catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d/catalog.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
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

  /// Degree-only legacy cards remain resolvable in Favorites and Recent.
  Iterable<CatalogEntry> get exploreEntries => entries
      .where((entry) => !burningShipDegrees.containsKey(entry.module.id));

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
      'hydrogen_orbital': 'Scientific Visualization',
      'number_wall': 'Number Walls',
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
          (module.id == 'number_wall'
              ? 'Number Walls'
              : FractalMathematics.forModule(module,
                      category: categoriesById[module.id])
                  .family),
      family: family,
    );
  }

  CatalogEntry byCatalogId(String catalogId) {
    return entries.firstWhere((entry) => entry.catalogId == catalogId);
  }

  @visibleForTesting
  Set<String> allIds() => entries.map((e) => e.catalogId).toSet();
}
