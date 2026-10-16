import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const output = String.fromEnvironment('VIEWER_CHROME_CAPTURE_DIR');

  for (final language in ['en', 'es']) {
    for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
      for (final accessibleLandscape in [false, true]) {
        final size = Size(width, width * (accessibleLandscape ? 0.625 : 1.25));
        final state = accessibleLandscape ? 'landscape-accessible' : 'portrait';
        final captureName = 'viewer-$language-${width.toInt()}-$state';
        testWidgets('native viewer chrome capture $captureName',
            (tester) async {
          SharedPreferences.setMockInitialValues({});
          final accessibility = await AccessibilityService.create();
          await accessibility.setHighContrast(accessibleLandscape);
          await accessibility.setLargeTargets(accessibleLandscape);
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundaryKey,
              child: FlutterFractalsApp(
                presetStore: await PresetStore.create(),
                accessibilityService: accessibility,
                rendererSettingsService: await RendererSettingsService.create(),
                locale: Locale(language),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 3));
          await tester.tap(catalogModuleCards().first);
          await tester.pump();
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.platformDispatcher.textScaleFactorTestValue =
              accessibleLandscape ? 2 : 1;
          await tester.binding.setSurfaceSize(size);
          addTearDown(() async {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
            tester.platformDispatcher.clearTextScaleFactorTestValue();
            await tester.binding.setSurfaceSize(null);
          });
          // Advance entrance animations without waiting for the live renderer to idle.
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.byType(FractalViewerScreen), findsOneWidget);
          final l10n = AppLocalizations.of(
              tester.element(find.byType(FractalViewerScreen)))!;
          expect(l10n.localeName, language);
          final media =
              MediaQuery.of(tester.element(find.byType(FractalViewerScreen)));
          expect(media.size, size);
          expect(media.textScaler.scale(10), accessibleLandscape ? 20 : 10);
          expect(accessibility.highContrastEnabled, accessibleLandscape);
          final minimumTarget = accessibleLandscape ? 56 : 48;
          final viewport = Offset.zero & size;
          expect(find.byTooltip(l10n.viewerBackToCatalog), findsOneWidget);
          final overflow = find.byKey(const ValueKey('viewerOverflowMenu'));
          expect(overflow.hitTestable(), findsOneWidget);
          final overflowTarget = tester.getRect(overflow);
          expect(overflowTarget.width, greaterThanOrEqualTo(minimumTarget));
          expect(overflowTarget.height, greaterThanOrEqualTo(minimumTarget));
          final back = find.byKey(const ValueKey('viewerBackToCatalogButton'));
          expect(back, findsOneWidget);
          final target = tester.getRect(back);
          expect(target.width, greaterThanOrEqualTo(minimumTarget));
          expect(target.height, greaterThanOrEqualTo(minimumTarget));
          expect(back.hitTestable(), findsOneWidget);
          expect(viewport.contains(target.topLeft), isTrue);
          expect(viewport.contains(target.bottomRight), isTrue);
          expect(viewport.contains(overflowTarget.topLeft), isTrue);
          expect(viewport.contains(overflowTarget.bottomRight), isTrue);
          expect(target.overlaps(overflowTarget), isFalse);
          expect(tester.takeException(), isNull);

          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            expect(image.width, size.width.toInt());
            expect(image.height, size.height.toInt());
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            expect(png, isNotNull);
            if (output.isNotEmpty) {
              await Directory(output).create(recursive: true);
              await File('$output/$captureName.png')
                  .writeAsBytes(png!.buffer.asUint8List());
            }
            debugPrint('[viewer-chrome-native] case=$captureName '
                'size=${image.width}x${image.height} back=$target '
                'fontSubstitution=false');
          } finally {
            image.dispose();
          }
          final randomize =
              find.byKey(const ValueKey('viewerRandomParamsButton'));
          await tester.ensureVisible(randomize);
          await tester.pumpAndSettle();
          await tester.longPress(randomize);
          await tester.pumpAndSettle();
          expect(find.text(l10n.controlsTitle), findsOneWidget);

          // Explicit catalog Back pops directly, unlike system Back, which
          // dismisses the open controls HUD first.
          await tester.tap(back);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(FractalViewerScreen), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
