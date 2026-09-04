import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

String _normalizeSearchText(String text) {
  const replacements = <String, String>{
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
    'ç': 'c',
  };
  var normalized = text.trim().toLowerCase();
  for (final replacement in replacements.entries) {
    normalized = normalized.replaceAll(replacement.key, replacement.value);
  }
  return normalized;
}

/// Replayable catalog search query used by the catalog screen.
///
/// The UI debounces text input, then filters entries by localized display name,
/// aliases, stable catalog ID, and category. Keeping the case/whitespace
/// normalization in one pure value object makes search behavior testable without
/// pumping the whole catalog widget.
final class CatalogSearchQuery {
  const CatalogSearchQuery._(this.value);

  factory CatalogSearchQuery.fromText(String text) {
    return CatalogSearchQuery._(_normalizeSearchText(text));
  }

  /// Lower-case, trimmed query text.
  final String value;

  bool get isEmpty => value.isEmpty;

  bool matches(CatalogEntry entry, AppLocalizations l10n) {
    return relevanceScore(entry, l10n) != null;
  }

  /// Lower scores are more relevant. Returns `null` when [entry] does not
  /// match this query.
  int? relevanceScore(CatalogEntry entry, AppLocalizations l10n) {
    if (isEmpty) return 0;

    final displayName = _normalizeSearchText(entry.module.displayName(l10n));
    final aliases = entry.aliases.map(_normalizeSearchText).toList();
    final catalogId = _normalizeSearchText(entry.catalogId);

    if (displayName == value) return 0;
    if (aliases.any((alias) => alias == value) ||
        catalogId == value ||
        catalogId.endsWith('.$value')) {
      return 1;
    }
    if (displayName.startsWith(value)) return 2;
    if (aliases.any((alias) => alias.startsWith(value))) return 3;
    final tokens = value.split(RegExp(r'\s+'));
    if (tokens.length > 1 && tokens.every(displayName.contains)) return 4;
    if (catalogId.contains(value)) return 5;
    if (displayName.contains(value)) return 6;
    if (aliases.any((alias) => alias.contains(value))) return 7;

    return _searchableFields(entry, l10n)
            .map(_normalizeSearchText)
            .any((field) => field.contains(value))
        ? 8
        : null;
  }

  Iterable<String> _searchableFields(
    CatalogEntry entry,
    AppLocalizations l10n,
  ) sync* {
    yield entry.module.displayName(l10n);
    yield* entry.aliases;
    yield entry.catalogId;
    yield entry.category;
    yield entry.module.dimension == FractalDimension.threeD
        ? l10n.dimension3d
        : l10n.dimension2d;
    for (final parameter in entry.module.parameters) {
      yield parameter.id;
      yield parameter.label(l10n);
      for (final option in parameter.options) {
        yield option.label(l10n);
      }
    }
  }
}

/// Dimension/category refinement selected in the catalog filter bar.
enum CatalogDimensionFilter { all, twoD, threeD, kaleidoscope }

/// Immutable catalog filter inputs for one replayable filter pass.
final class CatalogFilterCriteria {
  final String query;
  final CatalogDimensionFilter dimensionFilter;
  final String? selectedCategory;

  const CatalogFilterCriteria({
    required this.query,
    this.dimensionFilter = CatalogDimensionFilter.all,
    this.selectedCategory,
  });

  CatalogSearchQuery get searchQuery => CatalogSearchQuery.fromText(query);

  bool get hasActiveRefinements =>
      !searchQuery.isEmpty ||
      dimensionFilter != CatalogDimensionFilter.all ||
      selectedCategory != null;
}

/// Replayable catalog filter outputs consumed by the screen.
///
/// The catalog UI needs three related entry sets from one query snapshot:
/// filtered cards, dimension-chip counts, and category-chip counts. Keeping them
/// together prevents count chips and displayed cards from drifting when a search,
/// dimension, or category refinement is active.
final class CatalogFilterResult {
  final List<CatalogEntry> filteredEntries;
  final List<CatalogEntry> dimensionBaseEntries;
  final List<CatalogEntry> categoryBaseEntries;
  final Map<CatalogDimensionFilter, int> dimensionCounts;
  final Map<String, int> categoryCounts;
  final List<String> sortedCategories;

  const CatalogFilterResult._({
    required this.filteredEntries,
    required this.dimensionBaseEntries,
    required this.categoryBaseEntries,
    required this.dimensionCounts,
    required this.categoryCounts,
    required this.sortedCategories,
  });

  int countForDimension(CatalogDimensionFilter filter) =>
      dimensionCounts[filter] ?? 0;
}

/// Pure catalog filter/count contract shared by UI and tests.
final class CatalogFilter {
  const CatalogFilter._();

  static CatalogFilterResult apply({
    required Iterable<CatalogEntry> entries,
    required CatalogFilterCriteria criteria,
    required AppLocalizations l10n,
  }) {
    final query = criteria.searchQuery;
    final matchesSearch = entries
        .where((entry) => query.matches(entry, l10n))
        .toList(growable: true);
    if (!query.isEmpty) {
      matchesSearch.sort((a, b) {
        final scoreCompare = (query.relevanceScore(a, l10n) ?? 999)
            .compareTo(query.relevanceScore(b, l10n) ?? 999);
        if (scoreCompare != 0) return scoreCompare;
        return a.module.displayName(l10n).compareTo(b.module.displayName(l10n));
      });
    }

    final dimensionBaseEntries = matchesSearch
        .where(
          (entry) => _matchesSelectedCategory(entry, criteria.selectedCategory),
        )
        .toList(growable: false);
    final dimensionCounts = Map<CatalogDimensionFilter, int>.unmodifiable({
      CatalogDimensionFilter.all: dimensionBaseEntries.length,
      CatalogDimensionFilter.twoD: dimensionBaseEntries
          .where(
            (entry) => matchesDimension(entry, CatalogDimensionFilter.twoD),
          )
          .length,
      CatalogDimensionFilter.threeD: dimensionBaseEntries
          .where(
            (entry) => matchesDimension(entry, CatalogDimensionFilter.threeD),
          )
          .length,
      CatalogDimensionFilter.kaleidoscope: dimensionBaseEntries
          .where(
            (entry) => matchesDimension(
              entry,
              CatalogDimensionFilter.kaleidoscope,
            ),
          )
          .length,
    });

    final categoryBaseEntries = matchesSearch
        .where((entry) => matchesDimension(entry, criteria.dimensionFilter))
        .toList(growable: false);
    final categoryCounts = countCategories(categoryBaseEntries);
    final sortedCategories = sortCategories(
      categoryCounts,
      selectedCategory: criteria.selectedCategory,
    );

    final filteredEntries = categoryBaseEntries
        .where(
          (entry) => _matchesSelectedCategory(entry, criteria.selectedCategory),
        )
        .toList(growable: false);

    return CatalogFilterResult._(
      filteredEntries: filteredEntries,
      dimensionBaseEntries: dimensionBaseEntries,
      categoryBaseEntries: categoryBaseEntries,
      dimensionCounts: dimensionCounts,
      categoryCounts: categoryCounts,
      sortedCategories: sortedCategories,
    );
  }

  static bool matchesDimension(
    CatalogEntry entry,
    CatalogDimensionFilter filter,
  ) {
    switch (filter) {
      case CatalogDimensionFilter.all:
        return true;
      case CatalogDimensionFilter.twoD:
        return entry.module.dimension == FractalDimension.twoD;
      case CatalogDimensionFilter.threeD:
        return entry.module.dimension == FractalDimension.threeD;
      case CatalogDimensionFilter.kaleidoscope:
        return entry.category.toLowerCase().contains('kaleidoscope');
    }
  }

  static Map<String, int> countCategories(Iterable<CatalogEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
    }
    return Map<String, int>.unmodifiable(counts);
  }

  static List<String> sortCategories(
    Map<String, int> categoryCounts, {
    String? selectedCategory,
  }) {
    final categories = categoryCounts.keys.toList()
      ..sort((a, b) {
        final countCompare = (categoryCounts[b] ?? 0).compareTo(
          categoryCounts[a] ?? 0,
        );
        if (countCompare != 0) return countCompare;
        return a.compareTo(b);
      });

    if (selectedCategory != null) {
      categories.remove(selectedCategory);
      categories.insert(0, selectedCategory);
    }

    return List<String>.unmodifiable(categories);
  }

  static bool _matchesSelectedCategory(
    CatalogEntry entry,
    String? selectedCategory,
  ) {
    return selectedCategory == null || entry.category == selectedCategory;
  }
}
