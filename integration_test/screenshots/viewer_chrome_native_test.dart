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
    testWidgets('native viewer chrome capture $language', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: FlutterFractalsApp(
            presetStore: await PresetStore.create(),
            accessibilityService: await AccessibilityService.create(),
            rendererSettingsService: await RendererSettingsService.create(),
            locale: Locale(language),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(catalogModuleCards().first);
      await tester.pump();
      // Advance entrance animations without waiting for the live renderer to idle.
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(FractalViewerScreen), findsOneWidget);
      final l10n = AppLocalizations.of(
          tester.element(find.byType(FractalViewerScreen)))!;
      expect(l10n.localeName, language);
      expect(find.byTooltip(l10n.viewerBackToCatalog), findsOneWidget);
      final overflow = find.byKey(const ValueKey('viewerOverflowMenu'));
      expect(overflow.hitTestable(), findsOneWidget);
      final overflowTarget = tester.getRect(overflow);
      expect(overflowTarget.width, greaterThanOrEqualTo(48));
      expect(overflowTarget.height, greaterThanOrEqualTo(48));
      final back = find.byKey(const ValueKey('viewerBackToCatalogButton'));
      expect(back, findsOneWidget);
      final target = tester.getRect(back);
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      expect(back.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);

      final boundary = boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      try {
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        expect(png, isNotNull);
        if (output.isNotEmpty) {
          await Directory(output).create(recursive: true);
          await File('$output/viewer-$language.png')
              .writeAsBytes(png!.buffer.asUint8List());
        }
        debugPrint('[viewer-chrome-native] language=$language '
            'size=${image.width}x${image.height} back=$target '
            'fontSubstitution=false');
      } finally {
        image.dispose();
      }
      await tester.tap(back);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(FractalViewerScreen), findsNothing);
    });
  }
}
