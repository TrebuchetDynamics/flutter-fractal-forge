import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Viewer AppBar buttons open Controls + Presets bottom sheets', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    final presetStore = await PresetStore.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FractalViewerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open Controls.
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Controls'), findsOneWidget);

    // Dismiss.
    final barrier = find.byType(ModalBarrier);
    if (barrier.evaluate().isNotEmpty) {
      await tester.tap(barrier.first);
      await tester.pumpAndSettle();
    }

    // Open Presets.
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();
    expect(find.text('Presets'), findsOneWidget);
  });
}
