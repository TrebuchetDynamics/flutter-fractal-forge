import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const output = String.fromEnvironment('VIEWER_UI_CAPTURE_TAG');
  const holdMs = int.fromEnvironment('VIEWER_UI_CAPTURE_HOLD_MS');

  for (final language in ['en', 'es']) {
    testWidgets('mobile viewer controls and native capture $language',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      // Exercise a phone-sized Flutter viewport without changing the device's
      // display density, resolution, locale, or accessibility profile.
      final phoneDpr = tester.view.physicalSize.width / 360;
      tester.view.devicePixelRatio = phoneDpr;
      tester.view.padding =
          FakeViewPadding(top: 24 * phoneDpr, bottom: 48 * phoneDpr);
      tester.view.viewPadding =
          FakeViewPadding(top: 24 * phoneDpr, bottom: 48 * phoneDpr);
      tester.view.systemGestureInsets = FakeViewPadding(bottom: 24 * phoneDpr);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      addTearDown(tester.view.resetSystemGestureInsets);
      final accessibility = await AccessibilityService.create();
      final renderer = await RendererSettingsService.create();
      final boundaryKey = GlobalKey();
      addTearDown(accessibility.dispose);
      addTearDown(renderer.dispose);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(RepaintBoundary(
        key: boundaryKey,
        child: FlutterFractalsApp(
          presetStore: await PresetStore.create(),
          accessibilityService: accessibility,
          rendererSettingsService: renderer,
          locale: Locale(language),
          skipSplash: true,
        ),
      ));
      await pumpForAppBoot(tester);
      await tester.tap(catalogModuleCards().first);
      await pumpForUiTransition(tester);
      final context = tester.element(find.byType(FractalViewerScreen));
      final controller = context.read<FractalController>();
      controller.selectModule(
          context.read<ModuleRegistry>().byId('weierstrass_p'),
          animate: false);
      await pumpForUiTransition(tester);
      final l10n = AppLocalizations.of(context)!;
      final receipts = <String, Object?>{};
      final captureDirectory = output.isEmpty
          ? null
          : Directory(
              '${(await getApplicationDocumentsDirectory()).path}/$output');

      Future<void> capture(String name, Map<String, Object?> geometry) async {
        await pumpForUiTransition(tester);
        expect(tester.takeException(), isNull);
        final media = MediaQuery.of(context);
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final image =
            await boundary.toImage(pixelRatio: media.devicePixelRatio);
        try {
          expect(
              image.width, (media.size.width * media.devicePixelRatio).round());
          expect(image.height,
              (media.size.height * media.devicePixelRatio).round());
          receipts[name] = {
            'simulatedPhoneMetrics': true,
            'logicalSize': [media.size.width, media.size.height],
            'pixelSize': [image.width, image.height],
            'devicePixelRatio': media.devicePixelRatio,
            'textScale': media.textScaler.scale(10) / 10,
            'highContrast': accessibility.highContrastEnabled,
            'largeTargets': accessibility.largeTargetsEnabled,
            ...geometry,
          };
          if (captureDirectory != null) {
            await captureDirectory.create(recursive: true);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            expect(png, isNotNull);
            await File('${captureDirectory.path}/$name.png')
                .writeAsBytes(png!.buffer.asUint8List());
            await File('${captureDirectory.path}/receipts-$language.json')
                .writeAsString(
                    const JsonEncoder.withIndent('  ').convert(receipts));
          }
        } finally {
          image.dispose();
        }
        debugPrint(
            '[viewer-ui-geometry] ${jsonEncode({name: receipts[name]})}');
        debugPrint('[viewer-ui-capture] $name');
        if (holdMs > 0) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: holdMs)));
        }
      }

      List<double> rect(Rect value) =>
          [value.left, value.top, value.right, value.bottom];
      for (final scale in [1, 3]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale.toDouble();
        await accessibility.setHighContrast(scale == 3);
        await accessibility.setLargeTargets(scale == 3);
        await pumpForUiTransition(tester);
        final media = MediaQuery.of(context);
        expect(media.textScaler.scale(10), scale * 10);
        final safeBottom = math.max(
            math.max(media.padding.bottom, media.viewPadding.bottom),
            media.systemGestureInsets.bottom);
        final target = scale == 3 ? 56.0 : 48.0;
        final primary = <String, Object?>{};
        for (final key in [
          'viewerControlsButton',
          'viewerPaletteButton',
          'viewerRandomFractalFab',
          'viewerOverflowMenu'
        ]) {
          final finder = find.byKey(ValueKey(key));
          await tester.ensureVisible(finder);
          await pumpForUiTransition(tester);
          final bounds = tester.getRect(finder);
          expect(bounds.width, greaterThanOrEqualTo(target));
          expect(bounds.height, greaterThanOrEqualTo(target));
          expect(
              bounds.bottom, lessThanOrEqualTo(media.size.height - safeBottom));
          expect(finder.hitTestable(), findsOneWidget);
          primary[key] = rect(bounds);
        }
        await capture('viewer-ui-$language-$scale-primary', primary);

        await openViewerTools(tester);
        final cycle = find.byKey(const ValueKey('viewerColorCycleButton'));
        await tester.ensureVisible(cycle);
        await pumpForUiTransition(tester);
        expect(find.byKey(const ValueKey('viewerFourierFab')), findsOneWidget);
        await capture('viewer-ui-$language-$scale-more',
            {'cycle': rect(tester.getRect(cycle))});
        final oldColor = controller.params['colorScheme'];
        await tester.tap(cycle);
        await pumpForUiTransition(tester);
        expect(controller.params['colorScheme'], isNot(oldColor));
        expect(find.text(l10n.viewerActionsMenu), findsNothing);

        final controls = find.byKey(const ValueKey('viewerControlsButton'));
        await tester.ensureVisible(controls);
        await tester.tap(controls);
        await pumpForUiTransition(tester);
        final surface = find.byKey(const ValueKey('controlsHudSurface'));
        expect(tester.widget<Material>(surface).color!.a, 1);
        final expanded = tester.getRect(surface);
        final mathInfo = FractalMathematics.forModule(controller.module);
        expect(
            tester
                .widget<Text>(
                    find.byKey(const Key('currentMathematicalFormula')))
                .data,
            mathematicalLabel(context, mathInfo.formula(controller.params)));
        expect(find.text(mathematicalLabel(context, mathInfo.qualification)),
            findsOneWidget);
        expect(
            find.textContaining(language == 'es'
                ? 'Configuración inicial:'
                : 'Starting configuration:'),
            findsNothing);
        await capture(
            'viewer-ui-$language-$scale-controls', {'surface': rect(expanded)});

        await tester.tap(find.byIcon(Icons.expand_more_rounded));
        await pumpForUiTransition(tester);
        final collapsed = tester.getRect(surface);
        expect(collapsed.height, lessThan(expanded.height - target));
        final panBefore = controller.view.pan.clone();
        await tester.dragFrom(
            Offset(media.size.width * .25, (expanded.top + collapsed.top) / 2),
            const Offset(24, 12));
        await pumpForUiTransition(tester);
        expect(controller.view.pan, isNot(panBefore),
            reason:
                'Collapsed HUD must release its former empty region to the canvas');
        await capture('viewer-ui-$language-$scale-collapsed',
            {'surface': rect(collapsed)});

        await tester.tap(find.byIcon(Icons.expand_less_rounded));
        await pumpForUiTransition(tester);
        final randomize = find.widgetWithText(FilledButton, l10n.randomize);
        await tester.ensureVisible(randomize);
        await pumpForUiTransition(tester);
        final footer = tester.getRect(randomize);
        expect(
            footer.bottom, lessThanOrEqualTo(media.size.height - safeBottom));
        expect(footer.height, greaterThanOrEqualTo(target));
        expect(randomize.hitTestable(), findsOneWidget);
        await capture('viewer-ui-$language-$scale-footer',
            {'randomize': rect(footer), 'safeBottom': safeBottom});
        final close = find.byIcon(Icons.close_rounded);
        await tester.ensureVisible(close);
        await tester.tap(close);
        await pumpForUiTransition(tester);
        expect(find.byType(FractalControlsHud), findsNothing);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
