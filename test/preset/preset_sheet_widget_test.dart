import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PresetSheet exposes batch export only with a callback',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = FractalController(ModuleRegistry());
    final store = await PresetStore.create();
    addTearDown(controller.dispose);
    var calls = 0;

    Future<void> pumpSheet(VoidCallback? onBatchExport) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
            Provider.value(value: store),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PresetSheet(onBatchExport: onBatchExport)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final button = find.byKey(const ValueKey('presetBatchExportButton'));
    await pumpSheet(() => calls++);
    expect(button, findsOneWidget);
    expect(find.text('Export all presets'), findsOneWidget);
    await tester.tap(button);
    expect(calls, 1);

    await pumpSheet(null);
    expect(button, findsNothing);
  });

  testWidgets('PresetSheet renders empty state and accepts a name',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: await PresetStore.create()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PresetSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Presets'), findsOneWidget);
    expect(find.text('No saved presets yet.'), findsOneWidget);
    expect(find.text('Save Preset'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'My Preset');
    await tester.pump();

    expect(find.text('My Preset'), findsOneWidget);
  });

  testWidgets('PresetSheet reloads presets when the module changes',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    final presetStore = await PresetStore.create();
    addTearDown(controller.dispose);
    await presetStore.saveUserPreset(
      FractalPreset(
        id: 'mandelbrot-saved',
        moduleId: 'mandelbrot',
        name: 'Mandelbrot saved',
        params: Map<String, Object>.from(controller.params),
        view: controller.view,
        createdAt: DateTime(2026),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PresetSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mandelbrot saved'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('userPresetChip_mandelbrot-saved')),
      findsOneWidget,
    );

    controller.selectModule(registry.byId('julia'));
    await tester.pumpAndSettle();

    expect(find.text('Julia'), findsOneWidget);
    expect(find.text('Mandelbrot saved'), findsNothing);
    expect(find.text('No saved presets yet.'), findsOneWidget);
  });
}
