import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void runFlameReportCheck({
  required String moduleId,
  required String reportUrl,
  required String outputFolder,
}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('$moduleId report renders with fluid enabled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PaletteService.create();
    final registry = ModuleRegistry();
    final module = registry.byId(moduleId);
    final controller = FractalController(registry)
      ..selectModule(module, animate: false);
    final boundaryKey = GlobalKey();
    final sink = FractalRenderSnapshotSink();
    final output = Platform.isAndroid
        ? '${(await getExternalCacheDirectories())!.first.path}/$outputFolder'
        : (Platform.environment['FLAME_PREVIEW_DIR'] ??
            'build/test_output/$outputFolder-native');
    Directory(output).createSync(recursive: true);
    final reported = DeepLinkService.parseIncomingLink(reportUrl)!;
    final frames = <ui.FrameTiming>[];
    var timingsActive = false;
    void recordTimings(List<ui.FrameTiming> batch) => frames.addAll(batch);
    final evidence = <Map<String, Object?>>[];
    try {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: ChangeNotifierProvider.value(
                value: controller,
                child: FractalRenderer(
                  boundaryKey: boundaryKey,
                  gesturesEnabled: false,
                  animationEnabled: false,
                  showRendererIndicator: false,
                  renderSnapshotSink: sink,
                ),
              ),
            ),
          ),
        ),
      ));
      for (final isReport in [false, true]) {
        final name = isReport ? 'reported-fluid' : 'default';
        controller.applyPreset(isReport
            ? FractalPreset(
                id: 'reported',
                moduleId: module.id,
                name: 'Reported',
                params: reported.toParams(),
                view: reported.toViewState(),
                createdAt: DateTime.utc(2026, 10, 28),
              )
            : module.defaultPreset);
        controller.setFluidModeEnabled(isReport && reported.fluidModeEnabled!);
        controller.setFluidStrength(reported.fluidStrength!);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
        expect(sink.snapshot?.module.id, module.id);
        final capturedSnapshot = sink.snapshot!;
        final capturedView = capturedSnapshot.state.view;
        final requestedParams = Map<String, Object>.from(controller.params);
        final requestedIterations =
            (requestedParams['iterations'] as num).toInt();
        // These shallow-zoom fixtures exercise the existing mobile 160 cap,
        // not the higher iteration setting retained in the replayed controller.
        final expectedIterations = Platform.isAndroid || Platform.isIOS
            ? requestedIterations.clamp(4, 160)
            : requestedIterations;
        expect(capturedSnapshot.state.params,
            {...requestedParams, 'iterations': expectedIterations});
        expect(controller.fluidModeEnabled, isReport);
        final fluidShaderFilterActive = find
            .descendant(
              of: find.byType(FractalRenderer),
              matching: find.byType(ImageFiltered),
            )
            .evaluate()
            .isNotEmpty;
        expect(fluidShaderFilterActive,
            isReport && ui.ImageFilter.isShaderFilterSupported,
            reason: 'Distinguish the enabled flag from actual filter support.');
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final rgba =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
                .buffer
                .asUint8List();
        final colors = <int>{};
        var dark = 0;
        for (var i = 0; i < rgba.length; i += 4) {
          colors.add((rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2]);
          if (rgba[i] + rgba[i + 1] + rgba[i + 2] < 24) dark++;
        }
        final darkRatio = dark / (rgba.length ~/ 4);
        File('$output/$name.png').writeAsBytesSync(
          (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List(),
        );
        image.dispose();
        expect(colors.length, greaterThan(80));
        expect(darkRatio, inExclusiveRange(0.3, 0.99));
        frames.clear();
        WidgetsBinding.instance.addTimingsCallback(recordTimings);
        timingsActive = true;
        final zoom = controller.view.zoom;
        for (var i = 0; i < 20; i++) {
          controller.updateZoom(zoom * (1 + (i.isEven ? 0.002 : 0.004)));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pump(const Duration(milliseconds: 1200));
        WidgetsBinding.instance.removeTimingsCallback(recordTimings);
        timingsActive = false;
        final raster = frames
            .map((t) => t.rasterDuration.inMicroseconds / 1000)
            .toList()
          ..sort();
        expect(raster.length, greaterThanOrEqualTo(10),
            reason: 'Insufficient timing samples are not a performance result.');
        evidence.add({
          'view': name,
          'module': module.id,
          'requestedParams': requestedParams,
          'renderedParams': capturedSnapshot.state.params,
          'shaderTime': capturedSnapshot.time,
          'zoom': capturedView.zoom,
          'pan': [capturedView.pan.x, capturedView.pan.y],
          'rotation': [
            capturedView.rotation.x,
            capturedView.rotation.y,
            capturedView.rotation.z
          ],
          'devicePixelRatio': WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio,
          'fluidEnabled': controller.fluidModeEnabled,
          'fluidStrength': controller.fluidStrength,
          'shaderFilterSupported': ui.ImageFilter.isShaderFilterSupported,
          'fluidShaderFilterActive': fluidShaderFilterActive,
          'uniqueColors': colors.length,
          'darkPixelRatio': darkRatio,
          'timingSamples': raster.length,
          'rasterP50Ms': raster.isEmpty ? null : raster[raster.length ~/ 2],
          'rasterP95Ms':
              raster.isEmpty ? null : raster[(raster.length * .95).ceil() - 1],
          'timingScope':
              '20 small zoom changes at 320 logical pixels; this device/backend only',
          'image': '$output/$name.png',
        });
        print('FLAME_EVIDENCE ${jsonEncode(evidence.last)}');
        controller.updateZoom(zoom);
      }
      File('$output/report.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(evidence));
    } finally {
      if (timingsActive) {
        WidgetsBinding.instance.removeTimingsCallback(recordTimings);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });
}
