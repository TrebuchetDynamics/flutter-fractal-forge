import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PresetSheet', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
    });

    Widget buildTestWidget() {
      return MultiProvider(
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
      );
    }

    testWidgets('displays Presets title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsOneWidget);
    });

    testWidgets('displays Save Preset section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Save Preset'), findsWidgets);
    });

    testWidgets('displays preset name text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter preset name'), findsOneWidget);
    });

    testWidgets('save button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final saveButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('savePresetButton')),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('save button is enabled when name is provided', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My Preset');
      await tester.pumpAndSettle();

      final saveButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('savePresetButton')),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('displays Built-in Presets section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Built-in Presets'), findsOneWidget);
    });

    testWidgets('displays User Presets section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('User Presets'), findsOneWidget);
    });

    testWidgets('shows empty state for user presets initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No saved presets yet.'), findsOneWidget);
    });

    testWidgets('displays built-in preset chips', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Mandelbrot has Default, Classic, Soft Glow, Psychedelic presets
      expect(find.byType(ActionChip), findsWidgets);
    });

    testWidgets('displays Default preset', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('displays Classic preset', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Classic'), findsOneWidget);
    });

    testWidgets('displays Soft Glow preset', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Soft Glow'), findsOneWidget);
    });

    testWidgets('displays Psychedelic preset', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Psychedelic'), findsOneWidget);
    });

    testWidgets('tapping built-in preset applies it', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initial state
      expect(controller.params['iterations'], 120);

      await tester.tap(find.text('Psychedelic'));
      await tester.pumpAndSettle();

      // Psychedelic preset has different iterations
      expect(controller.params['iterations'], 260);
    });

    testWidgets('saving a preset adds it to user presets', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My Test Preset');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('savePresetButton')));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Preset saved!'), findsOneWidget);
    });

    testWidgets('saving preset clears the text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My Test Preset');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('savePresetButton')));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('saved preset appears in user presets list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Custom Preset');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('savePresetButton')));
      await tester.pumpAndSettle();

      // Find the saved preset in user presets
      expect(find.text('Custom Preset'), findsOneWidget);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('works with Julia module', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsOneWidget);
      expect(find.byType(ActionChip), findsWidgets);
    });

    testWidgets('text field has outlined border', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration;
      expect(decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('built-in presets are tappable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final chips = find.byType(ActionChip);
      expect(chips, findsWidgets);

      // Each should be tappable
      for (int i = 0; i < 3; i++) {
        final chip = tester.widget<ActionChip>(chips.at(i));
        expect(chip.onPressed, isNotNull);
      }
    });

    testWidgets('preset chips are wrapped in Wrap widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsWidgets);
    });
  });
}
