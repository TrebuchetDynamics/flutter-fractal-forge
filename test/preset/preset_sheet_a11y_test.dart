import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/overflow_guard.dart';

/// Pumps the sheet with one saved preset, so the user-preset chip and its
/// embedded rename/delete actions are in the tree.
Future<void> _pumpSheet(
  WidgetTester tester, {
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final controller = FractalController(ModuleRegistry());
  addTearDown(controller.dispose);
  final store = await PresetStore.create();
  await store.saveUserPreset(FractalPreset(
    id: 'a11y-saved',
    moduleId: controller.module.id,
    name: 'Saved One',
    params: Map<String, Object>.from(controller.params),
    view: controller.view,
    createdAt: DateTime(2026),
  ));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        Provider.value(value: store),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: PresetSheet()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PresetSheet accessibility', () {
    testWidgets('text meets the AA contrast ratio', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('every control meets the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every control is named', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSheet(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // Overflow here is caught by hand rather than via takeException, because
    // the loading row that overflowed is disposed once the preset future
    // resolves — pumpAndSettle throws it away before an assertion could see it.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await expectNoOverflow(
            () => _pumpSheet(tester, textScale: scale),
            reason: '$scale x on $size',
          );
        });
      }
    }
  });
}
