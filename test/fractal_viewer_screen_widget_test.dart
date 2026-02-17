import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FractalViewerScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late RendererSettingsService rendererSettings;
    late HistoryStore historyStore;
    late HistoryProvider historyProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings = RendererSettingsService(await SharedPreferences.getInstance());
      historyStore = await HistoryStore.create();
      historyProvider = HistoryProvider(store: historyStore);
    });

    tearDown(() {
      historyProvider.dispose();
      controller.dispose();
      rendererSettings.dispose();
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          ChangeNotifierProvider.value(value: rendererSettings),
          ChangeNotifierProvider.value(value: historyProvider),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FractalViewerScreen(),
        ),
      );
    }

    testWidgets('displays current module name in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('displays fractal renderer surface', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Test surface is rendered in test mode
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('updates title when module changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays Julia module correctly', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays Burning Ship module correctly', (tester) async {
      controller.selectModule(registry.byId('burning_ship'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
    });

    testWidgets('displays Phoenix module correctly', (tester) async {
      controller.selectModule(registry.byId('phoenix'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phoenix'), findsOneWidget);
    });

    testWidgets('displays Mandelbulb module correctly', (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('has scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('history back button restores previous module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Give history debounce time to record initial location.
      await tester.pump(const Duration(milliseconds: 700));

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Julia'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('works with all modules', (tester) async {
      // Many screens include continuous animations (shader time, UI pulses, etc.).
      // `pumpAndSettle` can therefore time out even when the UI is correct.
      // For this smoke test we only need a couple of frames.
      for (final module in registry.modules) {
        controller.selectModule(module);
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        // Basic sanity: the screen should build and not throw.
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
