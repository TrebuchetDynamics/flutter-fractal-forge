import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> openTools(WidgetTester tester) async {
    final more = find.byKey(const ValueKey('viewerOverflowMenu'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
  }

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
      await openTools(tester);
      expect(report, findsNothing);
      Navigator.of(
              tester.element(find.byKey(const ValueKey('viewerOverflowMenu'))))
          .pop();
      await tester.pumpAndSettle();
      await settings.setDebugModeEnabled(true);
      await tester.pumpAndSettle();
      await openTools(tester);
      expect(report, findsOneWidget);
      await tester.ensureVisible(report);
      await tester.pumpAndSettle();
      await tester.tap(report);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      Navigator.of(tester.element(find.byType(TextField))).pop();
      await tester.pumpAndSettle();
      await settings.setDebugModeEnabled(false);
      await tester.pumpAndSettle();
      await openTools(tester);
      expect(report, findsNothing);
      Navigator.of(
              tester.element(find.byKey(const ValueKey('viewerOverflowMenu'))))
          .pop();
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('Android copies the labelled AI report directly from its preview',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final settings = await RendererSettingsService.create();
    addTearDown(settings.dispose);
    await settings.setDebugModeEnabled(true);
    await pumpScreen(tester,
        const FractalViewerScreen(restoreViewerSession: false), settings);
    await openTools(tester);
    final report = find.byKey(const ValueKey('viewerReportFractalFab'));
    await tester.ensureVisible(report);
    await tester.pumpAndSettle();
    final controller = tester.element(report).read<FractalController>();
    final originalZoom = controller.view.zoom;
    await tester.tap(report);
    await tester.pumpAndSettle();
    final copy = find.widgetWithText(FilledButton, 'Copy');
    expect(copy, findsOneWidget);
    expect(find.text('Save report'), findsNothing);
    expect(tester.widget<FilledButton>(copy).onPressed, isNull);
    controller.updateZoom(originalZoom * 2);
    await tester.enterText(find.byType(TextField), 'Improve deep zoom detail');
    final tag = find.text('Weak deep zoom');
    await tester.ensureVisible(tag);
    await tester.tap(tag);
    await tester.pumpAndSettle();
    final preview = find.byKey(const Key('fractalReportPreview'));
    final text = tester.widget<SelectableText>(preview).data!;
    expect(text, contains('fix or improve'));
    expect(text, contains('mandelbrot'));
    expect(text, contains('Weak deep zoom'));
    expect(text, contains('Improve deep zoom detail'));
    expect(text, contains('rendererStatus'));
    expect(text, contains('"zoom": $originalZoom'));
    expect(controller.view.zoom, originalZoom * 2);
    await tester.tap(tag);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(copy).onPressed, isNull);
    await tester.tap(tag);
    await tester.pumpAndSettle();
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(clipboard, text);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Copy report JSON'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Linux keeps its report action with debug mode off',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final settings = await RendererSettingsService.create();
    addTearDown(settings.dispose);
    await pumpScreen(tester,
        const FractalViewerScreen(restoreViewerSession: false), settings);
    await openTools(tester);
    final report = find.byKey(const ValueKey('viewerReportFractalFab'));
    expect(report, findsOneWidget);
    await tester.ensureVisible(report);
    await tester.pumpAndSettle();
    await tester.tap(report);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Save report'), findsOneWidget);
    expect(find.byKey(const Key('fractalReportPreview')), findsNothing);
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });
}
