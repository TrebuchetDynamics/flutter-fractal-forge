import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';

/// Isolated catalog source for instrument-like Performance Fractals.
///
/// Keep these modules outside the core [ModuleRegistry] list so classic catalog
/// flows, random navigation, and existing fractal controls do not pick them up
/// accidentally. Add the first concrete performance module here.
final class PerformanceFractalCatalog {
  const PerformanceFractalCatalog._();

  static const family = CatalogFamily.performance;
  static const category = performanceFractalsCategory;

  static List<FractalModule> buildModules() => const [];
}
