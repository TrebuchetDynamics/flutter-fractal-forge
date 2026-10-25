import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/features/number_walls/number_wall_presentation.dart';
import 'package:flutter_fractals/features/viewer/export/number_wall_export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final palettes = await PaletteService.create();
    addTearDown(palettes.dispose);
  });

  test('styling keeps exact large-prime zeros and the completed grid',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final module = controller.registry.byId('number_wall');
    await controller.loadState(
        module: module,
        params: {
          ...module.defaultPreset.params,
          'prime': '97',
          'rows': 4,
          'columns': 16,
        },
        view: module.defaultPreset.view);
    final grid = controller.numberWallGrid;
    for (final edit in {
      'colorMode': 1,
      'colorScheme': 3,
      'foregroundColor': 0x123456,
      'zeroColor': 0xfedcba,
      'backgroundColor': 0x112233,
      'showGrid': true
    }.entries) {
      controller.updateParam(edit.key, edit.value);
      expect(controller.numberWallPending, isFalse,
          reason: 'presentation edits must not even restart prime validation');
      expect(controller.params[edit.key], edit.value);
      expect(controller.numberWallGrid, same(grid));
    }
    final style = NumberWallStyle.fromParams(controller.params);
    expect(style.palette.first,
        PaletteService.instance.paletteAtIndex(3).stops.first.color);
    final hugePrime = BigInt.parse('170141183460469231731687303715884105727');
    expect(style.cellColor(BigInt.zero, hugePrime), const Color(0xfffedcba));
    expect(style.cellColor(BigInt.one, hugePrime), isNot(style.zero));
    expect(
        style.cellColor(hugePrime - BigInt.one, hugePrime), isNot(style.zero));
  });

  test(
      'frozen PNG rerasterizes viewer cells, viewport and background without recapture',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final module = controller.registry.byId('number_wall');
    await controller.loadState(
        module: module,
        params: {
          ...module.defaultPreset.params,
          'source': 'squares',
          'prime': '3',
          'rows': 4,
          'columns': 16,
          'foregroundColor': 0x123456,
          'zeroColor': 0xfedcba,
          'backgroundColor': 0x112233,
        },
        view: module.defaultPreset.view);
    controller.updateZoom(0.5);
    controller.updatePan(Vector2(0.1, -0.1));
    final capture = NumberWallExportCapture.freeze(controller);
    final grid = controller.numberWallGrid!;
    controller.updateParam('colorMode', 1);
    controller.updateParam('colorScheme', 3);
    controller.updateParam('showGrid', true);
    final binned = NumberWallExportCapture.freeze(controller);
    final pending = controller
        .applyNumberWallPrime('170141183460469231731687303715884105727');
    controller.cancelNumberWallRequest();
    await pending;
    await controller.loadState(
        moduleId: 'mandelbrot', params: {}, view: controller.view);
    final service = const ExportService().withRasterizer(
        (width, height, transparent) => capture.capturePng(
            width: width, height: height, transparentBackground: transparent));
    for (final size in [const Size(160, 80), const Size(240, 160)]) {
      for (final transparent in [false, true]) {
        final bytes = await service.captureWithOptions(GlobalKey(),
            options: ExportOptions(
                resolution: ExportResolution.custom,
                customWidth: size.width.toInt(),
                customHeight: size.height.toInt(),
                transparentBackground: transparent),
            screenWidth: 160,
            screenHeight: 80);
        final png = img.decodePng(bytes)!;
        expect(png.width, size.width.toInt());
        expect(png.height, size.height.toInt());
        final background = png.getPixel(0, 0);
        expect(background.a, transparent ? 0 : 255);
        if (!transparent)
          expect([background.r, background.g, background.b], [17, 34, 51]);
        // Independently paint the same frozen state through the viewer painter.
        final recorder = ui.PictureRecorder();
        NumberWallPainter(
                grid: grid,
                style: capture.style,
                view: capture.view,
                transparentBackground: transparent)
            .paint(Canvas(recorder), size);
        final picture = recorder.endRecording();
        final image =
            await picture.toImage(size.width.toInt(), size.height.toInt());
        final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final rect = numberWallFieldRect(size, capture.view);
        for (var row = 0; row < grid.rowCount; row++) {
          for (var col = 0; col < grid.columnCount; col++) {
            final x = (rect.left + (col + 0.5) * rect.width / grid.columnCount)
                .floor();
            final y =
                (rect.top + (row + 0.5) * rect.height / grid.rowCount).floor();
            final pixel = png.getPixel(x, y);
            final expected = grid.values[row][col] == BigInt.zero
                ? [254, 220, 186, 255]
                : [18, 52, 86, 255];
            expect([pixel.r, pixel.g, pixel.b, pixel.a], expected);
            final offset = (y * png.width + x) * 4;
            expect(raw!.buffer.asUint8List().sublist(offset, offset + 4),
                expected);
          }
        }
        image.dispose();
        picture.dispose();
      }
    }
    final binnedPng =
        img.decodePng(await binned.capturePng(width: 160, height: 80))!;
    final nonzero =
        binnedPng.getPixel(50, 21); // n=64, residue 1 => exact bin 85.
    final ink = binned.style.palette[85];
    expect([nonzero.r, nonzero.g, nonzero.b],
        [(ink.r * 255).round(), (ink.g * 255).round(), (ink.b * 255).round()]);
    final zero =
        binnedPng.getPixel(60, 21); // n=66 remains zero, not palette bin 0.
    expect([zero.r, zero.g, zero.b], [254, 220, 186]);
    expect(
        [binnedPng.getPixel(57, 21), binnedPng.getPixel(58, 21)]
            .any((p) => p.r == 17 && p.g == 34 && p.b == 51),
        isTrue);
    final token = ExportCancellationToken();
    final cancelled =
        capture.capturePng(width: 160, height: 80, cancellationToken: token);
    token.cancel(); // Revoke ownership while image readback is in flight.
    await expectLater(cancelled, throwsA(isA<ExportCancelledException>()));
  });
}
