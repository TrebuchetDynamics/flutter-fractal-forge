import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/performance_fractal_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

FractalModule _module(String id) {
  return FractalModule(
    id: id,
    displayName: (_) => id,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/$id.frag',
    parameters: const [],
    defaultPreset: FractalPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Default',
      params: const {},
      view: FractalViewState.initial(),
      createdAt: DateTime(2026),
      isBuiltIn: true,
    ),
    builtInPresets: const [],
    setUniforms: (_, __, ___, ____) {},
  );
}

void main() {
  group('CatalogRepository family seams', () {
    test('has a dedicated empty builder for future Performance Fractals', () {
      expect(PerformanceFractalCatalog.family, CatalogFamily.performance);
      expect(PerformanceFractalCatalog.category, performanceFractalsCategory);
      expect(PerformanceFractalCatalog.buildModules(), isEmpty);
    });

    test('keeps Performance Fractals out of core catalog IDs', () {
      final shared = _module('pulse_feedback');
      final repository = CatalogRepository.fromFamilies(
        coreModules: [_module('mandelbrot'), shared],
        performanceModules: [shared],
      );

      expect(
        repository.entries.map((entry) => entry.catalogId),
        ['core.mandelbrot', 'performance.pulse_feedback'],
      );
      final coreCategories = repository.entries
          .where((entry) => entry.family == CatalogFamily.core)
          .map((entry) => entry.category);
      expect(coreCategories, isNot(contains(performanceFractalsCategory)));
    });

    test('assigns dedicated metadata to Performance Fractals', () {
      final repository = CatalogRepository.fromFamilies(
        coreModules: [_module('mandelbrot')],
        performanceModules: [_module('pulse_feedback')],
      );

      final performanceEntry =
          repository.byCatalogId('performance.pulse_feedback');
      expect(performanceEntry.family, CatalogFamily.performance);
      expect(performanceEntry.category, performanceFractalsCategory);
      expect(performanceEntry.catalogId, startsWith('performance.'));
    });
  });
}
