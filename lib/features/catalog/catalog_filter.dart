import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Replayable catalog search query used by the catalog screen.
///
/// The UI debounces text input, then filters entries by localized display name,
/// aliases, stable catalog ID, and category. Keeping the case/whitespace
/// normalization in one pure value object makes search behavior testable without
/// pumping the whole catalog widget.
final class CatalogSearchQuery {
  const CatalogSearchQuery._(this.value);

  factory CatalogSearchQuery.fromText(String text) {
    return CatalogSearchQuery._(text.trim().toLowerCase());
  }

  /// Lower-case, trimmed query text.
  final String value;

  bool get isEmpty => value.isEmpty;

  bool matches(CatalogEntry entry, AppLocalizations l10n) {
    if (isEmpty) return true;

    return _searchableFields(entry, l10n).any(
      (field) => field.toLowerCase().contains(value),
    );
  }

  Iterable<String> _searchableFields(
    CatalogEntry entry,
    AppLocalizations l10n,
  ) sync* {
    yield entry.module.displayName(l10n);
    yield* entry.aliases;
    yield entry.catalogId;
    yield entry.category;
  }
}
