import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';

/// Stable catalog entry used by the redesigned browser.
///
/// This is intentionally separate from [FractalModule] so we can scale the
/// catalog to many entries (e.g. PRD 200) while still mapping to currently
/// implemented render modules.
@immutable
class CatalogEntry {
  /// Stable ID for catalog persistence, analytics, and deep links.
  ///
  /// Must never change once published.
  final String catalogId;

  /// Backing runtime fractal module that can render this entry today.
  final FractalModule module;

  /// Display category used to group entries in the catalog UI.
  final String category;

  /// Product family used to keep isolated entry types out of core flows.
  final CatalogFamily family;

  /// Optional search aliases used by catalog filtering.
  final List<String> aliases;

  const CatalogEntry({
    required this.catalogId,
    required this.module,
    required this.category,
    this.family = CatalogFamily.core,
    this.aliases = const [],
  });
}
