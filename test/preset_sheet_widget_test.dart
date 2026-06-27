import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
