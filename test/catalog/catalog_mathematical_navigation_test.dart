import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SubsetRegistry extends ModuleRegistry {
  _SubsetRegistry(this._modules);
  final List<FractalModule> _modules;
  @override
  List<FractalModule> get modules => _modules;
}

void main() {
  final registry = ModuleRegistry();
  final julias = registry.modules
      .where((module) =>
          FractalMathematics.forModule(module).groupId == 'quadratic-julia')
      .take(2)
      .toList();

  test('search includes reviewed mathematical facets and formula', () {
    final entries = [
      for (final module in [julias.first, registry.byId('mandelbrot')])
        CatalogEntry(
            catalogId: 'core.${module.id}',
            module: module,
            category: 'Complex dynamics'),
    ];
    for (final query in ['complex dynamical', 'z(0) = pixel']) {
      final result = CatalogFilter.apply(
          entries: entries,
          criteria: CatalogFilterCriteria(query: query),
          l10n: AppLocalizationsEn());
      expect(result.filteredEntries.map((entry) => entry.catalogId),
          ['core.${julias.first.id}']);
    }
  });

  testWidgets('only verified recurrence members share a variant section',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final original = julias.first;
    final unreviewed = FractalModule(
      id: 'unreviewed_julia_renderer',
      displayName: (_) => 'Unreviewed sibling',
      dimension: original.dimension,
      shaderAsset: original.shaderAsset,
      parameters: original.parameters,
      defaultPreset: original.defaultPreset,
      builtInPresets: original.builtInPresets,
      setUniforms: original.setUniforms,
    );
    final modules = [...julias, unreviewed];
    final subset = _SubsetRegistry(modules);
    SharedPreferences.setMockInitialValues({
      'catalog_view_mode': CatalogViewMode.list.index,
      'catalog_browse_collection': '@favorites',
      'catalog_favorite_ids':
          modules.map((module) => 'core.${module.id}').toList(),
    });
    final controller = FractalController(subset);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<ModuleRegistry>.value(value: subset),
        ChangeNotifierProvider<FractalController>.value(value: controller)
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FractalCatalogScreen()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('catalogSectionHeader_complex_dynamics')),
        findsOneWidget);
    expect(
        find.text(
            'Complex dynamics · ${FractalMathematics.forModule(original).relationship}'),
        findsOneWidget);
    for (final module in modules) {
      expect(find.byKey(Key('catalogModuleCard_core.${module.id}')),
          findsOneWidget);
    }
    final summary =
        tester.widgetList<FractalMathSummary>(find.byType(FractalMathSummary));
    expect(summary, hasLength(3));
    expect(summary.every((widget) => widget.category == 'Complex dynamics'),
        isTrue);
    expect(tester.takeException(), isNull);
  });
}
