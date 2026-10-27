import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/settings/settings_screen.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreen(WidgetTester tester, Widget screen,
      RendererSettingsService settings) async {
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    final presets = await PresetStore.create();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider.value(value: registry),
        Provider.value(value: presets),
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Settings debug switch is off by default and persists changes',
      (tester) async {
    final settings = await RendererSettingsService.create();
    addTearDown(settings.dispose);
    await pumpScreen(tester, const SettingsScreen(), settings);
    final toggle = find.byKey(const Key('settingsDebugModeSwitch'));
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    final restored = await RendererSettingsService.create();
    addTearDown(restored.dispose);
    expect(restored.debugModeEnabled, isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final disabled = await RendererSettingsService.create();
    addTearDown(disabled.dispose);
    expect(disabled.debugModeEnabled, isFalse);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform report action follows debug mode and opens form',
        (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final settings = await RendererSettingsService.create();
      addTearDown(settings.dispose);
      await pumpScreen(tester,
          const FractalViewerScreen(restoreViewerSession: false), settings);
      final report = find.byKey(const ValueKey('viewerReportFractalFab'));
      expect(report, findsNothing);
      await settings.setDebugModeEnabled(true);
      await tester.pumpAndSettle();
      expect(report, findsOneWidget);
      await tester.tap(report);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      Navigator.of(tester.element(find.byType(TextField))).pop();
      await tester.pumpAndSettle();
      await settings.setDebugModeEnabled(false);
      await tester.pumpAndSettle();
      expect(report, findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('Linux keeps its report action with debug mode off',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final settings = await RendererSettingsService.create();
    addTearDown(settings.dispose);
    await pumpScreen(tester,
        const FractalViewerScreen(restoreViewerSession: false), settings);
    expect(
        find.byKey(const ValueKey('viewerReportFractalFab')), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
