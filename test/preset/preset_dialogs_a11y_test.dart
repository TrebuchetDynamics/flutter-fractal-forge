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

/// A deliberately long preset name, since these dialogs interpolate it into
/// their title and body — a short name would not exercise the wrapping.
const _longName = 'A rather long saved preset name for testing';

Future<void> _pumpSheet(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
  bool largeTargets = false,
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  SharedPreferences.setMockInitialValues({});
  final controller = FractalController(ModuleRegistry());
  addTearDown(controller.dispose);
  final store = await PresetStore.create();
  await store.saveUserPreset(FractalPreset(
    id: 'dialog-saved',
    moduleId: controller.module.id,
    name: _longName,
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
        theme: largeTargets
            ? AppTheme.dark.copyWith(
                visualDensity: const VisualDensity(horizontal: 4, vertical: 4))
            : AppTheme.dark,
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
  testWidgets('preset rename keeps a 56px invisible target in large mode',
      (tester) async {
    await _pumpSheet(tester, largeTargets: true, size: const Size(320, 568));
    final rename = find.byTooltip('Rename preset').first;
    await tester.ensureVisible(rename);
    await tester.pumpAndSettle();
    final rect = tester.getRect(rename);
    expect(rect.width, greaterThanOrEqualTo(56));
    expect(rect.height, greaterThanOrEqualTo(56));
    await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('Rename Preset'), findsOneWidget);
    final cancel = find.widgetWithText(TextButton, 'Cancel');
    final cancelRect = tester.getRect(cancel);
    await tester.tapAt(Offset(cancelRect.center.dx, cancelRect.bottom - 1));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(_longName), findsOneWidget);
  });

  // A sheet's audit does not cover what the sheet opens. These dialogs were
  // checked for semantics but not layout until this file existed.
  for (final dialog in const {
    'delete': 'Delete preset',
    'rename': 'Rename preset',
  }.entries) {
    group('preset ${dialog.key} dialog', () {
      for (final scale in const [1.0, 2.0, 3.0]) {
        for (final size in const [Size(360, 640), Size(320, 568)]) {
          testWidgets('holds up at ${scale}x on $size', (tester) async {
            final handle = tester.ensureSemantics();
            await _pumpSheet(tester, textScale: scale, size: size);

            final button = find.byTooltip(dialog.value);
            expect(button, findsWidgets,
                reason: 'harness did not render the ${dialog.key} action');

            await expectNoOverflow(
              () async {
                await tester.tap(button.first, warnIfMissed: false);
                await tester.pumpAndSettle();
              },
              reason: '${dialog.key} dialog at $scale x on $size',
            );

            await expectLater(tester, meetsGuideline(textContrastGuideline));
            await expectLater(
                tester, meetsGuideline(androidTapTargetGuideline));
            await expectLater(
                tester, meetsGuideline(labeledTapTargetGuideline));
            handle.dispose();
          });
        }
      }
    });
  }
}
