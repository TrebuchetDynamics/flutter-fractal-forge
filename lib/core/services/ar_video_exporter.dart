import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_fractals/core/services/export_service.dart';

class ArVideoExporter {
  final ExportService _exportService;

  const ArVideoExporter({ExportService exportService = const ExportService()})
      : _exportService = exportService;

  Future<ArVideoExportResult?> recordBakedVideo({
    required CameraController cameraController,
    required GlobalKey overlayKey,
    required Duration duration,
    int fps = 30,
    double pixelRatio = 1.0,
    int targetShortSide = 720,
    ValueChanged<double>? onProgress,
  }) async {
    if (!cameraController.value.isInitialized) {
      return null;
    }
    if (cameraController.value.isRecordingVideo) {
      return null;
    }

    return _recordWithGifFallback(
      cameraController: cameraController,
      overlayKey: overlayKey,
      duration: duration,
      fps: fps,
      pixelRatio: pixelRatio,
      targetShortSide: targetShortSide,
      onProgress: onProgress,
    );
  }

  Future<ArVideoExportResult?> _recordWithGifFallback({
    required CameraController cameraController,
    required GlobalKey overlayKey,
    required Duration duration,
    required int fps,
    required double pixelRatio,
    required int targetShortSide,
    ValueChanged<double>? onProgress,
  }) async {
    onProgress?.call(0.0);
    // Pure-Dart fallback: builds a low-FPS GIF from camera frames + overlay.
    // Expect larger files, lower quality, and no audio.
    final fallbackFps = min(fps, 12);
    final frameIntervalMs = (1000 / fallbackFps).round();
    final targetFrames = (duration.inMilliseconds / frameIntervalMs).round();
    final frames = <img.Image>[];

    final sessionId = DateTime.now().millisecondsSinceEpoch;
    final outputFile =
        await _exportService.createExportFile(filename: 'ar_baked_$sessionId.gif');

    final completer = Completer<ArVideoExportResult?>();
    final stopwatch = Stopwatch()..start();
    var captured = 0;
    var processing = false;
    var finished = false;

    Future<void> finish() async {
      if (finished) return;
      finished = true;
      try {
        await cameraController.stopImageStream();
      } catch (_) {}
      try {
        if (frames.isEmpty) {
          completer.complete(null);
          return;
        }
        final firstFrame = frames.first;
        for (var i = 1; i < frames.length; i++) {
          firstFrame.addFrame(frames[i]);
        }
        final bytes = img.encodeGif(firstFrame);
        await outputFile.writeAsBytes(bytes, flush: true);
        onProgress?.call(1.0);
        completer.complete(
          ArVideoExportResult(
            file: outputFile,
            method: ArVideoExportMethod.dartGifFallback,
          ),
        );
      } catch (_) {
        completer.complete(null);
      }
    }

    await cameraController.startImageStream((CameraImage image) async {
      if (processing || finished) {
        return;
      }
      final targetMs = captured * frameIntervalMs;
      if (stopwatch.elapsedMilliseconds < targetMs) {
        return;
      }
      processing = true;
      try {
        final overlayBytes =
            await _exportService.capturePng(overlayKey, pixelRatio: pixelRatio);
        final overlayImage = img.decodePng(overlayBytes);
        final cameraImage = _convertCameraImage(image);
        if (overlayImage != null && cameraImage != null) {
          img.Image overlayScaled = overlayImage;
          if (overlayImage.width != cameraImage.width ||
              overlayImage.height != cameraImage.height) {
            overlayScaled = img.copyResize(
              overlayImage,
              width: cameraImage.width,
              height: cameraImage.height,
              interpolation: img.Interpolation.linear,
            );
          }
          final composed = img.compositeImage(
            cameraImage,
            overlayScaled,
          );

          final resized = _resizeForFallback(
            composed,
            targetShortSide: targetShortSide,
          );
          frames.add(resized);
          captured += 1;
          if (onProgress != null && targetFrames > 0) {
            onProgress((captured / targetFrames).clamp(0.0, 1.0));
          }
        }
        if (captured >= targetFrames) {
          await finish();
        }
      } catch (e, st) {
        dev.log('recordBakedVideo: frame capture failed: $e',
            name: 'FF.AR', error: e, stackTrace: st);
        // Fail gracefully: stop streaming and return null instead of crashing.
        await finish();
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      } finally {
        processing = false;
      }
    });

    Future.delayed(duration + const Duration(milliseconds: 500), () async {
      if (!finished) {
        await finish();
      }
    });

    return completer.future;
  }

  Future<void> _cleanupDirectory(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {}
    }
    try {
      await directory.delete(recursive: true);
    } catch (_) {}
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      final plane = image.planes.first;
      final converted = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: plane.bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
      return _rotateIfLandscape(converted);
    }
    if (image.format.group != ImageFormatGroup.yuv420) {
      return null;
    }
    final width = image.width;
    final height = image.height;
    final imageBuffer = img.Image(width: width, height: height);

    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];
    final bytesY = planeY.bytes;
    final bytesU = planeU.bytes;
    final bytesV = planeV.bytes;
    final yRowStride = planeY.bytesPerRow;
    final uvRowStride = planeU.bytesPerRow;
    final uvPixelStride = planeU.bytesPerPixel ?? 1;

    for (var y = 0; y < height; y++) {
      final yRow = y * yRowStride;
      final uvRow = (y >> 1) * uvRowStride;
      for (var x = 0; x < width; x++) {
        final yIndex = yRow + x;
        final uvIndex = uvRow + (x >> 1) * uvPixelStride;

        final yp = bytesY[yIndex];
        final up = bytesU[uvIndex];
        final vp = bytesV[uvIndex];

        final r = (yp + 1.402 * (vp - 128)).round();
        final g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
        final b = (yp + 1.772 * (up - 128)).round();

        imageBuffer.setPixelRgb(
          x,
          y,
          r.clamp(0, 255).toInt(),
          g.clamp(0, 255).toInt(),
          b.clamp(0, 255).toInt(),
        );
      }
    }
    return _rotateIfLandscape(imageBuffer);
  }

  img.Image _resizeForFallback(img.Image image, {required int targetShortSide}) {
    final target = targetShortSide <= 0 ? 720 : targetShortSide;
    if (image.width <= target && image.height <= target) {
      return image;
    }
    final width = image.width;
    final height = image.height;
    final landscape = width >= height;
    final ratio = landscape ? width / height : height / width;
    final newWidth = landscape ? (target * ratio).round() : target;
    final newHeight = landscape ? target : (target * ratio).round();
    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  img.Image _rotateIfLandscape(img.Image image) {
    if (image.width <= image.height) {
      return image;
    }
    return img.copyRotate(image, angle: 90);
  }
}

enum ArVideoExportMethod {
  ffmpeg,
  dartGifFallback,
}

class ArVideoExportResult {
  final File file;
  final ArVideoExportMethod method;

  const ArVideoExportResult({
    required this.file,
    required this.method,
  });
}
