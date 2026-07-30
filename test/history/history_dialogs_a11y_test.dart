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

/// Opens the history sheet with two recorded locations and no saved favourite,
/// which is the state that leaves every header button *enabled*.
///
/// This matters: a disabled button carries no tap semantics, so a tap-target
/// guideline passes over it silently. The earlier history audit ran with a
/// single entry and an already-favourited location, so all three header buttons
/// were disabled and their 40x40 size went unmeasured.
Future<void> _pumpWithEnabledHeader(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  SharedPreferences.setMockInitialValues({});
  final controller = FractalController(ModuleRegistry());
  addTearDown(controller.dispose);
  final provider = HistoryProvider(store: await HistoryStore.create());
  addTearDown(provider.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
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

  for (var i = 0; i < 2; i++) {
    controller.updateParam('iterations', 200 + i * 50);
    provider.recordLocation(
      moduleId: controller.module.id,
      view: controller.view,
      params: Map<String, Object>.from(controller.params),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('HistorySheet header with every button enabled', () {
    testWidgets('meets the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpWithEnabledHeader(tester);
      expect(find.byTooltip('Go back'), findsOneWidget,
          reason: 'harness did not reach the enabled state');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('is named and readable', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpWithEnabledHeader(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('save-favourite dialog', () {
    for (final scale in const [1.0, 2.0, 3.0]) {
      for (final size in const [Size(360, 640), Size(320, 568)]) {
        testWidgets('holds up at ${scale}x on $size', (tester) async {
          final handle = tester.ensureSemantics();
          await _pumpWithEnabledHeader(tester, textScale: scale, size: size);

          await expectNoOverflow(
            () async {
              await tester.tap(
                find.byTooltip('Save as favorite').first,
                warnIfMissed: false,
              );
              await tester.pumpAndSettle();
            },
            reason: 'save-favourite dialog at $scale x on $size',
          );

          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          handle.dispose();
        });
      }
    }
  });
}
