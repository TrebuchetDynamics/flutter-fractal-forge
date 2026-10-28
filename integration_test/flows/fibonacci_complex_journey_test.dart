import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

Map<String, Object> viewJson(FractalViewState view) => {
      'pan': [view.pan.x, view.pan.y],
      'zoom': view.zoom,
      'rotation': [view.rotation.x, view.rotation.y, view.rotation.z],
    };

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Fibonacci catalog edits survive preset reopen and PNG export',
      (tester) async {
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    final output = const String.fromEnvironment('FIBONACCI_ARTIFACT_DIR');
    final directory = await Directory(output.isEmpty
            ? '${Platform.environment['FLUTTER_TEST_OUTPUTS_DIR']}/fibonacci'
            : output)
        .create(recursive: true);
    final saved = await Directory('${directory.path}/saved').create();
    await const ExportService().setPreferredExportDirectory(saved);
    final presets = await PresetStore.create();
    final accessibility = await AccessibilityService.create();
    final settings = await RendererSettingsService.create();
    final semantics = tester.ensureSemantics();
    final root = GlobalKey();
    final observations = <Object>[];
    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    }

    Future<void> capture(String name) async {
      await settle();
      expect(tester.takeException(), isNull, reason: name);
      final boundary =
          root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final frame = await boundary.toImage(pixelRatio: 1);
      final data = await frame.toByteData(format: ui.ImageByteFormat.png);
      await File('${directory.path}/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
      frame.dispose();
    }

    try {
      for (final spanish in [false, true]) {
        final locale = spanish ? 'es' : 'en';
        final size = Size(spanish ? 320 : 1280, 900);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = spanish ? 1.5 : 1;
        await binding.setSurfaceSize(size);
        await accessibility.setHighContrast(spanish);
        await accessibility.setReducedMotion(true);
        await tester.pumpWidget(RepaintBoundary(
          key: root,
          child: FlutterFractalsApp(
            presetStore: presets,
            accessibilityService: accessibility,
            rendererSettingsService: settings,
            locale: Locale(locale),
            skipSplash: true,
          ),
        ));
        await pumpForAppBoot(tester);
        await enterCatalogSearch(tester,
            spanish ? 'Julia de Fibonacci de grado primo' : 'Fibonacci prime');
        final card = catalogModuleCard('core.fibonacci_complex_julia');
        await tester.ensureVisible(card);
        await tester.tap(card);
        await settle();
        final renderer = find.byType(FractalRenderer);
        final controller = tester.element(renderer).read<FractalController>();
        final l10n = AppLocalizations.of(tester.element(renderer))!;
        expect(controller.params, containsPair('iterations', 45));
        expect(controller.params, containsPair('juliaCReal', -.2));
        expect(controller.params, containsPair('juliaCImag', .25));
        expect(controller.view.zoom, 1);
        await tester.tap(find.byKey(const ValueKey('viewerControlsButton')));
        await settle();
        final legend = find.textContaining('H_c(z,w) = (zw+c,z)');
        await tester.ensureVisible(legend);
        expect(legend, findsOneWidget);
        final text = tester.widget<Text>(legend).data!;
        expect(text, contains('F19 = 4181 = 37'));
        expect(text, contains(spanish ? 'no demuestra' : 'not proven'));
        expect(text, contains(spanish ? 'Dorado' : 'Gold'));
        await capture('$locale-legend');
        for (final label in [
          l10n.paramIterations,
          l10n.paramJuliaCReal,
          l10n.paramJuliaCImag
        ]) {
          final control = find.bySemanticsLabel(label);
          await tester.ensureVisible(control);
          final node = tester.getSemantics(control);
          tester.binding.performSemanticsAction(ui.SemanticsActionEvent(
            type: ui.SemanticsAction.decrease,
            nodeId: node.id,
            viewId: tester.view.viewId,
          ));
          await settle();
        }
        expect(controller.params['iterations'], 44);
        expect(controller.params['juliaCReal'], closeTo(-.21, 1e-9));
        expect(controller.params['juliaCImag'], closeTo(.24, 1e-9));
        await tester.tap(find.descendant(
            of: find.byType(FractalControlsHud),
            matching: find.byTooltip(l10n.semanticCloseButton)));
        await settle();
        await tester.drag(renderer, const Offset(35, 20));
        await tester.sendEventToBinding(PointerScrollEvent(
          position: tester.getCenter(renderer),
          scrollDelta: const Offset(0, 200),
        ));
        await settle();
        final editedParams = Map<String, Object>.from(controller.params);
        final editedView = viewJson(controller.view);
        expect(controller.view.zoom, isNot(1));
        expect(controller.view.pan.length, greaterThan(0));
        // A populated effective snapshot proves the real shader painted, not
        // merely that a GPU preference or a placeholder was selected.
        final effective = tester
            .widget<FractalRenderer>(renderer)
            .renderSnapshotSink!
            .snapshot!;
        expect(effective.module.id, 'fibonacci_complex_julia');
        expect(effective.state.params['iterations'], 44);
        await capture('$locale-edited-view');

        Future<List<int>> export(String name) async {
          final existing = saved.listSync().map((f) => f.path).toSet();
          await tester.tapAt(
              tester.getTopLeft(renderer) + const Offset(80, 200),
              buttons: 2,
              kind: ui.PointerDeviceKind.mouse);
          await settle();
          await tester.tap(find.text(l10n.contextMenuExport));
          await settle();
          final customize = find.text(l10n.exportButtonCustomize);
          await tester.ensureVisible(customize);
          await tester.tap(customize);
          await settle();
          final hd = find.text(l10n.exportResolutionHd);
          await tester.scrollUntilVisible(hd, 150,
              scrollable: find
                  .descendant(
                      of: find.byType(ExportOptionsSheet),
                      matching: find.byType(Scrollable))
                  .first);
          await Scrollable.ensureVisible(tester.element(hd), alignment: .5);
          await settle();
          await tester.tap(hd);
          await settle();
          final save = find.byKey(const ValueKey('exportSaveButton'));
          await tester.ensureVisible(save);
          await tester.tap(save);
          File? file;
          for (var i = 0; i < 300 && file == null; i++) {
            await tester.pump(const Duration(milliseconds: 100));
            final files = saved
                .listSync()
                .whereType<File>()
                .where((f) =>
                    f.path.endsWith('.png') && !existing.contains(f.path))
                .toList();
            if (files.isNotEmpty) file = files.single;
          }
          expect(file, isNotNull);
          final bytes = await file!.readAsBytes();
          final png =
              img.decodePng(bytes)!; // Reopen the actual committed file.
          expect([png.width, png.height], spanish ? [720, 1280] : [1280, 720]);
          final colors = png.map((p) => '${p.r},${p.g},${p.b}').toSet();
          expect(colors.length, greaterThan(6));
          expect(png.every((p) => p.a == 255), isTrue);
          await File('${directory.path}/$name.png').writeAsBytes(bytes);
          await settle();
          expect(controller.params, editedParams);
          expect(viewJson(controller.view), editedView);
          return png.getBytes(order: img.ChannelOrder.rgba);
        }

        Future<void> openPresets() async {
          await tester.tapAt(
              tester.getTopLeft(renderer) + const Offset(80, 200),
              buttons: 2,
              kind: ui.PointerDeviceKind.mouse);
          await settle();
          await tester.tap(find.text(l10n.contextMenuOpenPresets));
          await settle();
        }

        final before = await export('$locale-before-reopen');
        await openPresets();
        final name = 'Fibonacci $locale retained';
        await tester.enterText(
            find
                .descendant(
                    of: find.byType(PresetSheet),
                    matching: find.byType(TextField))
                .first,
            name);
        await settle();
        await tester.tap(find.text(l10n.savePreset).last);
        await settle();
        final stored = (await presets.loadUserPresets(controller.module.id))
            .singleWhere((p) => p.name == name);
        expect(stored.params, editedParams);
        expect(viewJson(stored.view), editedView);
        // Move to a genuinely different preset, then restore through its UI row.
        await tester.ensureVisible(find.text('c = 0'));
        await tester.tap(find.text('c = 0'));
        await settle();
        expect(controller.params['juliaCReal'], 0);
        await openPresets();
        await tester.ensureVisible(find.text(name));
        await tester.tap(find.text(name));
        await settle();
        expect(controller.params, editedParams);
        expect(viewJson(controller.view), editedView);
        expect(await export('$locale-after-reopen'), before);
        observations.add({
          'locale': locale,
          'viewport': [size.width, size.height],
          'textScale': spanish ? 1.5 : 1,
          'highContrast': spanish,
          'defaults': {
            'c': [-.2, .25],
            'N': 45,
            'zoom': 1
          },
          'legend': text,
          'params': editedParams,
          'view': editedView,
          'backend':
              'Flutter FragmentShader (see glxinfo for hardware/software)',
          'pngDimensions': spanish ? [720, 1280] : [1280, 720],
          'opaque': true,
          'restoredPixelsEqual': true,
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await settle();
      }
      final gl = await Process.run('glxinfo', ['-B']);
      await File('${directory.path}/glxinfo.txt')
          .writeAsString('${gl.stdout}\n${gl.stderr}');
      await File('${directory.path}/observations.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert({
        'source': const String.fromEnvironment('FIBONACCI_SOURCE'),
        'os': Platform.operatingSystemVersion,
        'dart': Platform.version,
        'fontSubstitution': false,
        'journeys': observations,
        'limits': [
          'Android and human qualification not run',
          'GPU alpha and CPU refusal covered by focused export tests'
        ],
      }));
    } finally {
      semantics.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await binding.setSurfaceSize(null);
    }
  });
}
