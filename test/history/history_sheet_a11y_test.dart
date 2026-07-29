import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/overflow_guard.dart';

/// Pumps the sheet with one recorded location and one favourite, so the entry
/// tiles, count badges and the position label are all present.
Future<void> _pumpSheet(
  WidgetTester tester, {
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final registry = ModuleRegistry();
  final controller = FractalController(registry);
  addTearDown(controller.dispose);
  final provider = HistoryProvider(store: await HistoryStore.create());
  addTearDown(provider.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: registry),
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: provider),
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
        home: const Scaffold(body: HistorySheet()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // recordLocation debounces through a Timer, so the fake clock has to be
  // pumped past the delay rather than awaited.
  provider.recordLocation(
    moduleId: controller.module.id,
    view: controller.view,
    params: Map<String, Object>.from(controller.params),
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
  provider.saveCurrentAsFavorite('Favourite One');
  await tester.pumpAndSettle();
}

void main() {
  group('HistorySheet accessibility', () {
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

    testWidgets('the tab body keeps height at a 3x text scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpSheet(tester, textScale: 3.0);

      // The header is a fixed child of the sheet's Column, so an unbounded one
      // takes its space from the tab body instead of scrolling. Uncapped it
      // reached 412px inside a 341px sheet and the body collapsed to zero,
      // hiding every entry until the sheet was dragged taller.
      expect(
        tester.getSize(find.byType(TabBarView).first).height,
        greaterThan(0),
        reason: 'tab body collapsed to nothing',
      );
    });
  });
}
