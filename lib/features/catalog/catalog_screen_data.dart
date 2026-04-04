import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

const _kFeaturedFractalIds = <String>[
  'mandelbrot',
  'julia',
  'burning_ship',
  'newton_z3',
  'mandelbulb',
  'buddhabrot',
  'sierpinski_triangle',
  'barnsley_fern',
];

enum CatalogDimensionFilter { all, twoD, threeD }

enum CatalogSortOrder { byCategory, alphabetical }

@immutable
class CatalogDimensionCounts {
  final int all;
  final int twoD;
  final int threeD;

  const CatalogDimensionCounts({
    required this.all,
    required this.twoD,
    required this.threeD,
  });
}

/// Immutable presentation data for the catalog screen.
///
/// The screen remains responsible for rendering and navigation, while this
/// value object carries the already-filtered and grouped data needed by the UI.
@immutable
class CatalogScreenData {
  final String normalizedQuery;
  final List<CatalogEntry> filteredEntries;
  final List<CatalogSection> sections;
  final Map<String, String> semanticLabels;
  final CatalogDimensionCounts dimensionCounts;
  final int categoryScopeCount;
  final Map<String, int> categoryCounts;
  final List<String> sortedCategories;
  final List<CatalogEntry> featuredEntries;
  final bool hasActiveRefinements;

  const CatalogScreenData({
    required this.normalizedQuery,
    required this.filteredEntries,
    required this.sections,
    required this.semanticLabels,
    required this.dimensionCounts,
    required this.categoryScopeCount,
    required this.categoryCounts,
    required this.sortedCategories,
    required this.featuredEntries,
    required this.hasActiveRefinements,
  });

  bool get isEmpty => filteredEntries.isEmpty;
  bool get showFeatured => featuredEntries.isNotEmpty && !hasActiveRefinements;
  int get resultCount => filteredEntries.length;
  int get visibleCategoryCount => categoryCounts.length;

  String semanticLabelFor(CatalogEntry entry) =>
      semanticLabels[entry.catalogId] ?? entry.catalogId;
}

@immutable
class CatalogSection {
  final String title;
  final List<CatalogEntry> entries;

  const CatalogSection({
    required this.title,
    required this.entries,
  });

  int get count => entries.length;
}

/// Builds localized catalog presentation data from raw catalog entries.
class CatalogScreenDataBuilder {
  final List<CatalogEntry> entries;

  CatalogScreenDataBuilder({required List<CatalogEntry> entries})
      : entries = List<CatalogEntry>.unmodifiable(entries);

  CatalogScreenData build({
    required AppLocalizations l10n,
    required String searchQuery,
    CatalogDimensionFilter dimensionFilter = CatalogDimensionFilter.all,
    CatalogSortOrder sortOrder = CatalogSortOrder.byCategory,
    String? selectedCategory,
  }) {
    final normalizedQuery = _normalizeQuery(searchQuery);
    final searchMatchedEntries = _filterEntries(
      entries: entries,
      l10n: l10n,
      normalizedQuery: normalizedQuery,
    );
    final dimensionScopeEntries = _filterBySelectedCategory(
      entries: searchMatchedEntries,
      selectedCategory: selectedCategory,
    );
    final categoryScopeEntries = _filterByDimension(
      entries: searchMatchedEntries,
      dimensionFilter: dimensionFilter,
    );
    final filteredEntries = _filterBySelectedCategory(
      entries: categoryScopeEntries,
      selectedCategory: selectedCategory,
    );
    final categoryCounts = _buildCategoryCounts(categoryScopeEntries);
    final featuredEntries = _resolveFeaturedEntries(entries);

    return CatalogScreenData(
      normalizedQuery: normalizedQuery,
      filteredEntries: filteredEntries,
      sections: _buildSections(filteredEntries, l10n, sortOrder),
      semanticLabels: _buildSemanticLabels(entries, l10n),
      dimensionCounts: _buildDimensionCounts(dimensionScopeEntries),
      categoryScopeCount: categoryScopeEntries.length,
      categoryCounts: categoryCounts,
      sortedCategories: _sortedCategories(categoryCounts, selectedCategory),
      featuredEntries: featuredEntries,
      hasActiveRefinements: _hasActiveRefinements(
        normalizedQuery: normalizedQuery,
        dimensionFilter: dimensionFilter,
        sortOrder: sortOrder,
        selectedCategory: selectedCategory,
      ),
    );
  }

  static String _normalizeQuery(String value) => value.trim().toLowerCase();

  static List<CatalogEntry> _filterEntries({
    required List<CatalogEntry> entries,
    required AppLocalizations l10n,
    required String normalizedQuery,
  }) {
    if (normalizedQuery.isEmpty) {
      return List<CatalogEntry>.unmodifiable(entries);
    }

    final filteredEntries = entries.where(
      (entry) => _matchesSearch(
        entry: entry,
        l10n: l10n,
        normalizedQuery: normalizedQuery,
      ),
    );

    return List<CatalogEntry>.unmodifiable(filteredEntries);
  }

  static List<CatalogEntry> _filterByDimension({
    required List<CatalogEntry> entries,
    required CatalogDimensionFilter dimensionFilter,
  }) {
    if (dimensionFilter == CatalogDimensionFilter.all) {
      return List<CatalogEntry>.unmodifiable(entries);
    }

    final filteredEntries = entries.where(
      (entry) => _matchesDimension(
        entry: entry,
        dimensionFilter: dimensionFilter,
      ),
    );

    return List<CatalogEntry>.unmodifiable(filteredEntries);
  }

  static List<CatalogEntry> _filterBySelectedCategory({
    required List<CatalogEntry> entries,
    required String? selectedCategory,
  }) {
    if (selectedCategory == null) {
      return List<CatalogEntry>.unmodifiable(entries);
    }

    final filteredEntries = entries.where(
      (entry) => entry.category == selectedCategory,
    );

    return List<CatalogEntry>.unmodifiable(filteredEntries);
  }

  static bool _matchesSearch({
    required CatalogEntry entry,
    required AppLocalizations l10n,
    required String normalizedQuery,
  }) {
    final moduleName = entry.module.displayName(l10n).toLowerCase();
    final matchesAlias = entry.aliases.any(
      (alias) => alias.toLowerCase().contains(normalizedQuery),
    );

    return moduleName.contains(normalizedQuery) ||
        matchesAlias ||
        entry.catalogId.toLowerCase().contains(normalizedQuery) ||
        entry.category.toLowerCase().contains(normalizedQuery);
  }

  static bool _matchesDimension({
    required CatalogEntry entry,
    required CatalogDimensionFilter dimensionFilter,
  }) {
    switch (dimensionFilter) {
      case CatalogDimensionFilter.all:
        return true;
      case CatalogDimensionFilter.twoD:
        return entry.module.dimension == FractalDimension.twoD;
      case CatalogDimensionFilter.threeD:
        return entry.module.dimension == FractalDimension.threeD;
    }
  }

  static List<CatalogSection> _buildSections(
    List<CatalogEntry> entries,
    AppLocalizations l10n,
    CatalogSortOrder sortOrder,
  ) {
    if (entries.isEmpty) {
      return const <CatalogSection>[];
    }

    if (sortOrder == CatalogSortOrder.alphabetical) {
      final sortedEntries = List<CatalogEntry>.from(entries)
        ..sort(
          (left, right) => left.module
              .displayName(l10n)
              .compareTo(right.module.displayName(l10n)),
        );

      return List<CatalogSection>.unmodifiable([
        CatalogSection(
          title: l10n.catalogAllFractals,
          entries: List<CatalogEntry>.unmodifiable(sortedEntries),
        ),
      ]);
    }

    final groupedEntries = <String, List<CatalogEntry>>{};
    for (final entry in entries) {
      groupedEntries.putIfAbsent(entry.category, () => <CatalogEntry>[]).add(
            entry,
          );
    }

    final sortedGroups = groupedEntries.entries.toList()
      ..sort((left, right) {
        final countComparison = right.value.length.compareTo(left.value.length);
        if (countComparison != 0) {
          return countComparison;
        }

        return left.key.compareTo(right.key);
      });

    final sections = sortedGroups.map((group) {
      final sortedEntries = List<CatalogEntry>.from(group.value)
        ..sort(
          (left, right) => left.module
              .displayName(l10n)
              .compareTo(right.module.displayName(l10n)),
        );

      return CatalogSection(
        title: group.key,
        entries: List<CatalogEntry>.unmodifiable(sortedEntries),
      );
    });

    return List<CatalogSection>.unmodifiable(sections);
  }

  static CatalogDimensionCounts _buildDimensionCounts(List<CatalogEntry> entries) {
    var twoD = 0;
    var threeD = 0;
    for (final entry in entries) {
      if (entry.module.dimension == FractalDimension.threeD) {
        threeD += 1;
      } else {
        twoD += 1;
      }
    }

    return CatalogDimensionCounts(
      all: entries.length,
      twoD: twoD,
      threeD: threeD,
    );
  }

  static Map<String, int> _buildCategoryCounts(List<CatalogEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
    }

    return Map<String, int>.unmodifiable(counts);
  }

  static List<String> _sortedCategories(
    Map<String, int> categoryCounts,
    String? selectedCategory,
  ) {
    final categories = categoryCounts.keys.toList()
      ..sort((left, right) {
        final countComparison =
            (categoryCounts[right] ?? 0).compareTo(categoryCounts[left] ?? 0);
        if (countComparison != 0) {
          return countComparison;
        }

        return left.compareTo(right);
      });

    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      categories.insert(0, selectedCategory);
    }

    return List<String>.unmodifiable(categories);
  }

  static List<CatalogEntry> _resolveFeaturedEntries(List<CatalogEntry> entries) {
    final entriesById = <String, CatalogEntry>{};
    for (final entry in entries) {
      entriesById.putIfAbsent(entry.catalogId, () => entry);
      if (entry.catalogId.startsWith('core.')) {
        entriesById.putIfAbsent(entry.catalogId.substring(5), () => entry);
      }
    }

    final featuredEntries = <CatalogEntry>[];
    final seenCatalogIds = <String>{};
    for (final featuredId in _kFeaturedFractalIds) {
      final entry = entriesById[featuredId] ?? entriesById['core.$featuredId'];
      if (entry == null || !seenCatalogIds.add(entry.catalogId)) {
        continue;
      }

      featuredEntries.add(entry);
    }

    return List<CatalogEntry>.unmodifiable(featuredEntries);
  }

  static bool _hasActiveRefinements({
    required String normalizedQuery,
    required CatalogDimensionFilter dimensionFilter,
    required CatalogSortOrder sortOrder,
    required String? selectedCategory,
  }) {
    return normalizedQuery.isNotEmpty ||
        dimensionFilter != CatalogDimensionFilter.all ||
        sortOrder != CatalogSortOrder.byCategory ||
        selectedCategory != null;
  }

  static Map<String, String> _buildSemanticLabels(
    List<CatalogEntry> entries,
    AppLocalizations l10n,
  ) {
    final entriesByName = <String, List<CatalogEntry>>{};
    for (final entry in entries) {
      final name = entry.module.displayName(l10n);
      entriesByName.putIfAbsent(name, () => <CatalogEntry>[]).add(entry);
    }

    final semanticLabels = <String, String>{};
    for (final entry in entries) {
      final variants = List<CatalogEntry>.from(
        entriesByName[entry.module.displayName(l10n)] ?? const <CatalogEntry>[],
      )..sort((left, right) => left.module.id.compareTo(right.module.id));

      final variantIndex = variants.indexWhere(
        (candidate) => candidate.catalogId == entry.catalogId,
      );

      semanticLabels[entry.catalogId] = _buildSemanticLabel(
        entry: entry,
        l10n: l10n,
        duplicateNameCount: variants.length,
        duplicateIndex: variantIndex < 0 ? 0 : variantIndex,
      );
    }

    return Map<String, String>.unmodifiable(semanticLabels);
  }

  static String _buildSemanticLabel({
    required CatalogEntry entry,
    required AppLocalizations l10n,
    required int duplicateNameCount,
    required int duplicateIndex,
  }) {
    final name = entry.module.displayName(l10n);
    final dimensionLabel = entry.module.dimension == FractalDimension.threeD
        ? l10n.dimension3d
        : l10n.dimension2d;
    final baseLabel = l10n.semanticFractalCard(name, dimensionLabel);

    if (duplicateNameCount <= 1) {
      return baseLabel;
    }

    return '$baseLabel Variant ${duplicateIndex + 1}.';
  }
}
