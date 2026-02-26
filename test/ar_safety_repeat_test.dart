import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return {
      for (final p in permissions) p: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

void main() {
  group('AR safety warning repeat behaviour', () {
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

    testWidgets('AR safety warning appears on first AR launch', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();

      expect(find.text('AR Safety Warning'), findsOneWidget);
    });

    testWidgets('AR safety warning appears on second AR launch (no SharedPreferences gate)',
        (tester) async {
      // First widget tree: launch AR, see warning, dismiss with Continue.
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();
      expect(find.text('AR Safety Warning'), findsOneWidget);
      // Dismiss by cancelling (Close) so no AR overlay is pushed; this keeps
      // the tree clean and avoids the ArOverlayScreen.dispose notifyListeners
      // bug that fires during framework teardown.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Second launch in the same session — warning MUST appear again.
      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('AR Safety Warning'),
        findsOneWidget,
        reason: 'AR safety warning must be shown on every launch per Families Policy',
      );

      // Clean up: dismiss before teardown.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('AR safety warning is not gated by SharedPreferences flag',
        (tester) async {
      // Pre-seed SharedPreferences with a hypothetical "already seen" key to
      // confirm the implementation does NOT read from prefs to suppress the
      // dialog (i.e., it always shows regardless of stored values).
      SharedPreferences.setMockInitialValues({
        'ar_safety_accepted': true,
        'ar_safety_shown': true,
        'arSafetyAccepted': true,
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('AR Safety Warning'),
        findsOneWidget,
        reason: 'AR safety warning must appear even when SharedPreferences '
            'contains a hypothetical previously-accepted flag',
      );
    });

    testWidgets('dismissing AR safety warning with Close does not open AR overlay',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_rounded));
      await tester.pumpAndSettle();

      expect(find.text('AR Safety Warning'), findsOneWidget);

      // Tap Close (cancel).
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog gone, no AR screen pushed.
      expect(find.text('AR Safety Warning'), findsNothing);
      // The viewer screen is still shown (no navigation happened).
      expect(find.byType(FractalViewerScreen), findsOneWidget);
    });
  });
}
