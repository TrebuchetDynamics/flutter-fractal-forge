import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/catalog_screen_data.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogScreenDataBuilder', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    test('filters by normalized query across aliases, categories, and ids', () {
      final entries = [
        _catalogEntry(
          catalogId: 'core.mandelbrot',
          moduleId: 'mandelbrot',
          name: 'Mandelbrot',
          category: 'Escape Time',
          aliases: const ['classic set'],
        ),
        _catalogEntry(
          catalogId: 'core.lorenz',
          moduleId: 'lorenz',
          name: 'Lorenz',
          category: 'Attractors',
          aliases: const ['chaos flow'],
        ),
      ];
      final builder = CatalogScreenDataBuilder(entries: entries);

      expect(
        builder
            .build(l10n: l10n, searchQuery: '  CHAOS ')
            .filteredEntries
            .single
            .catalogId,
        'core.lorenz',
      );
      expect(
        builder
            .build(l10n: l10n, searchQuery: 'escape')
            .filteredEntries
            .single
            .catalogId,
        'core.mandelbrot',
      );
      expect(
        builder
            .build(l10n: l10n, searchQuery: 'CORE.MANDEL')
            .filteredEntries
            .single
            .catalogId,
        'core.mandelbrot',
      );
    });

    test('sorts sections by entry count and names within each section', () {
      final entries = [
        _catalogEntry(
          catalogId: 'core.zed',
          moduleId: 'zed',
          name: 'Zed',
          category: 'Beta',
        ),
        _catalogEntry(
          catalogId: 'core.beta',
          moduleId: 'beta',
          name: 'Beta',
          category: 'Alpha',
        ),
        _catalogEntry(
          catalogId: 'core.alpha',
          moduleId: 'alpha',
          name: 'Alpha',
          category: 'Alpha',
        ),
      ];
      final data = CatalogScreenDataBuilder(entries: entries).build(
        l10n: l10n,
        searchQuery: '',
      );

      expect(data.sections.map((section) => section.title), ['Alpha', 'Beta']);
      expect(
        data.sections.first.entries
            .map((entry) => entry.module.displayName(l10n)),
        ['Alpha', 'Beta'],
      );
    });

    test('collapses to one alphabetical section when requested', () {
      final entries = [
        _catalogEntry(
          catalogId: 'core.zed',
          moduleId: 'zed',
          name: 'Zed',
          category: 'Beta',
        ),
        _catalogEntry(
          catalogId: 'core.alpha',
          moduleId: 'alpha',
          name: 'Alpha',
          category: 'Omega',
        ),
      ];

      final data = CatalogScreenDataBuilder(entries: entries).build(
        l10n: l10n,
        searchQuery: '',
        sortOrder: CatalogSortOrder.alphabetical,
      );

      expect(data.sections, hasLength(1));
      expect(data.sections.single.title, l10n.catalogAllFractals);
      expect(
        data.sections.single.entries.map((entry) => entry.module.displayName(l10n)),
        ['Alpha', 'Zed'],
      );
    });

    test('preserves featured content only when no refinements are active', () {
      final entries = [
        _catalogEntry(
          catalogId: 'core.mandelbrot',
          moduleId: 'mandelbrot',
          name: 'Mandelbrot',
          category: 'Escape Time',
        ),
        _catalogEntry(
          catalogId: 'core.julia',
          moduleId: 'julia',
          name: 'Julia',
          category: 'Escape Time',
        ),
        _catalogEntry(
          catalogId: 'core.orbit',
          moduleId: 'orbit',
          name: 'Orbit',
          category: 'Attractors',
        ),
      ];
      final builder = CatalogScreenDataBuilder(entries: entries);

      final defaultData = builder.build(
        l10n: l10n,
        searchQuery: '',
      );
      final filteredData = builder.build(
        l10n: l10n,
        searchQuery: 'julia',
      );
      final alphabeticalData = builder.build(
        l10n: l10n,
        searchQuery: '',
        sortOrder: CatalogSortOrder.alphabetical,
      );

      expect(defaultData.showFeatured, isTrue);
      expect(
        defaultData.featuredEntries.map((entry) => entry.catalogId),
        ['core.mandelbrot', 'core.julia'],
      );
      expect(filteredData.showFeatured, isFalse);
      expect(alphabeticalData.showFeatured, isFalse);
    });

    test('adds stable variant suffixes when names are duplicated', () {
      final entries = [
        _catalogEntry(
          catalogId: 'core.alpha',
          moduleId: 'alpha',
          name: 'Nova',
          category: 'Escape Time',
        ),
        _catalogEntry(
          catalogId: 'core.beta',
          moduleId: 'beta',
          name: 'Nova',
          category: 'Escape Time',
          dimension: FractalDimension.threeD,
        ),
      ];
      final data = CatalogScreenDataBuilder(entries: entries).build(
        l10n: l10n,
        searchQuery: '',
      );

      expect(data.semanticLabelFor(entries.first), contains('Variant 1.'));
      expect(data.semanticLabelFor(entries.last), contains('Variant 2.'));
      expect(data.semanticLabelFor(entries.last), contains(l10n.dimension3d));
    });
  });
}

CatalogEntry _catalogEntry({
  required String catalogId,
  required String moduleId,
  required String name,
  required String category,
  FractalDimension dimension = FractalDimension.twoD,
  List<String> aliases = const <String>[],
}) {
  return CatalogEntry(
    catalogId: catalogId,
    category: category,
    aliases: aliases,
    module: FractalModule(
      id: moduleId,
      displayName: (_) => name,
      dimension: dimension,
      shaderAsset: 'shaders/$moduleId.frag',
      parameters: const [],
      defaultPreset: FractalPreset(
        id: '$moduleId-default',
        moduleId: moduleId,
        name: 'Default',
        params: const <String, Object>{},
        view: FractalViewState.initial(),
        createdAt: DateTime(2024),
      ),
      builtInPresets: const [],
      setUniforms: (shader, state, size, time) {},
    ),
  );
}
