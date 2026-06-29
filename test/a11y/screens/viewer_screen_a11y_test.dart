import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/a11y_test_helpers.dart';

void main() {
  group('FractalViewerScreen accessibility', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: controller),
          Provider<ModuleRegistry>.value(value: registry),
          ChangeNotifierProvider<AccessibilityService>.value(
            value: accessibilityService,
          ),
          ChangeNotifierProvider<RendererSettingsService>.value(
            value: rendererSettingsService,
          ),
          Provider<ExplorationStatsService?>.value(value: null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const FractalViewerScreen(),
        ),
      );
    }

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });
  });
}
