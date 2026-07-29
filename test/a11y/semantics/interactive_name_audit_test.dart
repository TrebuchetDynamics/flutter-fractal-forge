import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/settings/accessibility_settings_screen.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fractal_controller_widget_harness.dart';
import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';
import 'interactive_name_audit.dart';

Future<void> settleChrome(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Asserts a surface exposes each control to a screen reader exactly once,
/// with a name, and that sliders say what they adjust.
void expectCleanSemantics(WidgetTester tester, String where) {
  final root = semanticsRoot(tester);

  expect(
    operableControlNames(root),
    isNotEmpty,
    reason: '$where exposed no operable controls — the tree never rendered, so '
        'the rest of this check would pass vacuously',
  );
  expect(
    findUnnamedControls(root).map((c) => c.toString()).toList(),
    isEmpty,
    reason: '$where has controls a screen reader cannot name',
  );
  expect(
    findStackedStops(root),
    isEmpty,
    reason: '$where announces one control as two stops over the same rect',
  );
  expect(
    findUnnamedSliders(root),
    isEmpty,
    reason: '$where has sliders that announce a value but not what it adjusts',
  );
}

void main() {
  test('semantics action bits match the audit mask', assertActionBitsUnchanged);

  testWidgets('app shell', (tester) async {
    final harness = MainAppA11yHarness();
    await harness.setUp();
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness.buildApp());
    await settleChrome(tester);
    expectCleanSemantics(tester, 'app-shell');
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  });

  testWidgets('onboarding', (tester) async {
    final harness = MainAppA11yHarness();
    await harness.setUp(forceOnboarding: true);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness.buildApp());
    await settleChrome(tester);
    expectCleanSemantics(tester, 'onboarding');
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  });

  testWidgets('viewer', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    final a11y = await AccessibilityService.create();
    final rendererSettings = await RendererSettingsService.create();

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<FractalController>.value(value: controller),
        Provider<ModuleRegistry>.value(value: registry),
        ChangeNotifierProvider<AccessibilityService>.value(value: a11y),
        ChangeNotifierProvider<RendererSettingsService>.value(
            value: rendererSettings),
        Provider<ExplorationStatsService?>.value(value: null),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const FractalViewerScreen(),
      ),
    ));
    await settleChrome(tester);
    expectCleanSemantics(tester, 'viewer');
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  });

  testWidgets('accessibility settings', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final a11y = await AccessibilityService.create();

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(ChangeNotifierProvider<AccessibilityService>.value(
      value: a11y,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const AccessibilitySettingsScreen(),
      ),
    ));
    await settleChrome(tester);
    expectCleanSemantics(tester, 'a11y-settings');
    handle.dispose();
    await disposeAccessibilityTestWidget(tester);
  });

  testWidgets('controls HUD', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final harness = FractalControllerWidgetHarness();
    addTearDown(harness.dispose);

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(harness.wrapScaffold(const FractalControlsHud()));
    await settleChrome(tester);
    await tester.tap(find.text('Kaleidoscope'));
    await settleChrome(tester);
    await tester.tap(find.text('Fluid mode'));
    await settleChrome(tester);
    expectCleanSemantics(tester, 'hud-expanded');
    handle.dispose();
  });
}
