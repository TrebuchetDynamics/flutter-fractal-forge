import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const output = String.fromEnvironment('APP_QUALITY_CAPTURE_DIR');
  const source = String.fromEnvironment('APP_QUALITY_SOURCE');

  testWidgets('composed app quality states preserve catalog return',
      (tester) async {
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    for (final fixture in [
      (
        name: 'small-en',
        size: const Size(320, 568),
        language: 'en',
        scale: 1.0,
        accessible: false
      ),
      (
        name: 'small-es-large',
        size: const Size(320, 568),
        language: 'es',
        scale: 2.0,
        accessible: false
      ),
      (
        name: 'desktop-en',
        size: const Size(1280, 800),
        language: 'en',
        scale: 1.0,
        accessible: false
      ),
      (
        name: 'desktop-es-accessible',
        size: const Size(1280, 800),
        language: 'es',
        scale: 1.0,
        accessible: true
      ),
    ]) {
      SharedPreferences.setMockInitialValues({});
      final accessibility = await AccessibilityService.create();
      await accessibility.setHighContrast(fixture.accessible);
      await accessibility.setReducedMotion(fixture.accessible);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = fixture.size;
      tester.platformDispatcher.textScaleFactorTestValue = fixture.scale;
      await binding.setSurfaceSize(fixture.size);
      final semantics = tester.ensureSemantics();
      final rendererSettings = await RendererSettingsService.create();
      final boundaryKey = GlobalKey();
      try {
        await tester.pumpWidget(RepaintBoundary(
          key: boundaryKey,
          child: FlutterFractalsApp(
            presetStore: await PresetStore.create(),
            accessibilityService: accessibility,
            rendererSettingsService: rendererSettings,
            locale: Locale(fixture.language),
          ),
        ));
        await pumpForAppBoot(tester);
        final l10n = AppLocalizations.of(
            tester.element(find.byKey(const ValueKey('homeSettingsButton'))))!;

        Future<void> capture(String state) async {
          await pumpForUiTransition(tester);
          expect(tester.takeException(), isNull,
              reason: '${fixture.name}/$state');
          final media =
              MediaQuery.of(tester.element(find.byType(Scaffold).last));
          expect(media.size, fixture.size);
          expect(media.textScaler.scale(10), 10 * fixture.scale);
          expect(accessibility.highContrastEnabled, fixture.accessible);
          expect(accessibility.reducedMotionEnabled, fixture.accessible);
          if (output.isEmpty) return;
          final renderer = find.byType(FractalRenderer);
          final controller = renderer.evaluate().isEmpty
              ? null
              : tester.element(renderer).read<FractalController>();
          final exportOptions = state == 'export'
              ? tester
                  .widget<ExportOptionsSheet>(find.byType(ExportOptionsSheet))
                  .initialOptions
              : null;
          final renderSize =
              controller == null ? null : tester.getSize(renderer);
          final dimensions = exportOptions?.getTargetDimensions(
              renderSize!.width, renderSize.height);
          final preferences = await SharedPreferences.getInstance();
          final directory = Directory('$output/${fixture.name}');
          await directory.create(recursive: true);
          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            expect((image.width, image.height),
                (fixture.size.width.toInt(), fixture.size.height.toInt()));
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('${directory.path}/$state.png')
                .writeAsBytes(png!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
          await File('${directory.path}/$state.json').writeAsString(jsonEncode({
            'source': source,
            'state': state,
            'viewport': [fixture.size.width, fixture.size.height],
            'devicePixelRatio': 1,
            'locale': fixture.language,
            'textScale': fixture.scale,
            'highContrast': fixture.accessible,
            'reducedMotion': fixture.accessible,
            'module': controller?.module.id,
            'params': controller?.params,
            'view': controller == null
                ? null
                : {
                    'pan': [controller.view.pan.x, controller.view.pan.y],
                    'zoom': controller.view.zoom,
                    'rotation': [
                      controller.view.rotation.x,
                      controller.view.rotation.y,
                      controller.view.rotation.z
                    ],
                  },
            'exportResolution': exportOptions?.resolution.name,
            'exportDimensions':
                dimensions == null ? null : [dimensions.$1, dimensions.$2],
            'catalogPreferences': {
              for (final key in preferences
                  .getKeys()
                  .where((key) => key.startsWith('catalog_browse_')))
                key: preferences.get(key),
            },
            'semantics': tester.binding.renderViews.single.owner?.semanticsOwner
                ?.rootSemanticsNode
                ?.toStringDeep(),
          }));
        }

        await capture('home');
        await tester.tap(find.byKey(const ValueKey('homeSettingsButton')));
        await capture('settings');
        await tester.tap(find.text(l10n.settingsPaletteSubtitle));
        await capture('theme');
        Navigator.of(tester.element(find.text(l10n.settingsColorTheme))).pop();
        await pumpForUiTransition(tester);
        await tester.tap(find.byType(BackButton));
        await pumpForUiTransition(tester);
        await capture('catalog');
        await enterCatalogSearch(tester, 'Mandelbrot');
        final card = catalogModuleCard('core.mandelbrot');
        await tester.scrollUntilVisible(card, 400,
            scrollable: find.byType(Scrollable).first, maxScrolls: 80);
        await tester.ensureVisible(card);
        await tester.tap(card);
        await capture('viewer');
        expect(find.byType(FractalViewerScreen), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
        await pumpForUiTransition(tester);
        await tester.tap(find.text(l10n.exportTitle).last);
        await capture('export');
        expect(find.byType(ExportOptionsSheet), findsOneWidget);
        final save = find.byKey(const ValueKey('exportSaveButton'));
        await tester.ensureVisible(save);
        expect(save.hitTestable(), findsOneWidget);
        Navigator.of(tester.element(find.byType(ExportOptionsSheet))).pop();
        await pumpForUiTransition(tester);
        await tester
            .tap(find.byKey(const ValueKey('viewerBackToCatalogButton')));
        await pumpForUiTransition(tester);
        expect(find.byType(FractalViewerScreen), findsNothing);
        expect(tester.widget<TextField>(catalogSearchField()).controller!.text,
            'Mandelbrot');
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        semantics.dispose();
        accessibility.dispose();
        rendererSettings.dispose();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        await binding.setSurfaceSize(null);
      }
    }
  });
}
