/// Dedicated VIS-004 first-view coverage for Newton z³.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late PresetStore presetStore;
  late AccessibilityService accessibilityService;
  late RendererSettingsService rendererSettingsService;

  setUp(() async {
    binding.platformDispatcher.semanticsEnabledTestValue = false;
    SharedPreferences.setMockInitialValues({});
    presetStore = await PresetStore.create();
    accessibilityService = await AccessibilityService.create();
    rendererSettingsService = await RendererSettingsService.create();
  });

  testWidgets(
    'Newton Fractal (z³ − 1) Explore launch shows configured first view',
    (tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      await enterCatalogSearch(tester, 'Newton Fractal');
      final moduleCard = catalogModuleCard('core.newton_z3');
      expect(moduleCard, findsOneWidget);
      await tester.ensureVisible(moduleCard);
      await tester.pumpAndSettle(const Duration(milliseconds: 80));
      await tester.tap(moduleCard);

      final renderer = find.byType(FractalRenderer);
      LogEntry? firstFrame;
      for (var frame = 0; frame < 600 && firstFrame == null; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        for (final entry in AppLogger.instance.entries.reversed) {
          if (entry.category == 'perf' &&
              entry.message == 'gpu_first_frame' &&
              entry.data?['module'] == 'newton_z3') {
            firstFrame = entry;
            break;
          }
        }
      }
      expect(firstFrame, isNotNull,
          reason: 'Newton GPU first frame was not logged');
      expect(firstFrame!.data?['backend'], 'gpu');
      expect(renderer, findsOneWidget);
      final controller = Provider.of<FractalController>(
        tester.element(renderer),
        listen: false,
      );

      // gpu_first_frame is emitted from the GPU renderer's first frame builder;
      // read the controller immediately after that frame, not after a delay.
      expect(controller.module.id, 'newton_z3');
      expect(controller.params['relaxation'], 1.0);
      expect(controller.view.pan.x, closeTo(-0.41568627450980394, 1e-9));
      expect(controller.view.pan.y, closeTo(-0.05411764705882354, 1e-9));
      expect(controller.view.zoom, closeTo(1.4688235294117646, 1e-9));

      while (true) {
        final error = tester.takeException();
        if (error == null) break;
        final message = error.toString();
        if (message.contains('Invalid SkSL') ||
            message.contains("operator '%' is not allowed")) {
          continue;
        }
        fail('Unexpected Flutter exception: $error');
      }
    },
    skip: RuntimeModeService.useRendererPlaceholderSurface,
  );
}
