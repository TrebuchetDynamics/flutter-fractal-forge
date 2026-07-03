import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('GPU health probe does not mutate live controller params',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    final presetStore = await PresetStore.create();
    final rendererSettings =
        RendererSettingsService(await SharedPreferences.getInstance());

    final originalIterations = controller.params['iterations'];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          ChangeNotifierProvider.value(value: rendererSettings),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FractalViewerScreen(),
        ),
      ),
    );

    // Allow initial build.
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Advance time so the 2s GPU health timer fires.
    await tester.pump(const Duration(seconds: 5));

    // Allow async work (toImage/byteData) to complete.
    await tester.pump(const Duration(seconds: 1));

    // Probe must not touch controller params (no transient iteration bumps).
    expect(controller.params['iterations'], originalIterations);

    expect(tester.takeException(), isNull);
  });
}
