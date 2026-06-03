import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/catalog_filter.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Sort choices for the library list.
enum LibrarySortOrder { byCategory, alphabetical }

/// Returns stable library categories for the filter chip row.
List<String> libraryCategories(Iterable<CatalogEntry> entries) {
  final categories = entries.map((entry) => entry.category).toSet().toList();
  categories.sort();
  return categories;
}

/// Pure filtering/sorting pipeline for [FractalLibraryScreen].
///
/// The screen owns text controllers and selected chip state; this helper owns
/// the replayable candidate/data-flow steps so catalog/library search drift is
/// visible in unit tests.
List<CatalogEntry> filterAndSortLibraryEntries({
  required Iterable<CatalogEntry> entries,
  required AppLocalizations l10n,
  required String searchText,
  required String? selectedCategory,
  required LibrarySortOrder sortOrder,
}) {
  final query = CatalogSearchQuery.fromText(searchText);
  var filtered = entries.toList();

  if (selectedCategory != null) {
    filtered = filtered
        .where((entry) => entry.category == selectedCategory)
        .toList(growable: false);
  }

  if (!query.isEmpty) {
    filtered = filtered
        .where((entry) => query.matches(entry, l10n))
        .toList(growable: false);
  }

  switch (sortOrder) {
    case LibrarySortOrder.alphabetical:
      filtered.sort((a, b) =>
          a.module.displayName(l10n).compareTo(b.module.displayName(l10n)));
    case LibrarySortOrder.byCategory:
      filtered.sort((a, b) {
        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) return categoryCompare;
        return a.module.displayName(l10n).compareTo(b.module.displayName(l10n));
      });
  }

  return filtered;
}
