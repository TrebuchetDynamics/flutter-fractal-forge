import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

FractalModule _module({
  String id = 'dummy_module',
  String displayName = 'Visible Name',
}) {
  return FractalModule(
    id: id,
    displayName: (_) => displayName,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/dummy.frag',
    parameters: const [],
    defaultPreset: FractalPreset(
      id: 'dummy-default',
      moduleId: 'dummy_module',
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

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('CatalogSearchQuery', () {
    test('empty query matches every entry', () {
      final entry = CatalogEntry(
        catalogId: 'core.dummy_module',
        module: _module(),
        category: 'Other',
      );

      expect(CatalogSearchQuery.fromText('   ').matches(entry, l10n), isTrue);
    });

    test('case-folds every searchable entry field', () {
      final entry = CatalogEntry(
        catalogId: 'Core.MixedCaseId',
        module: _module(displayName: 'Visible Name'),
        category: 'Escape Time',
        aliases: const ['Phoenix Alias'],
      );

      expect(CatalogSearchQuery.fromText(' visible ').matches(entry, l10n),
          isTrue);
      expect(
          CatalogSearchQuery.fromText('PHOENIX').matches(entry, l10n), isTrue);
      expect(CatalogSearchQuery.fromText('escape time').matches(entry, l10n),
          isTrue);
      expect(CatalogSearchQuery.fromText('mixedcaseid').matches(entry, l10n),
          isTrue);
    });

    test('exact display-name match ranks ahead of prefix and metadata matches',
        () {
      CatalogEntry entry(String id, String name, String category) =>
          CatalogEntry(
            catalogId: 'core.$id',
            module: _module(id: id, displayName: name),
            category: category,
          );
      final exact = entry('mandelbrot', 'Mandelbrot', 'Escape-Time');
      final prefix =
          entry('mandelbrot_cubic', 'Mandelbrot Cubic', 'Escape-Time');
      final metadata = entry('unrelated', 'Unrelated', 'Mandelbrot Studies');

      final result = CatalogFilter.apply(
        entries: [metadata, prefix, exact],
        criteria: const CatalogFilterCriteria(query: 'Mandelbrot'),
        l10n: l10n,
      );

      expect(result.filteredEntries, [exact, prefix, metadata]);
    });
  });
}
