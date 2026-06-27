import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'a11y/shared/permission_test_harness.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

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
      installDenyAllPermissionsHandler();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());
      historyStore = await HistoryStore.create();
      historyProvider = HistoryProvider(store: historyStore);
    });

    tearDown(() {
      historyProvider.dispose();
      controller.dispose();
      rendererSettings.dispose();
    });

    Widget buildTestWidget({
      CatalogFamily catalogFamily = CatalogFamily.core,
    }) {
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
          home: FractalViewerScreen(catalogFamily: catalogFamily),
        ),
      );
    }

    testWidgets('displays current module name in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('does not show renderer status chip', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);
      expect(find.byKey(const Key('viewerStatusChipText')), findsNothing);
    });

    testWidgets('back FAB is not shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('fullscreen FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Fullscreen view'), findsOneWidget);
    });

    testWidgets('fractal music FAB is immediately visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final music = find.byKey(const ValueKey('viewerFractalMusicButton'));
      expect(music, findsOneWidget);
      final rect = tester.getRect(music);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(600));
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('FAB column stays on-screen and scrolls on short viewports',
        (tester) async {
      // Simulate a short viewport (e.g. landscape phone / small web window)
      // where the stacked FAB column is taller than the available height.
      tester.view.physicalSize = const Size(400, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The stacked column must not overflow its parent.
      expect(tester.takeException(), isNull);

      // The top-most quick-control FAB must stay within the viewport instead of
      // being pushed above the top edge (the pre-fix overflow symptom).
      final fullscreen = find.byKey(const ValueKey('viewerFullscreenButton'));
      expect(fullscreen, findsOneWidget);
      expect(tester.getRect(fullscreen).top, greaterThanOrEqualTo(0.0),
          reason: 'top FAB was pushed off the top of the viewport');

      // The scroll container is height-bounded (so it can actually scroll)
      // rather than expanding to its full natural content height.
      final column = find.byKey(const ValueKey('viewerFabColumn'));
      expect(column, findsOneWidget);
      expect(tester.getSize(column).height, lessThan(360.0),
          reason: 'FAB column is unbounded and cannot scroll');
    });

    testWidgets('random fractal FAB switches module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, equals('mandelbrot'));

      final randomButton = find.byKey(const ValueKey('viewerRandomButton'));
      await tester.ensureVisible(randomButton);
      await tester.pumpAndSettle();
      await tester.tap(randomButton);
      await tester.pumpAndSettle();

      expect(controller.module.id, isNot(equals('mandelbrot')));

      // Let delayed FAB fade-in timers complete before teardown.
      await tester.pump(const Duration(milliseconds: 400));

      // Drain/cancel pending history debounce timer to keep test harness clean.
      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('camera FAB is not shown (feature removed)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_rounded), findsNothing);
    });

    testWidgets('fullscreen FAB collapses controls and restores them',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Fullscreen view'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);

      await tester.tap(find.byTooltip('Fullscreen view'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Exit fullscreen view'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);

      await tester.tap(find.byTooltip('Exit fullscreen view'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byKey(const Key('viewerStatusChip')), findsNothing);
    });

    testWidgets('export FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('viewerExportButton')), findsOneWidget);
    });

    testWidgets('performance family route hides core viewer chrome',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(catalogFamily: CatalogFamily.performance),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
      expect(find.byKey(const ValueKey('viewerRandomButton')), findsNothing);
      expect(
          find.byKey(const ValueKey('viewerRandomParamsButton')), findsNothing);
      expect(
          find.byKey(const ValueKey('viewerFractalMusicButton')), findsNothing);
      expect(find.byTooltip('Controls'), findsNothing);
      expect(find.text('Mandelbrot'), findsNothing);

      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
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

    testWidgets('controls FAB is shown', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Controls'), findsOneWidget);
    });

    testWidgets('controls FAB opens controls sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Controls'));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
    });

    testWidgets('keyboard arrow keys pan view', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialX = controller.view.pan.x;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.pan.x, greaterThan(initialX));
    });

    testWidgets('keyboard plus and minus keys adjust zoom', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialZoom = controller.view.zoom;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.equal);
      await tester.pump();
      final zoomedIn = controller.view.zoom;

      expect(zoomedIn, greaterThan(initialZoom));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.minus);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.zoom, lessThan(zoomedIn));
    });

    testWidgets('keyboard R resets view state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      controller.updatePan(Vector2(0.5, -0.25));
      controller.updateZoom(4.0);
      await tester.pump();

      expect(controller.view.zoom, equals(4.0));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(controller.view.zoom, equals(1.0));
      expect(controller.view.pan.x, equals(0.0));
      expect(controller.view.pan.y, equals(0.0));
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

        // Basic sanity: the screen should build and not throw.
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Avoid long-running debounce carryover between module swaps.
        historyProvider.cancelPendingRecord();
      }

      // Ensure pending async work is drained before teardown.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      historyProvider.cancelPendingRecord();
    });
  });
}
