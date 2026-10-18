import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Gaussian catalog journey walks, pauses growth, and exports its selected PNG',
    (tester) async {
      binding.platformDispatcher.semanticsEnabledTestValue = false;
      SharedPreferences.setMockInitialValues({});
      final presetStore = await PresetStore.create();
      final accessibility = await AccessibilityService.create();
      final settings = await RendererSettingsService.create();
      addTearDown(() {
        accessibility.dispose();
        settings.dispose();
      });

      final tempRoot = Platform.environment['TMPDIR'];
      expect(tempRoot, isNotEmpty, reason: 'use task-scoped temporary storage');
      final exportDirectory = Directory(
        '$tempRoot/gaussian-moat-journey-$pid-${DateTime.now().microsecondsSinceEpoch}',
      );
      await exportDirectory.create(recursive: true);
      addTearDown(() => exportDirectory.delete(recursive: true));
      await ExportService().setPreferredExportDirectory(exportDirectory);
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibility,
        rendererSettingsService: settings,
        locale: const Locale('en'),
        skipSplash: true,
      ));
      await pumpForAppBoot(tester);

      // Enter through the actual catalog card; this guards the bypass that
      // previously mounted FractalViewerScreen with the module preselected.
      await enterCatalogSearch(tester, 'Gaussian Prime Lattice');
      final card = catalogModuleCard('core.gaussian_prime_lattice');
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await pumpForUiTransition(tester, settle: const Duration(seconds: 2));
      final renderer = find.byType(FractalRenderer);
      expect(renderer, findsOneWidget);
      final controller = Provider.of<FractalController>(
        tester.element(renderer),
        listen: false,
      );
      expect(controller.module.id, 'gaussian_prime_lattice');

      await tester.tap(find.text('Walk'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ready:'), findsOneWidget);
      expect(find.textContaining('boundary'), findsOneWidget);
      final stepControl = find.widgetWithText(TextButton, 'Step to candidate');
      final stepBounds = tester.getSize(stepControl);
      expect(stepBounds.width, greaterThanOrEqualTo(48));
      expect(stepBounds.height, greaterThanOrEqualTo(48),
          reason:
              'the accessible Step action target must be at least 48px tall');
      final beforeWalk = await _exportHdPng(tester, exportDirectory);

      // Candidate input is also the keyboard-accessible route to the same
      // exact lattice point: 1+i to 1-i has squared distance four.
      await tester.enterText(find.byKey(const Key('gaussianCoordinateA')), '1');
      await tester.enterText(
          find.byKey(const Key('gaussianCoordinateB')), '-1');
      await tester.tap(find.text('Select candidate'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Candidate: (1, -1)'), findsOneWidget);
      await _pressStep(tester);
      expect(find.textContaining('Path: 1 steps'), findsOneWidget);

      await tester.tap(find.text('Play radius growth'));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.tap(find.text('Pause radius growth'));
      await tester.pumpAndSettle();
      expect(find.text('Play radius growth'), findsOneWidget);
      await _pressStep(tester);
      expect(find.textContaining('Path: 1 steps'), findsOneWidget);

      final pausedPng = await _exportHdPng(tester, exportDirectory);
      final beforeDecoded = image.decodePng(await beforeWalk.readAsBytes());
      final pausedDecoded = image.decodePng(await pausedPng.readAsBytes());
      expect(beforeDecoded, isNotNull);
      expect(pausedDecoded, isNotNull);
      expect(pausedDecoded!.width, 1280);
      expect(pausedDecoded.height, 720);
      expect(_hasVisiblePixels(pausedDecoded), isTrue);
      expect(_pngsDiffer(beforeDecoded!, pausedDecoded), isTrue,
          reason: 'PNG must reflect the committed path in the paused snapshot');
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pressStep(WidgetTester tester) async {
  final step = find.text('Step to candidate');
  Focus.of(tester.element(step)).requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

Future<File> _exportHdPng(
  WidgetTester tester,
  Directory exportDirectory,
) async {
  final existing = (await exportDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList())
      .map((file) => file.path)
      .toSet();
  final export = find.text('Export').last;
  Focus.of(tester.element(export)).requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Customize'));
  await tester.tap(find.text('Customize'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(ExportResolution.hd.displayName));
  await tester.tap(find.text(ExportResolution.hd.displayName));
  await tester.pumpAndSettle();
  final save = find.byKey(const ValueKey('exportSaveButton'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pump();
  for (var attempt = 0; attempt < 30; attempt++) {
    final files = await exportDirectory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    for (final file in files) {
      if (!existing.contains(file.path) &&
          file.path.contains('gaussian_prime_lattice') &&
          file.path.endsWith('.png')) return file;
    }
    await tester.pump(const Duration(seconds: 1));
  }
  fail('No Gaussian PNG saved in ${exportDirectory.path}');
}

bool _pngsDiffer(image.Image a, image.Image b) {
  if (a.width != b.width || a.height != b.height) return true;
  for (var y = 0; y < a.height; y += 2) {
    for (var x = 0; x < a.width; x += 2) {
      final left = a.getPixel(x, y);
      final right = b.getPixel(x, y);
      if (left.r != right.r ||
          left.g != right.g ||
          left.b != right.b ||
          left.a != right.a) return true;
    }
  }
  return false;
}

bool _hasVisiblePixels(image.Image decoded) {
  for (var y = 0; y < decoded.height; y += 4) {
    for (var x = 0; x < decoded.width; x += 4) {
      if (decoded.getPixel(x, y).a > 0) return true;
    }
  }
  return false;
}
