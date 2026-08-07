import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exhaustive viewer walkthrough: every module in the live [ModuleRegistry]
/// (escape-time catalog, raymarched 3D, custom, and debug diagnostics) must
/// open in the real [FractalViewerScreen] widget tree without throwing.
///
/// This replaces the skip-gated placeholder that used to live in
/// `integration_test/catalog/every_fractal_programmatic_test.dart`. It is a
/// fast widget-level sweep (no device, no GPU required) so the whole catalog
/// stays covered on every CI run.
void main() {
  testWidgets('every registered module opens in the viewer without crashing',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final registry = ModuleRegistry();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();

    final failures = <String>[];
    final modules = registry.modules;

    for (final module in modules) {
            final controller = FractalController(registry);
      controller.selectModule(module, animate: false);

      await tester.pumpWidget(
        MultiProvider(
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
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      final exception = tester.takeException();
      if (exception != null) {
        failures.add('${module.id}: threw $exception');
      }
      if (find.byKey(const Key('fractalViewerRoot')).evaluate().isEmpty) {
        failures.add('${module.id}: viewer root key missing');
      }

      controller.dispose();
      // Tear the previous tree down before the next module.
      await tester.pumpWidget(const SizedBox.shrink());
    }

    if (failures.isNotEmpty) {
      fail('${failures.length}/${modules.length} modules failed the viewer '
          'walkthrough:\n${failures.take(50).join('\n')}');
    }
  });
}
