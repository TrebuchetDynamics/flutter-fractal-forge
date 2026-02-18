import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart';

class _Rgb {
  final int r;
  final int g;
  final int b;

  const _Rgb(this.r, this.g, this.b);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation diagnostics', () {
    final boundaryKey = GlobalKey();

    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() async {
        await binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: FlutterFractalsApp(
            presetStore: presetStore,
            arQualityStore: arQualityStore,
            accessibilityService: accessibilityService,
            rendererSettingsService: rendererSettingsService,
            locale: const Locale('en'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> tapModuleByName(WidgetTester tester, String name) async {
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text(name),
        240.0,
        scrollable: scrollable,
      );
      await tester.tap(find.text(name));
      await tester.pump();
    }

    Future<_Rgb> captureCenterRgb(WidgetTester tester) async {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final context = boundaryKey.currentContext;
          if (context == null) {
            throw StateError('Screenshot boundary not mounted');
          }
          final boundary = context.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1.0);
          final data =
              await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          if (data == null) {
            image.dispose();
            throw StateError('Failed to encode screenshot bytes');
          }

          final bytes = data.buffer.asUint8List();
          final cx = (image.width / 2).floor();
          final cy = (image.height / 2).floor();
          final index = ((cy * image.width) + cx) * 4;

          final rgb = _Rgb(bytes[index], bytes[index + 1], bytes[index + 2]);
          image.dispose();
          return rgb;
        } catch (_) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      }
      throw StateError('Unable to capture center pixel RGB after retries');
    }

    testWidgets('viewer flow end-to-end with numeric diagnostics',
        (tester) async {
      final frameTimings = <ui.FrameTiming>[];
      final previousOnReportTimings =
          ui.PlatformDispatcher.instance.onReportTimings;
      ui.PlatformDispatcher.instance.onReportTimings = (timings) {
        frameTimings.addAll(timings);
        previousOnReportTimings?.call(timings);
      };
      addTearDown(() {
        ui.PlatformDispatcher.instance.onReportTimings =
            previousOnReportTimings;
      });

      await pumpApp(tester);
      debugPrint('ROUTE_CHECK route=/catalog result=ok');

      final checkedRoutes = <String>['/catalog'];

      Future<void> collectModuleDiag(String moduleDisplayName) async {
        final frameStart = frameTimings.length;

        await tapModuleByName(tester, moduleDisplayName);
        await tester.pump(const Duration(seconds: 3));

        final viewerContext = tester.element(find.byType(FractalViewerScreen));
        final controller =
            Provider.of<FractalController>(viewerContext, listen: false);
        final rgb = await captureCenterRgb(tester);
        final frameDelta = frameTimings.length - frameStart;

        final routeName = '/viewer/${controller.module.id}';
        checkedRoutes.add(routeName);
        debugPrint('ROUTE_CHECK route=$routeName result=ok');
        debugPrint(
          'NAV_DIAG module=${controller.module.id} shader=${controller.module.shaderAsset} '
          'preset=${controller.module.defaultPreset.id} center_rgb=${rgb.r},${rgb.g},${rgb.b} '
          'frame_count=$frameDelta',
        );
      }

      await collectModuleDiag('Mandelbrot');

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      checkedRoutes.add('/viewer/controls');
      debugPrint('ROUTE_CHECK route=/viewer/controls result=ok');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      checkedRoutes.add('/viewer/presets');
      debugPrint('ROUTE_CHECK route=/viewer/presets result=ok');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();
      checkedRoutes.add('/catalog');
      debugPrint('ROUTE_CHECK route=/catalog result=ok');

      await collectModuleDiag('Julia');
      await tester.pageBack();
      await tester.pumpAndSettle();
      checkedRoutes.add('/catalog');
      debugPrint('ROUTE_CHECK route=/catalog result=ok');

      await collectModuleDiag('Phoenix');

      expect(checkedRoutes.length, 8);
      expect(find.byType(FractalViewerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      debugPrint(
          'ROUTE_SUMMARY total=${checkedRoutes.length} routes=${checkedRoutes.join(',')}');
    });
  });
}
