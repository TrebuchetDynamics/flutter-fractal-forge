import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/features/number_walls/number_wall_presentation.dart';

/// Owns exactly the committed field, materialized palette and viewport from
/// sheet opening. Neither navigation nor a late validation job can replace it.
class NumberWallExportCapture {
  NumberWallExportCapture._(
      this.module, this.grid, this.style, this.view, this.params);

  factory NumberWallExportCapture.freeze(FractalController controller) {
    if (controller.module.id != 'number_wall' ||
        controller.numberWallGrid == null) {
      throw StateError('No completed Number Wall to export.');
    }
    controller.cancelNumberWallRequest();
    return NumberWallExportCapture._(
        controller.module,
        controller.numberWallGrid!,
        NumberWallStyle.fromParams(controller.params),
        controller.view.copyWith(),
        Map.unmodifiable(controller.params));
  }

  final FractalModule module;
  final NumberWallGrid grid;
  final NumberWallStyle style;
  final FractalViewState view;
  final Map<String, Object> params;

  Future<Uint8List> capturePng(
      {required int width,
      required int height,
      bool transparentBackground = false,
      ExportCancellationToken? cancellationToken}) async {
    cancellationToken?.throwIfCancelled();
    ExportSizePolicy.validateTargetDimensions(width, height);
    final recorder = ui.PictureRecorder();
    NumberWallPainter(
            grid: grid,
            style: style,
            view: view,
            transparentBackground: transparentBackground)
        .paint(
            ui.Canvas(recorder), ui.Size(width.toDouble(), height.toDouble()));
    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(width, height);
      cancellationToken?.throwIfCancelled();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      cancellationToken?.throwIfCancelled();
      if (data == null) throw StateError('Could not encode Number Wall PNG.');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      ExportSizePolicy.validateEncodedByteLength(bytes.lengthInBytes);
      return bytes;
    } finally {
      image?.dispose();
      picture.dispose();
    }
  }
}
