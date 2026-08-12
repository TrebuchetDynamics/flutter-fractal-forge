import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/semantics/interactive_name_audit.dart';
import '../helpers/overflow_guard.dart';

Future<void> _pumpCatalog(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
  Locale locale = const Locale('en'),
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  SharedPreferences.setMockInitialValues({});
  final registry = ModuleRegistry();
  final controller = FractalController(registry);
  addTearDown(controller.dispose);
  final presetStore = await PresetStore.create();
  final rendererSettings =
      RendererSettingsService(await SharedPreferences.getInstance());
  addTearDown(rendererSettings.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: registry),
        ChangeNotifierProvider.value(value: controller),
        Provider.value(value: presetStore),
        ChangeNotifierProvider.value(value: rendererSettings),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: FractalCatalogScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('FractalCatalogScreen accessibility', () {
    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCatalog(tester);
      final root = semanticsRoot(tester);

      expect(operableControlNames(root), isNotEmpty,
          reason: 'the grid never rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      handle.dispose();
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCatalog(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('the search field is reachable and readable', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCatalog(tester);
      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();

      final root = semanticsRoot(tester);
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    // The repo's layout sweep in test/layout covers 375/428/768 at up to 2.0x.
    // The narrow widths and 3.0x below are where the sheets and the HUD broke,
    // so the catalogue is held to them too.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await expectNoOverflow(
            () => _pumpCatalog(tester, textScale: scale, size: size),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('card labels localize', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCatalog(tester, locale: const Locale('es'));
      final names = operableControlNames(semanticsRoot(tester));

      // Built inline in English before, so every one of the 430 cards announced
      // in English while the section headers around them localized correctly.
      expect(
        names.where((n) => n.startsWith('Fractal ')),
        isNotEmpty,
        reason: 'no Spanish card label found',
      );
      expect(
        names.where((n) => n.contains(' fractal, ')),
        isEmpty,
        reason: 'a card label is still English',
      );
      expect(
        names.where((n) => n.contains(' presets.')),
        isEmpty,
        reason: 'the inline English label is still in use',
      );
      // The platform appends its own activation instruction for a button, so
      // the label must not carry one of its own.
      expect(
        names.where(
            (n) => n.contains('Double tap') || n.contains('Toca dos veces')),
        isEmpty,
        reason: 'a label still spells out the activation gesture',
      );
      handle.dispose();
    });
  });
}
