import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  const source = String.fromEnvironment('UI_REPAIR_SOURCE');
  const captureTag = String.fromEnvironment('UI_REPAIR_CAPTURE_TAG');

  for (final language in ['en', 'es']) {
    testWidgets('screenshot UI repairs retain usable native flows $language',
        (tester) async {
      expect(Platform.isAndroid, isTrue,
          reason: 'This fixture qualifies the designated Android target.');
      expect(const bool.fromEnvironment('FORCE_GPU_RENDER'), isTrue,
          reason: 'The live UI check must use the real shader path.');
      expect(source, matches(RegExp(r'^[a-f0-9]{40}$')),
          reason: 'Native evidence must identify its exact source commit.');
      SharedPreferences.setMockInitialValues({});
      final accessibility = await AccessibilityService.create();
      final renderer = await RendererSettingsService.create();
      await accessibility.setReducedMotion(true);
      final root = GlobalKey();
      final folder = captureTag.isEmpty
          ? 'ui-repair-${DateTime.now().millisecondsSinceEpoch}'
          : captureTag;
      // App-scoped external storage permits ADB readback without root/run-as.
      final storage = await getExternalStorageDirectory();
      expect(storage, isNotNull);
      final directory = Directory('${storage!.path}/$folder');
      await directory.create(recursive: true);
      final observations = <String, Object?>{};
      var metricsOverridden = false;
      final semantics = tester.ensureSemantics();
      try {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        addTearDown(tester.view.resetSystemGestureInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(accessibility.dispose);
        addTearDown(renderer.dispose);

        await tester.pumpWidget(RepaintBoundary(
          key: root,
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
        final registry = context.read<ModuleRegistry>();
        final l10n = AppLocalizations.of(context)!;

        Future<void> capture(String name) async {
          await pumpForUiTransition(tester);
          List<FractalCanvas> painters() => tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .map((paint) => paint.painter)
              .whereType<FractalCanvas>()
              .where((paint) => paint.module.id == controller.module.id)
              .toList();
          for (var attempt = 0; attempt < 20 && painters().isEmpty; attempt++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(painters(), hasLength(1),
              reason: 'Require this module’s real FragmentShader painter.');
          expect(tester.takeException(), isNull);
          final boundary =
              root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final dpr = tester.view.devicePixelRatio;
          final image = await boundary.toImage(pixelRatio: dpr);
          try {
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            expect(bytes, isNotNull);
            await File('${directory.path}/$name.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            observations[name] = {
              'source': source,
              'module': controller.module.id,
              'shader': controller.module.shaderAsset,
              'backend': 'gpu',
              'painter': 'FractalCanvas/FragmentShader',
              'logicalSize': [boundary.size.width, boundary.size.height],
              'pixelSize': [image.width, image.height],
              'textScale': MediaQuery.textScalerOf(context).scale(10) / 10,
              'testViewportMetrics': metricsOverridden,
              'hostDeviceProfileChanged': false,
              'highContrast': accessibility.highContrastEnabled,
            };
            await File('${directory.path}/receipts-$language.json')
                .writeAsString(
                    const JsonEncoder.withIndent('  ').convert(observations));
            debugPrint('[ui-repair-capture] ${directory.path}/$name.png');
          } finally {
            image.dispose();
          }
        }

        Future<void> waitForFeedback() async {
          // Copy/Apply success feedback is transient and can cover dock actions.
          for (var attempt = 0;
              attempt < 70 && find.byType(SnackBar).evaluate().isNotEmpty;
              attempt++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.byType(SnackBar), findsNothing);
        }

        Future<Finder> reveal(String key) async {
          await waitForFeedback();
          var action = find.byKey(ValueKey(key));
          if (action.evaluate().isEmpty) {
            await openViewerTools(tester);
            action = find.byKey(ValueKey(key));
          }
          expect(action, findsOneWidget);
          await tester.ensureVisible(action);
          await pumpForUiTransition(tester);
          expect(action.hitTestable(), findsOneWidget);
          return action;
        }

        Future<void> tapAction(String key) async {
          await tester.tap(await reveal(key));
          await pumpForUiTransition(tester);
        }

        Future<void> closeSheet() async {
          final close = find
              .byTooltip(MaterialLocalizations.of(context).closeButtonTooltip);
          if (close.evaluate().isEmpty) {
            // Lazy palette/wallpaper lists rebuild their shared header on return
            // to the top, rather than reserving a tall fixed header.
            final paletteScroll =
                find.byKey(const ValueKey('palettePickerScroll'));
            final sheet = paletteScroll.evaluate().isNotEmpty
                ? paletteScroll
                : find.byType(WallpaperOptionsSheet);
            expect(sheet, findsOneWidget);
            await tester.scrollUntilVisible(close, -300,
                maxScrolls: 100,
                scrollable: find.descendant(
                    of: sheet, matching: find.byType(Scrollable)));
            await pumpForUiTransition(tester);
          }
          expect(close, findsWidgets);
          await tester.ensureVisible(close.last);
          await pumpForUiTransition(tester);
          expect(close.last.hitTestable(), findsOneWidget);
          await tester.tap(close.last);
          await pumpForUiTransition(tester);
        }

        void expectUnbrokenWords(Finder action) {
          final texts =
              find.descendant(of: action, matching: find.byType(RichText));
          for (final element in texts.evaluate()) {
            final paragraph = element.renderObject;
            if (paragraph is! RenderParagraph) continue;
            expect(paragraph.didExceedMaxLines, isFalse);
            final text = paragraph.text.toPlainText();
            for (final word in RegExp(r'\S+').allMatches(text)) {
              final boxes = paragraph.getBoxesForSelection(TextSelection(
                  baseOffset: word.start, extentOffset: word.end));
              expect(boxes.map((box) => (box.top * 10).round()).toSet().length,
                  lessThanOrEqualTo(1),
                  reason: 'Action word ${word.group(0)} must not split lines.');
            }
          }
        }

        controller.selectModule(registry.byId('f0490_tangent_mandelbrot'),
            animate: false);
        await pumpForUiTransition(tester);
        await capture('$language-native-baseline');
        await tapAction('viewerShareLinkAction');
        final nativeShare =
            find.widgetWithIcon(FilledButton, Icons.share_rounded);
        await tester.ensureVisible(nativeShare);
        await tester.tap(nativeShare);
        // The host runner verifies/captures Android's actual chooser, then
        // cancels it. No recipient is selected and no message is transmitted.
        debugPrint('[ui-repair-native-share] $language');
        for (var attempt = 0;
            attempt < 200 && find.byType(ShareSheet).evaluate().isNotEmpty;
            attempt++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.byType(ShareSheet), findsNothing,
            reason:
                'Native chooser cancellation must finish without a stuck sheet.');
        await capture('$language-native-after-share');

        final nativePhysicalWidth = tester.view.physicalSize.width;
        metricsOverridden = true;
        for (final profile in [
          (390.0, 780.0, 1.0),
          (360.0, 640.0, 2.0),
          (320.0, 568.0, 3.0),
          (640.0, 360.0, 3.0),
        ]) {
          final (width, height, scale) = profile;
          final dpr = nativePhysicalWidth / width;
          // Test-only Flutter metrics: never rotate or reconfigure the host.
          tester.view.physicalSize = Size(nativePhysicalWidth, height * dpr);
          tester.view.devicePixelRatio = dpr;
          tester.view.padding =
              FakeViewPadding(top: 24 * dpr, bottom: 32 * dpr);
          tester.view.viewPadding =
              FakeViewPadding(top: 24 * dpr, bottom: 32 * dpr);
          tester.view.systemGestureInsets = FakeViewPadding(bottom: 24 * dpr);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          await accessibility.setHighContrast(scale == 3);
          await accessibility.setLargeTargets(scale == 3);
          controller.selectModule(registry.byId('f0161_swirl_julia'),
              animate: false);
          await pumpForUiTransition(tester);
          final tag = '$language-${width.round()}-${scale.round()}';
          final target = scale == 3 ? 56.0 : 48.0;

          for (final key in [
            'viewerControlsButton',
            'viewerPaletteButton',
            'viewerRandomFractalFab',
            'viewerBreathingButton',
            'viewerOverflowMenu',
          ]) {
            final inMenu = find.byKey(ValueKey(key)).evaluate().isEmpty;
            final action = await reveal(key);
            final bounds = tester.getRect(action);
            expect(bounds.width, greaterThanOrEqualTo(target));
            expect(bounds.height, greaterThanOrEqualTo(target));
            expectUnbrokenWords(action);
            if (inMenu) await closeSheet();
          }
          await capture('$tag-toolbar');
          await openViewerTools(tester);
          await capture('$tag-more');
          await closeSheet();

          controller.selectModule(registry.byId('f1046_svensson_wave'),
              animate: false);
          await pumpForUiTransition(tester);
          await tapAction('viewerPaletteButton');
          await capture('$tag-palette');
          final finalPalette = find.byKey(const ValueKey('paletteChoice63'));
          await tester.scrollUntilVisible(finalPalette, 300,
              maxScrolls: 100,
              scrollable: find.descendant(
                  of: find.byKey(const ValueKey('palettePickerScroll')),
                  matching: find.byType(Scrollable)));
          await pumpForUiTransition(tester);
          expect(finalPalette.hitTestable(), findsOneWidget);
          await tester.tap(finalPalette);
          await pumpForUiTransition(tester);
          expect(controller.params['colorScheme'], 63);
          expect(
              tester
                  .getSemantics(finalPalette)
                  .getSemanticsData()
                  .flagsCollection
                  .isSelected,
              ui.Tristate.isTrue);
          expect(
              find.descendant(
                  of: finalPalette,
                  matching: find.byIcon(Icons.check_circle_rounded)),
              findsOneWidget);
          await capture('$tag-palette-selected');
          await closeSheet();

          controller.selectModule(registry.byId('f0490_tangent_mandelbrot'),
              animate: false);
          await pumpForUiTransition(tester);
          await openViewerTools(tester);
          await tapAction('viewerShareLinkAction');
          expect(find.byType(ShareSheet), findsOneWidget);
          for (var attempt = 0;
              attempt < 30 &&
                  find
                      .descendant(
                          of: find.byType(ShareSheet),
                          matching: find.byType(Image))
                      .evaluate()
                      .isEmpty;
              attempt++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(
              find.descendant(
                  of: find.byType(ShareSheet), matching: find.byType(Image)),
              findsOneWidget,
              reason:
                  'Share must show this actual artwork, not a fake swatch.');
          final sheet = tester.widget<ShareSheet>(find.byType(ShareSheet));
          final codec = await ui.instantiateImageCodec(sheet.previewBytes!);
          try {
            final frame = await codec.getNextFrame();
            try {
              final pixels = await frame.image
                  .toByteData(format: ui.ImageByteFormat.rawRgba);
              final colors = pixels!.buffer.asUint32List().toSet();
              expect(colors.length, greaterThan(16),
                  reason: 'The actual artwork preview must not be blank.');
            } finally {
              frame.image.dispose();
            }
          } finally {
            codec.dispose();
          }
          final uri = sheet.uri;
          expect(find.text(uri.toString()).hitTestable(), findsNothing);
          await capture('$tag-share');
          final copy = find.widgetWithIcon(OutlinedButton, Icons.copy_rounded);
          await tester.ensureVisible(copy);
          await tester.tap(copy);
          await pumpForUiTransition(tester);
          final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
          expect(clipboard?.text, uri.toString());
          expect(find.byType(ShareSheet), findsNothing);
          await waitForFeedback();

          await openViewerTools(tester);
          await tapAction('viewerWallpaperAction');
          expect(find.byType(WallpaperOptionsSheet), findsOneWidget);
          final wallpaperScroll = find.descendant(
              of: find.byType(WallpaperOptionsSheet),
              matching: find.byType(Scrollable));
          for (final label in [
            l10n.wallpaperTargetHome,
            l10n.wallpaperTargetBoth,
            l10n.wallpaperTargetLock,
            l10n.wallpaperPresetPlain,
            l10n.wallpaperPresetHome,
            l10n.wallpaperPresetLock,
          ]) {
            final option = find.text(label);
            await tester.scrollUntilVisible(option, 90,
                scrollable: wallpaperScroll, maxScrolls: 100);
            await tester.ensureVisible(option);
            await pumpForUiTransition(tester);
            expect(option.hitTestable(), findsOneWidget, reason: label);
            await tester.tap(option);
            await pumpForUiTransition(tester);
            final chip = find.widgetWithText(ChoiceChip, label);
            if (chip.evaluate().isNotEmpty) {
              expect(tester.widget<ChoiceChip>(chip).selected, isTrue);
            } else {
              final targetButton = find.widgetWithText(OutlinedButton, label);
              expect(
                  tester
                      .getSemantics(targetButton)
                      .getSemanticsData()
                      .flagsCollection
                      .isSelected,
                  ui.Tristate.isTrue);
            }
          }
          final saveCopy = find.byType(SwitchListTile);
          await tester.ensureVisible(saveCopy);
          await pumpForUiTransition(tester);
          final apply = find.widgetWithText(FilledButton, l10n.wallpaperApply);
          final optionsBounds = tester.getRect(saveCopy);
          final applyBounds = tester.getRect(apply);
          expect(optionsBounds.bottom, lessThanOrEqualTo(applyBounds.top));
          expect(saveCopy.hitTestable(), findsOneWidget);
          expect(apply.hitTestable(), findsOneWidget);
          // Exercise the real Apply once; other profiles retain scroll/target
          // checks without repeatedly replacing the disposable target's wallpaper.
          if (language == 'en' && width == 390) {
            final saveCopyTile = tester.widget<SwitchListTile>(saveCopy);
            if (saveCopyTile.value) {
              await tester.tap(saveCopy);
              await pumpForUiTransition(tester);
            }
            await capture('$tag-wallpaper');
            debugPrint('[ui-repair-wallpaper] tap-start');
            await tester.tap(apply);
            debugPrint('[ui-repair-wallpaper] tap-dispatched');
            await pumpForUiTransition(tester);
            debugPrint('[ui-repair-wallpaper] transition-ready');
            for (var attempt = 0;
                attempt < 100 &&
                    find.text(l10n.wallpaperApplied).evaluate().isEmpty;
                attempt++) {
              await tester.pump(const Duration(milliseconds: 200));
            }
            debugPrint('[ui-repair-wallpaper] feedback-assert');
            expect(find.byType(WallpaperOptionsSheet), findsNothing);
            expect(find.text(l10n.wallpaperApplied), findsOneWidget,
                reason: 'Require the actual Android wallpaper API to succeed.');
            debugPrint('[ui-repair-wallpaper] capture-start');
            await capture('$tag-wallpaper-applied');
            debugPrint('[ui-repair-wallpaper] capture-complete');
            await waitForFeedback();
            debugPrint('[ui-repair-wallpaper] feedback-cleared');
          } else {
            await capture('$tag-wallpaper');
            await closeSheet();
          }

          controller.selectModule(
              registry.byId('f1178_orbit_trap_composite_multi_shape'),
              animate: false);
          final initialParams = Map<String, Object>.from(controller.params);
          final changedIterations =
              initialParams['iterations'] == 420 ? 400 : 420;
          controller.updateParam('iterations', changedIterations);
          controller.updateView(controller.view.copyWith(
              pan: Vector2(0.2, 0.3),
              zoom: 2,
              rotation: Vector3(0.1, 0.2, 0.3)));
          expect(controller.params['iterations'],
              isNot(initialParams['iterations']));
          await pumpForUiTransition(tester);
          await tapAction('viewerControlsButton');
          expect(find.byType(FractalControlsHud), findsOneWidget);
          await capture('$tag-controls');
          final details = find.text(l10n.viewerFormulaDetails);
          await tester.ensureVisible(details);
          await tester.tap(details);
          await pumpForUiTransition(tester);
          expect(find.byKey(const Key('currentMathematicalFormula')),
              findsOneWidget);
          expect(find.byKey(const Key('currentMathematicalQualification')),
              findsOneWidget);
          await capture('$tag-formula');
          final resetView = find.text(l10n.hudResetViewLabel);
          await tester.ensureVisible(resetView);
          await pumpForUiTransition(tester);
          expect(resetView.hitTestable(), findsOneWidget);
          await capture('$tag-reset-view');
          await tester.tap(resetView);
          await pumpForUiTransition(tester);
          expect(controller.view.zoom, 1);
          expect(controller.view.rotation, Vector3.zero());
          expect(controller.view.pan.x, 0);
          expect(controller.view.pan.y, 0);
          expect(controller.params['iterations'], changedIterations);
          final reset = find.text(l10n.hudResetParamsLabel);
          await tester.ensureVisible(reset);
          await pumpForUiTransition(tester);
          expect(reset.hitTestable(), findsOneWidget);
          await tester.tap(reset);
          await pumpForUiTransition(tester);
          expect(controller.params, initialParams);
          expect(controller.view.zoom, 1);
          expect(controller.view.rotation, Vector3.zero());
          await capture('$tag-resets');
          final close = find.byTooltip(l10n.semanticCloseButton);
          await tester.ensureVisible(close);
          await tester.tap(close);
          await pumpForUiTransition(tester);
          expect(find.byType(FractalControlsHud), findsNothing);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      } finally {
        semantics.dispose();
      }
    });
  }
}
