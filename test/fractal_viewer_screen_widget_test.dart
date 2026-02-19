import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/ar/ar_overlay_screen.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

class _DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return {
      for (final permission in permissions) permission: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

void main() {
  group('FractalViewerScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late RendererSettingsService rendererSettings;
    late HistoryStore historyStore;
    late HistoryProvider historyProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
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

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          Provider.value(value: arQualityStore),
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

    testWidgets('shows render status chip for clarity', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('viewerStatusChip')), findsOneWidget);
      final statusText = tester.widget<Text>(
        find.byKey(const Key('viewerStatusChipText')),
      );
      expect(statusText.data, contains('z='));
      expect(statusText.data, contains('it='));
    });

    testWidgets('back button includes tooltip for accessibility',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('bookmark button is present in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Save location'), findsOneWidget);
    });

    testWidgets('random fractal FAB is present and switches module',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final randomFab = find.byIcon(Icons.shuffle_rounded);
      expect(randomFab, findsOneWidget);
      expect(controller.module.id, equals('mandelbrot'));

      await tester.tap(randomFab);
      await tester.pumpAndSettle();

      expect(controller.module.id, isNot(equals('mandelbrot')));

      // Let delayed FAB fade-in timers complete before teardown.
      await tester.pump(const Duration(milliseconds: 400));

      // Drain/cancel pending history debounce timer to keep test harness clean.
      historyProvider.cancelPendingRecord();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('AR FAB is present for quick access', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_rounded), findsOneWidget);
    });

    testWidgets('AR launch falls back to overlay screen safely',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ArOverlayScreen), findsOneWidget);
      expect(find.byIcon(Icons.no_photography), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping bookmark button saves a preset and shows snackbar',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify no presets exist yet.
      final before = await presetStore.loadUserPresets('mandelbrot');
      expect(before, isEmpty);

      // Tap the bookmark button.
      await tester.tap(find.byTooltip('Save location'));
      await tester.pumpAndSettle();

      // SnackBar should appear with bookmark_added icon.
      expect(find.byIcon(Icons.bookmark_added_rounded), findsOneWidget);

      // A preset should be saved.
      final after = await presetStore.loadUserPresets('mandelbrot');
      expect(after.length, equals(1));
      expect(after.first.name, contains('Mandelbrot'));
      expect(after.first.name, contains('×'));
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
