import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/library/library_filter.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

FractalModule _module({
  required String id,
  required String displayName,
}) {
  return FractalModule(
    id: id,
    displayName: (_) => displayName,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/dummy.frag',
    parameters: const [],
    defaultPreset: FractalPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Default',
      params: const <String, Object>{},
      view: FractalViewState.initial(),
      createdAt: DateTime.utc(2024),
      isBuiltIn: true,
    ),
    builtInPresets: const [],
    setUniforms: (_, __, ___, ____) {},
  );
}

CatalogEntry _entry({
  required String moduleId,
  required String displayName,
  required String category,
  List<String> aliases = const [],
}) {
  return CatalogEntry(
    catalogId: 'core.$moduleId',
    module: _module(id: moduleId, displayName: displayName),
    category: category,
    aliases: aliases,
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('libraryCategories', () {
    test('returns sorted unique categories', () {
      final entries = [
        _entry(moduleId: 'z', displayName: 'Z', category: 'Strange'),
        _entry(moduleId: 'a', displayName: 'A', category: 'Escape Time'),
        _entry(moduleId: 'b', displayName: 'B', category: 'Escape Time'),
      ];

      expect(libraryCategories(entries), ['Escape Time', 'Strange']);
    });
  });

  group('filterAndSortLibraryEntries', () {
    test('keeps category-first sort stable and replayable', () {
      final entries = [
        _entry(moduleId: 'zeta', displayName: 'Zeta', category: 'B'),
        _entry(moduleId: 'alpha', displayName: 'Alpha', category: 'B'),
        _entry(moduleId: 'omega', displayName: 'Omega', category: 'A'),
      ];

      final filtered = filterAndSortLibraryEntries(
        entries: entries,
        l10n: l10n,
        searchText: '',
        selectedCategory: null,
        sortOrder: LibrarySortOrder.byCategory,
      );

      expect(filtered.map((entry) => entry.module.id), [
        'omega',
        'alpha',
        'zeta',
      ]);
    });

    test('matches trimmed alias queries like the catalog search contract', () {
      final entries = [
        _entry(
          moduleId: 'visible_only',
          displayName: 'Visible Only',
          category: 'Other',
        ),
        _entry(
          moduleId: 'hidden_alias',
          displayName: 'Hidden Name',
          category: 'Other',
          aliases: const ['Phoenix Variant'],
        ),
      ];

      final filtered = filterAndSortLibraryEntries(
        entries: entries,
        l10n: l10n,
        searchText: ' phoenix ',
        selectedCategory: null,
        sortOrder: LibrarySortOrder.alphabetical,
      );

      expect(filtered.map((entry) => entry.module.id), ['hidden_alias']);
    });
  });
}
