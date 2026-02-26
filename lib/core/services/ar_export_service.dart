import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/services/export_service.dart';

class ArExportService {
  final ExportService _exportService;

  const ArExportService(this._exportService);

  Future<File> exportBakedScreenshot({
    required CameraController cameraController,
    required Uint8List overlayPng,
    required String filename,
  }) async {
    if (kIsWeb) throw UnsupportedError('exportBakedScreenshot is not supported on web');
    if (!cameraController.value.isInitialized) {
      throw StateError('Camera not initialized');
    }
    // Some camera implementations disallow takePicture while an image stream is active.
    if (cameraController.value.isStreamingImages) {
      try {
        await cameraController.stopImageStream();
      } catch (e) { if (kDebugMode) debugPrint('[FF] silent catch: $e'); }
    }
    final photoFile = await cameraController.takePicture();
    final photoBytes = await photoFile.readAsBytes();
    final baseImage = img.decodeImage(photoBytes);
    final overlayImage = img.decodePng(overlayPng);

    if (baseImage == null || overlayImage == null) {
      throw StateError('Failed to decode camera or overlay image');
    }

    img.Image overlayScaled = overlayImage;
    if (overlayImage.width != baseImage.width ||
        overlayImage.height != baseImage.height) {
      overlayScaled = img.copyResize(
        overlayImage,
        width: baseImage.width,
        height: baseImage.height,
        interpolation: img.Interpolation.linear,
      );
    }

    final composed = img.compositeImage(
      baseImage,
      overlayScaled,
    );

    final encoded = img.encodePng(composed);
    return _exportService.saveBytes(
      Uint8List.fromList(encoded),
      filename: filename,
    );
  }
}
