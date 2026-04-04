import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart';
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
      entries: registry.modules.map(
        (module) {
          final category = categoriesById[module.id] ??
              (module.dimension == FractalDimension.threeD
                  ? '3D Fractals'
                  : 'Other');
          return CatalogEntry(
            // Stable prefix to decouple future module refactors from IDs.
            catalogId: 'core.${module.id}',
            module: module,
            category: category,
            aliases: _buildAliases(module: module, category: category),
          );
        },
      ).toList(growable: false),
    );
  }

  CatalogEntry byCatalogId(String catalogId) {
    return entries.firstWhere((entry) => entry.catalogId == catalogId);
  }

  @visibleForTesting
  Set<String> allIds() => entries.map((e) => e.catalogId).toSet();

  static List<String> _buildAliases({
    required FractalModule module,
    required String category,
  }) {
    final rawAliases = <String>{
      module.id,
      module.id.replaceAll('_', ' '),
      module.id.replaceAll('_', ''),
      category,
      module.dimension == FractalDimension.threeD ? '3d' : '2d',
    };

    final expandedAliases = <String>{};
    for (final alias in rawAliases) {
      final normalized = alias.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      expandedAliases.add(normalized);
      expandedAliases.addAll(
        normalized
            .split(RegExp(r'[^a-z0-9]+'))
            .where((token) => token.isNotEmpty),
      );
    }

    return expandedAliases.toList(growable: false)..sort();
  }
}
