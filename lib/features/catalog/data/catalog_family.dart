import 'package:flutter_fractals/core/modules/fractal_module.dart';

/// Top-level catalog family for entries that share product behavior.
///
/// Keep this separate from display category: category groups cards for browsing,
/// while family controls whether an entry belongs to the classic mathematical
/// catalog or to isolated instrument-like Performance Fractals.
enum CatalogFamily {
  core,
  performance,
}

extension CatalogFamilyMetadata on CatalogFamily {
  String get catalogIdPrefix {
    switch (this) {
      case CatalogFamily.core:
        return 'core';
      case CatalogFamily.performance:
        return 'performance';
    }
  }

  String? get forcedCategory {
    switch (this) {
      case CatalogFamily.core:
        return null;
      case CatalogFamily.performance:
        return performanceFractalsCategory;
    }
  }

  String catalogIdFor(FractalModule module) => '$catalogIdPrefix.${module.id}';
}

const performanceFractalsCategory = 'Performance Fractals';
