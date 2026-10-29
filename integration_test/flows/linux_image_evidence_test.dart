// Supplemental retained-image evidence, not a release or human-review verdict.
// Run with scripts/run-native-integration.sh and FORCE_GPU_RENDER=true.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const size =
      Size(1280, 720); // Same dimensions/aspect as landscape HD export.

  for (final language in ['en', 'es']) {
    for (final entry in [
      (id: 'mandelbrot', query: 'Mandelbrot', dimension: FractalDimension.twoD),
      (
        id: 'mandelbulb',
        query: 'Mandelbulb',
        dimension: FractalDimension.threeD
      ),
      (
        id: 'milnor_brieskorn',
        query: 'Milnor',
        dimension: FractalDimension.twoD
      ),
    ]) {
      // Catches wrong-module launches, lost edits, blank exports and divergence
      // between the actual frozen renderer and the production Save PNG flow.
      testWidgets(
          '$language ${entry.id} retains edited preview/export equality',
          (tester) async {
        expect(Platform.isLinux, isTrue);
        expect(RuntimeModeService.forceGpuRender, isTrue);
        expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
        final output = Platform.environment['FLUTTER_TEST_OUTPUTS_DIR'];
        expect(output, isNotNull,
            reason: 'Use the supported driver for private retained outputs');
        final directory =
            Directory('$output/linux-image-journey/$language-${entry.id}');
        expect(directory.existsSync(), isFalse,
            reason: 'Never overwrite evidence from an earlier invocation');
        await directory.create(recursive: true);
        final exports = await Directory('${directory.path}/saved').create();
        SharedPreferences.setMockInitialValues({
          'linux_export_directory': exports.path,
        });
        binding.platformDispatcher.semanticsEnabledTestValue = false;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await binding.setSurfaceSize(size);
        final accessibility = await AccessibilityService.create();
        await accessibility.setReducedMotion(true);
        final settings = await RendererSettingsService.create();
        final appBoundaryKey = GlobalKey();
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          accessibility.dispose();
          settings.dispose();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          binding.platformDispatcher.clearSemanticsEnabledTestValue();
          await binding.setSurfaceSize(null);
        });
        await tester.pumpWidget(RepaintBoundary(
          key: appBoundaryKey,
          child: FlutterFractalsApp(
            presetStore: await PresetStore.create(),
            accessibilityService: accessibility,
            rendererSettingsService: settings,
            locale: Locale(language),
          ),
        ));
        await pumpForAppBoot(tester);
        await enterCatalogSearch(tester, entry.query);
        final card = catalogModuleCard('core.${entry.id}');
        await tester.scrollUntilVisible(card, 400,
            scrollable: find.byType(Scrollable).first, maxScrolls: 80);
        await tester.ensureVisible(card);
        await pumpForUiTransition(tester);
        await tester.tap(card);
        await pumpForUiTransition(tester);
        final rendererFinder = find.byType(FractalRenderer);
        expect(rendererFinder, findsOneWidget);
        final context = tester.element(rendererFinder);
        final controller = context.read<FractalController>();
        final l10n = AppLocalizations.of(context)!;
        expect(Localizations.localeOf(context).languageCode, language);
        expect(controller.module.id, entry.id);
        expect(controller.module.dimension, entry.dimension);
        expect(tester.getSize(rendererFinder), size);
        final original = _state(controller);

        await tester.drag(rendererFinder, const Offset(48, 24));
        await pumpForUiTransition(tester);
        expect(_state(controller)['view'], isNot(original['view']),
            reason: 'Real viewer gesture must change the camera');
        await tester.tap(find.byKey(const ValueKey('viewerControlsButton')));
        await pumpForUiTransition(tester);
        final iterationsBefore = controller.params['iterations'];
        // The HUD puts iterations before other numeric parameters in all three
        // real modules. Read back the parameter, not merely the slider position.
        final slider = find
            .descendant(
                of: find.byType(FractalControlsHud),
                matching: find.byType(Slider))
            .first;
        await tester.ensureVisible(slider);
        await pumpForUiTransition(tester);
        await tester.drag(slider, const Offset(-36, 0));
        await pumpForUiTransition(tester);
        expect(controller.params['iterations'], isNot(iterationsBefore));
        final mathematics = FractalMathematics.forModule(controller.module);
        final formulaFinder =
            find.byKey(const Key('currentMathematicalFormula'));
        await tester.ensureVisible(formulaFinder);
        await pumpForUiTransition(tester);
        final formula = tester.widget<Text>(formulaFinder).data!;
        final qualification =
            mathematicalLabel(context, mathematics.qualification);
        expect(formula, isNotEmpty);
        expect(formula,
            mathematicalLabel(context, mathematics.formula(controller.params)));
        expect(find.text(qualification), findsOneWidget);
        if (entry.id == 'milnor_brieskorn') {
          expect(mathematics.qualification, startsWith('Inspired;'));
          expect(qualification,
              startsWith(language == 'es' ? 'Inspirada;' : 'Inspired;'));
        }
        await _capture(
            appBoundaryKey, '${directory.path}/formula-controls.png');
        await tester.tap(find.byTooltip(l10n.semanticCloseButton).last);
        await pumpForUiTransition(tester);
        final edited = _state(controller);
        final renderer = tester.widget<FractalRenderer>(rendererFinder);
        expect(accessibility.reducedMotionEnabled, isTrue);
        expect(renderer.animationEnabled, isFalse);
        expect(renderer.renderSnapshotSink?.snapshot?.time, 0);
        expect(controller.transparentBackground, isFalse);
        await _capture(appBoundaryKey, '${directory.path}/edited-viewer.png');
        final preview = await _capture(
            renderer.boundaryKey!, '${directory.path}/preview.png');
        await tester.pump(const Duration(milliseconds: 300));
        final repeated = await _capture(
            renderer.boundaryKey!, '${directory.path}/preview-repeat.png');
        final stability = _compare(preview, repeated);

        await openViewerTools(tester);
        final exportAction =
            find.byKey(const ValueKey('viewerOpenExportAction'));
        await tester.ensureVisible(exportAction);
        await pumpForUiTransition(tester);
        await tester.tap(exportAction);
        await pumpForUiTransition(tester);
        expect(find.byType(ExportOptionsSheet), findsOneWidget);
        final customize = find.text(l10n.exportButtonCustomize);
        await tester.ensureVisible(customize);
        await tester.tap(customize);
        await pumpForUiTransition(tester);
        final hd = find.text(l10n.exportResolutionHd);
        await tester.ensureVisible(hd);
        await tester.tap(hd);
        await pumpForUiTransition(tester);
        expect(
            tester
                .widget<ChoiceChip>(
                    find.ancestor(of: hd, matching: find.byType(ChoiceChip)))
                .selected,
            isTrue);
        final save = find.byKey(const ValueKey('exportSaveButton'));
        await tester.ensureVisible(save);
        await pumpForUiTransition(tester);
        await _capture(appBoundaryKey, '${directory.path}/export-options.png');
        expect(save.hitTestable(), findsOneWidget);
        await tester.tap(save);
        await tester.pump();
        File? saved;
        for (var attempt = 0; attempt < 120; attempt++) {
          final files = await exports
              .list()
              .where((entity) => entity is File && entity.path.endsWith('.png'))
              .cast<File>()
              .toList();
          if (files.length == 1) {
            saved = files.single;
            break;
          }
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(saved, isNotNull,
            reason: 'Production Save must commit an edited PNG');
        final decoded = img.decodePng(await saved!.readAsBytes());
        expect(decoded, isNotNull);
        final comparison = _compare(preview, decoded!);
        final unchanged = _state(controller);
        final stateFile = File('${directory.path}/state.json');
        await stateFile
            .writeAsString(const JsonEncoder.withIndent('  ').convert({
          'fixture': 'supplemental Linux native integration journey',
          'sourceBinding':
              'Exact tested revision and fixture/driver/wrapper/SDK hashes are in the enclosing native run.json; runtime-tree equality is separately recorded in the task report',
          'locale': language,
          'catalogId': 'core.${entry.id}',
          'search': entry.query,
          'moduleId': controller.module.id,
          'shader': controller.module.shaderAsset,
          'dimension': controller.module.dimension.name,
          'viewport': [1280, 720],
          'devicePixelRatio': 1,
          'nativeFonts': true,
          'reducedMotion': accessibility.reducedMotionEnabled,
          'animationEnabled': renderer.animationEnabled,
          'renderTime': renderer.renderSnapshotSink?.snapshot?.time,
          'original': original,
          'edited': edited,
          'afterExport': unchanged,
          'formula': formula,
          'qualification': qualification,
          'sourceQualification': mathematics.qualification,
          'export': {
            'format': 'png',
            'resolution': 'hd',
            'dimensions': [1280, 720]
          },
          'preview':
              _imageRecord(File('${directory.path}/preview.png'), preview),
          'saved': _imageRecord(saved, decoded),
          'previewStability': stability,
          'previewExportComparison': comparison,
          'humanCompositionReadabilitySourceReview':
              'pending; no human verdict supplied',
        }));
        debugPrint(
            'LINUX_IMAGE_EVIDENCE:${stateFile.path}:${jsonEncode(comparison)}');
        // Persist numerical failures before asserting. No image substitution,
        // crop, rescaling, ignored pixels or ungrounded tolerance is allowed.
        expect((preview.width, preview.height), (1280, 720));
        expect((decoded.width, decoded.height), (1280, 720));
        expect(_colors(preview), greaterThan(16));
        expect(_colors(decoded), greaterThan(16));
        expect(stability['differentPixels'], 0,
            reason: 'Reduced-motion preview must really be frozen');
        expect(comparison['differentPixels'], 0,
            reason:
                'Same-size opaque PNG must exactly match frozen edited RGBA');
        expect(unchanged, edited,
            reason: 'Export must preserve edited parameters/view');
        expect(tester.takeException(), isNull);
        await tester
            .tap(find.byKey(const ValueKey('viewerBackToCatalogButton')));
        await pumpForUiTransition(tester);
        expect(tester.widget<TextField>(catalogSearchField()).controller!.text,
            entry.query);
      },
          // Broad integration discovery includes other platforms; only Linux
          // supports this fixture's native-driver retained-output flow.
          skip: kIsWeb || !Platform.isLinux);
    }
  }
}

Map<String, Object?> _state(FractalController controller) => {
      'params': Map<String, dynamic>.from(controller.params),
      'view': {
        'pan': [controller.view.pan.x, controller.view.pan.y],
        'zoom': controller.view.zoom,
        'rotation': [
          controller.view.rotation.x,
          controller.view.rotation.y,
          controller.view.rotation.z
        ],
      },
      'transparentBackground': controller.transparentBackground,
    };

Future<img.Image> _capture(GlobalKey key, String path) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  try {
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    await File(path).writeAsBytes(bytes);
    return img.decodePng(bytes)!;
  } finally {
    image.dispose();
  }
}

int _colors(img.Image image) {
  final colors = <int>{};
  for (var y = 0; y < image.height; y += 4) {
    for (var x = 0; x < image.width; x += 4) {
      final pixel = image.getPixel(x, y);
      colors.add(
          (pixel.r.toInt() << 16) | (pixel.g.toInt() << 8) | pixel.b.toInt());
    }
  }
  return colors.length;
}

Map<String, Object> _imageRecord(File file, img.Image image) {
  final hash = Process.runSync('/usr/bin/sha256sum', [file.path]);
  expect(hash.exitCode, 0);
  return {
    'path': file.path,
    'sha256': (hash.stdout as String).split(' ').first,
    'width': image.width,
    'height': image.height,
    'sampledRgbColors': _colors(image),
  };
}

Map<String, Object> _compare(img.Image preview, img.Image exported) {
  if (preview.width != exported.width || preview.height != exported.height) {
    return {'comparable': false, 'reason': 'dimension mismatch'};
  }
  var differentPixels = 0;
  var differentChannels = 0;
  var maximumChannelError = 0;
  var absoluteChannelError = 0;
  for (var y = 0; y < preview.height; y++) {
    for (var x = 0; x < preview.width; x++) {
      final a = preview.getPixel(x, y);
      final b = exported.getPixel(x, y);
      final differences = [
        (a.r - b.r).abs().toInt(),
        (a.g - b.g).abs().toInt(),
        (a.b - b.b).abs().toInt(),
        (a.a - b.a).abs().toInt(),
      ];
      if (differences.any((difference) => difference != 0)) differentPixels++;
      for (final difference in differences) {
        if (difference != 0) differentChannels++;
        if (difference > maximumChannelError) maximumChannelError = difference;
        absoluteChannelError += difference;
      }
    }
  }
  return {
    'comparable': true,
    'comparedPixels': preview.width * preview.height,
    'channels': 'RGBA8 decoded, including alpha',
    'differentPixels': differentPixels,
    'differentChannels': differentChannels,
    'maximumChannelError': maximumChannelError,
    'meanAbsoluteChannelError':
        absoluteChannelError / (preview.width * preview.height * 4),
    'allowedChannelError': 0,
  };
}
