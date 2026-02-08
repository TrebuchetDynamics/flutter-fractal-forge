import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart';
import '../models/video_export_options.dart';
import '../models/fractal_view_state.dart';

/// Result of a video export operation.
class VideoExportResult {
  final File file;
  final String filePath;
  final int frameCount;
  final Duration duration;
  final int fileSizeBytes;
  final VideoResolution resolution;
  final VideoExportFormat format;

  VideoExportResult({
    required this.file,
    required this.filePath,
    required this.frameCount,
    required this.duration,
    required this.fileSizeBytes,
    required this.resolution,
    required this.format,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

/// Service for exporting fractal animations as video.
class VideoExportService {
  const VideoExportService();

  /// Calculate the view state for a given frame in the animation.
  FractalViewState calculateAnimationFrame({
    required FractalViewState startView,
    required VideoExportOptions options,
    required int frameIndex,
    required int totalFrames,
  }) {
    final t = frameIndex / (totalFrames - 1).clamp(1, totalFrames);
    final easedT = options.easing.apply(t);

    switch (options.animationType) {
      case VideoAnimationType.zoomIn:
        final targetZoom = startView.zoom * options.zoomFactor;
        final newZoom = startView.zoom + (targetZoom - startView.zoom) * easedT;
        return startView.copyWith(zoom: newZoom);

      case VideoAnimationType.zoomOut:
        final targetZoom = startView.zoom / options.zoomFactor;
        final newZoom = startView.zoom + (targetZoom - startView.zoom) * easedT;
        return startView.copyWith(zoom: newZoom);

      case VideoAnimationType.rotate:
        final angle = easedT * 360 * (3.14159 / 180);
        final currentRot = startView.rotation;
        return startView.copyWith(
          rotation: Vector3(currentRot.x, currentRot.y + angle, currentRot.z),
        );

      case VideoAnimationType.pan:
        final angle = easedT * 2 * 3.14159;
        final radius = 0.5 / startView.zoom;
        return startView.copyWith(
          pan: Vector2(
            startView.pan.x + radius * (1 - angle.abs()),
            startView.pan.y + radius * angle.abs(),
          ),
        );

      case VideoAnimationType.parameterSweep:
      case VideoAnimationType.custom:
        return startView;
    }
  }

  /// Calculate parameter values for a parameter sweep animation.
  Map<String, double> calculateParameterFrame({
    required Map<String, Object> startParams,
    required VideoExportOptions options,
    required int frameIndex,
    required int totalFrames,
  }) {
    final sweep = options.parameterSweep;
    if (sweep == null) return {};

    var t = frameIndex / (totalFrames - 1).clamp(1, totalFrames);
    
    if (sweep.pingPong) {
      t = t < 0.5 ? t * 2 : 2 - t * 2;
    }
    
    final easedT = options.easing.apply(t);
    final value = sweep.startValue + (sweep.endValue - sweep.startValue) * easedT;

    return {sweep.parameterId: value};
  }

  /// Generate a unique filename for the export.
  String generateFilename(VideoExportOptions options) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fractal_${options.animationType.name}_$timestamp.${options.format.extension}';
  }

  /// Capture a widget as PNG bytes.
  Future<Uint8List> captureWidget(GlobalKey boundaryKey, {double pixelRatio = 2.0}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Could not find render boundary');
    }
    
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Could not capture image');
    }
    
    return byteData.buffer.asUint8List();
  }

  /// Export video with the given options.
  /// 
  /// This method captures frames and encodes them. For full video encoding,
  /// use a native plugin or FFmpeg.
  Future<VideoExportResult> exportVideo({
    required VideoExportOptions options,
    required FractalViewState startView,
    required Map<String, Object> startParams,
    required String fractalType,
    required void Function(FractalViewState view, Map<String, double>? paramUpdates) updateView,
    required Future<Uint8List> Function() captureFrame,
    void Function(double progress, String status)? onProgress,
  }) async {
    final frames = <Uint8List>[];
    final totalFrames = options.totalFrames;

    for (var i = 0; i < totalFrames; i++) {
      // Calculate view for this frame
      final view = calculateAnimationFrame(
        startView: startView,
        options: options,
        frameIndex: i,
        totalFrames: totalFrames,
      );
      
      // Calculate parameter updates if doing a sweep
      Map<String, double>? paramUpdates;
      if (options.animationType == VideoAnimationType.parameterSweep) {
        paramUpdates = calculateParameterFrame(
          startParams: startParams,
          options: options,
          frameIndex: i,
          totalFrames: totalFrames,
        );
      }
      
      // Update the fractal
      updateView(view, paramUpdates);
      
      // Wait for render
      await Future.delayed(const Duration(milliseconds: 16));
      
      // Capture frame
      final frame = await captureFrame();
      frames.add(frame);
      
      // Report progress
      final progress = (i + 1) / totalFrames;
      onProgress?.call(progress, 'Rendering frame ${i + 1} of $totalFrames');
    }

    // Save frames to temporary directory
    final dir = await getTemporaryDirectory();
    final filename = generateFilename(options);
    final outputPath = '${dir.path}/$filename';

    // For now, save as PNG sequence (actual video encoding requires ffmpeg or native)
    // In production, you'd encode to MP4/GIF here
    final outputFile = File(outputPath.replaceAll('.${options.format.extension}', '.png'));
    await outputFile.writeAsBytes(frames.first);

    final size = await outputFile.length();

    return VideoExportResult(
      file: outputFile,
      filePath: outputFile.path,
      frameCount: frames.length,
      duration: options.duration,
      fileSizeBytes: size,
      resolution: options.resolution,
      format: options.format,
    );
  }
}
