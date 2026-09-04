import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  CatalogEntry entry({
    required String id,
    required String name,
    required FractalDimension dimension,
    required String category,
    List<String> aliases = const [],
    List<FractalParameter> parameters = const [],
    void Function()? onNameRead,
  }) {
    final module = FractalModule(
      id: id,
      displayName: (_) {
        onNameRead?.call();
        return name;
      },
      dimension: dimension,
      shaderAsset: 'unused.frag',
      parameters: parameters,
      defaultPreset: FractalPreset(
        id: '$id.default',
        moduleId: id,
        name: 'Default',
        params: const {},
        view: FractalViewState.initial(),
        createdAt: DateTime(2026),
      ),
      builtInPresets: const [],
      setUniforms: (shader, state, size, time) {},
    );

    return CatalogEntry(
      catalogId: 'core.$id',
      module: module,
      category: category,
      aliases: aliases,
    );
  }

  final entries = [
    entry(
      id: 'mandelbrot',
      name: 'Mandelbrot',
      dimension: FractalDimension.twoD,
      category: 'Escape-Time',
      aliases: ['classic'],
      parameters: [
        FractalParameter(
          id: 'bailout',
          label: (l10n) => l10n.paramBailout,
          type: FractalParamType.float,
          min: 2,
          max: 16,
          step: 0.5,
          defaultValue: 4.0,
        ),
      ],
    ),
    entry(
      id: 'julia',
      name: 'Julia',
      dimension: FractalDimension.twoD,
      category: 'Escape-Time',
    ),
    entry(
      id: 'mandelbulb',
      name: 'Mandelbulb',
      dimension: FractalDimension.threeD,
      category: '3D Fractals',
    ),
    entry(
      id: 'levy_c_curve',
      name: 'Lévy C Curve',
      dimension: FractalDimension.twoD,
      category: 'Other',
    ),
    entry(
      id: 'mirror',
      name: 'Mirror',
      dimension: FractalDimension.twoD,
      category: 'Kaleidoscopes',
    ),
  ];

  group('CatalogFilter.apply', () {
    test('broad search evaluates localized names at most twice per entry', () {
      var nameReads = 0;
      final manyEntries = List.generate(
        256,
        (i) => entry(
          id: 'fractal_$i',
          name: 'Fractal ${255 - i}',
          dimension: FractalDimension.twoD,
          category: 'Other',
          onNameRead: () => nameReads++,
        ),
      );
      final result = CatalogFilter.apply(
        entries: manyEntries,
        criteria: const CatalogFilterCriteria(query: 'fractal'),
        l10n: l10n,
      );
      expect(result.filteredEntries, hasLength(256));
      expect(nameReads, lessThanOrEqualTo(2 * manyEntries.length));
      expect(result.filteredEntries.first.catalogId, 'core.fractal_255');
    });

    test('matches all query words across name, dimension, alias and parameters',
        () {
      for (final query in ['3D mandelbulb', 'mandelbulb 3D']) {
        final result = CatalogFilter.apply(
          entries: entries,
          criteria: CatalogFilterCriteria(query: query),
          l10n: l10n,
        );
        expect(result.filteredEntries.map((entry) => entry.catalogId),
            ['core.mandelbulb']);
        expect(result.countForDimension(CatalogDimensionFilter.threeD), 1);
        expect(result.categoryCounts, {'3D Fractals': 1});
      }
      final result = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(query: 'classic bailout 2D'),
        l10n: l10n,
      );
      expect(result.filteredEntries.map((entry) => entry.catalogId),
          ['core.mandelbrot']);
      expect(
        CatalogFilter.apply(
          entries: entries,
          criteria: const CatalogFilterCriteria(query: 'mandelbulb 2D'),
          l10n: l10n,
        ).filteredEntries,
        isEmpty,
      );
    });

    test('filters cards, dimension counts, and category counts from one query',
        () {
      final result = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(query: 'core.julia'),
        l10n: l10n,
      );

      expect(result.filteredEntries.map((entry) => entry.catalogId), [
        'core.julia',
      ]);
      expect(result.countForDimension(CatalogDimensionFilter.all), 1);
      expect(result.countForDimension(CatalogDimensionFilter.twoD), 1);
      expect(result.countForDimension(CatalogDimensionFilter.threeD), 0);
      expect(result.categoryCounts, {'Escape-Time': 1});
      expect(result.sortedCategories, ['Escape-Time']);
    });

    test('searches math parameter labels', () {
      final result = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(query: 'bailout'),
        l10n: l10n,
      );

      expect(result.filteredEntries.map((entry) => entry.catalogId), [
        'core.mandelbrot',
      ]);
    });

    test('complete phrases outrank words spread across metadata', () {
      final rankedEntries = [
        entry(
            id: 'cross_field',
            name: 'Mandelbulb',
            dimension: FractalDimension.threeD,
            category: 'Other'),
        entry(
            id: 'metadata_phrase',
            name: 'Study',
            dimension: FractalDimension.threeD,
            category: '3D Mandelbulb Studies'),
        entry(
            id: 'unordered_name',
            name: 'Mandelbulb 3D',
            dimension: FractalDimension.threeD,
            category: 'Other'),
        entry(
            id: 'prefix',
            name: '3D Mandelbulb Slice',
            dimension: FractalDimension.threeD,
            category: 'Other'),
        entry(
            id: 'exact',
            name: '3D Mandelbulb',
            dimension: FractalDimension.threeD,
            category: 'Other'),
      ];
      final result = CatalogFilter.apply(
        entries: rankedEntries,
        criteria: const CatalogFilterCriteria(query: '3D Mandelbulb'),
        l10n: l10n,
      );
      expect(result.filteredEntries, orderedEquals(rankedEntries.reversed));
    });

    test('search ignores accents and ranks unordered name tokens', () {
      final accentResult = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(query: 'levy'),
        l10n: l10n,
      );
      final tokenResult = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(query: 'curve levy'),
        l10n: l10n,
      );

      expect(
          accentResult.filteredEntries.single.catalogId, 'core.levy_c_curve');
      expect(tokenResult.filteredEntries.single.catalogId, 'core.levy_c_curve');
    });

    test('keeps selected category visible even when current dimension hides it',
        () {
      final result = CatalogFilter.apply(
        entries: entries,
        criteria: const CatalogFilterCriteria(
          query: '',
          dimensionFilter: CatalogDimensionFilter.twoD,
          selectedCategory: '3D Fractals',
        ),
        l10n: l10n,
      );

      expect(result.filteredEntries, isEmpty);
      expect(result.categoryCounts.containsKey('3D Fractals'), isFalse);
      expect(result.sortedCategories.first, '3D Fractals');
      expect(result.countForDimension(CatalogDimensionFilter.all), 1);
      expect(result.countForDimension(CatalogDimensionFilter.threeD), 1);
    });
  });
}
