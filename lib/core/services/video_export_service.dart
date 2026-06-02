import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;
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
    if (fileSizeBytes < 1024 * 1024)
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

/// Replayable frame timeline contract for video animations.
class VideoFrameTimeline {
  const VideoFrameTimeline._();

  /// Returns normalized progress in [0, 1] for a frame sequence.
  ///
  /// A single-frame export is defined as the start of the animation. This keeps
  /// frame interpolation deterministic without dividing by zero.
  static double progress({
    required int frameIndex,
    required int totalFrames,
  }) {
    if (totalFrames <= 0) {
      throw ArgumentError('Invalid totalFrames: $totalFrames');
    }
    if (totalFrames == 1) {
      return 0.0;
    }

    return (frameIndex / (totalFrames - 1)).clamp(0.0, 1.0).toDouble();
  }
}

/// Replayable zoom-factor contract for zoom-in/zoom-out video animations.
///
/// Zoom factors below 1.0 invert the selected animation direction, while
/// zero/non-finite factors produce invalid zooms. Treat malformed factors as a
/// neutral 1.0x movement so stale/custom options cannot poison captured frames.
class VideoZoomFactor {
  static const double neutral = 1.0;

  const VideoZoomFactor._();

  static double normalize(double zoomFactor) {
    if (!zoomFactor.isFinite || zoomFactor < neutral) return neutral;
    return zoomFactor;
  }
}

/// Replayable start-zoom contract for video animation frames.
///
/// Stored or caller-provided views can bypass controller zoom clamps. Normalize
/// at the export-frame boundary so interpolation and pan-orbit radius math never
/// emit NaN/Infinity to the caller's update callback.
class VideoStartZoom {
  static const double neutral = 1.0;

  const VideoStartZoom._();

  static double normalize(double zoom) {
    if (!zoom.isFinite || zoom <= 0.0) return neutral;
    return zoom;
  }

  static double panOrbitRadius(double zoom) => 0.5 / normalize(zoom);
}

/// Replayable parameter-sweep frame contract for video animations.
///
/// [VideoExportService.calculateParameterFrame] hands updates to an arbitrary
/// caller callback, so malformed sweep configs must be contained here instead
/// of relying on a later controller to reject NaN/Infinity or empty IDs.
class VideoParameterSweepPlan {
  final String parameterId;
  final double startValue;
  final double endValue;
  final double timelineProgress;
  final double sweepProgress;
  final double easedProgress;
  final double value;

  const VideoParameterSweepPlan._({
    required this.parameterId,
    required this.startValue,
    required this.endValue,
    required this.timelineProgress,
    required this.sweepProgress,
    required this.easedProgress,
    required this.value,
  });

  factory VideoParameterSweepPlan.fromSweep({
    required ParameterSweepConfig sweep,
    required AnimationEasing easing,
    required double timelineProgress,
  }) {
    final sweepProgress = sweep.pingPong
        ? timelineProgress < 0.5
            ? timelineProgress * 2
            : 2 - timelineProgress * 2
        : timelineProgress;
    final easedProgress = easing.apply(sweepProgress);
    final value =
        sweep.startValue + (sweep.endValue - sweep.startValue) * easedProgress;

    return VideoParameterSweepPlan._(
      parameterId: sweep.parameterId,
      startValue: sweep.startValue,
      endValue: sweep.endValue,
      timelineProgress: timelineProgress,
      sweepProgress: sweepProgress,
      easedProgress: easedProgress,
      value: value,
    );
  }

  bool get isReplayable {
    return parameterId.isNotEmpty &&
        startValue.isFinite &&
        endValue.isFinite &&
        timelineProgress.isFinite &&
        sweepProgress.isFinite &&
        easedProgress.isFinite &&
        value.isFinite;
  }

  Map<String, double> toUpdates() {
    if (!isReplayable) return const {};
    return {parameterId: value};
  }
}

/// Replayable encoding contract for video exports.
///
/// MP4 is selectable in the public options model, but this Dart-only exporter
/// currently has a GIF encoder. Keep the fallback explicit so output filename,
/// bytes, and reported format cannot silently drift apart.
class VideoExportEncodingPlan {
  final VideoExportFormat requestedFormat;
  final VideoExportFormat effectiveFormat;

  const VideoExportEncodingPlan._({
    required this.requestedFormat,
    required this.effectiveFormat,
  });

  factory VideoExportEncodingPlan.forFormat(
    VideoExportFormat requestedFormat,
  ) {
    return VideoExportEncodingPlan._(
      requestedFormat: requestedFormat,
      effectiveFormat: switch (requestedFormat) {
        VideoExportFormat.gif => VideoExportFormat.gif,
        VideoExportFormat.mp4 => VideoExportFormat.gif,
      },
    );
  }

  bool get usesFallback => requestedFormat != effectiveFormat;

  VideoExportOptions applyTo(VideoExportOptions options) {
    if (options.format == effectiveFormat) return options;
    return options.copyWith(format: effectiveFormat);
  }
}

/// Service for exporting fractal animations as video.
class VideoExportService {
  const VideoExportService();

  /// Returns the format this Dart-only exporter can encode today.
  VideoExportFormat resolveEffectiveFormat(VideoExportFormat requested) {
    return VideoExportEncodingPlan.forFormat(requested).effectiveFormat;
  }

  VideoExportEncodingPlan encodingPlanFor(VideoExportOptions options) {
    return VideoExportEncodingPlan.forFormat(options.format);
  }

  /// Calculate the view state for a given frame in the animation.
  FractalViewState calculateAnimationFrame({
    required FractalViewState startView,
    required VideoExportOptions options,
    required int frameIndex,
    required int totalFrames,
  }) {
    final t = VideoFrameTimeline.progress(
      frameIndex: frameIndex,
      totalFrames: totalFrames,
    );
    final easedT = options.easing.apply(t);
    final startZoom = VideoStartZoom.normalize(startView.zoom);
    final replayableStartView = startZoom == startView.zoom
        ? startView
        : startView.copyWith(zoom: startZoom);

    switch (options.animationType) {
      case VideoAnimationType.zoomIn:
        final zoomFactor = VideoZoomFactor.normalize(options.zoomFactor);
        final targetZoom = startZoom * zoomFactor;
        final newZoom = startZoom + (targetZoom - startZoom) * easedT;
        return replayableStartView.copyWith(zoom: newZoom);

      case VideoAnimationType.zoomOut:
        final zoomFactor = VideoZoomFactor.normalize(options.zoomFactor);
        final targetZoom = startZoom / zoomFactor;
        final newZoom = startZoom + (targetZoom - startZoom) * easedT;
        return replayableStartView.copyWith(zoom: newZoom);

      case VideoAnimationType.rotate:
        final angle = easedT * 2 * math.pi;
        final currentRot = replayableStartView.rotation;
        return replayableStartView.copyWith(
          rotation: Vector3(currentRot.x, currentRot.y + angle, currentRot.z),
        );

      case VideoAnimationType.pan:
        final angle = easedT * 2 * math.pi;
        final radius = VideoStartZoom.panOrbitRadius(startView.zoom);
        return replayableStartView.copyWith(
          pan: Vector2(
            replayableStartView.pan.x + radius * math.cos(angle),
            replayableStartView.pan.y + radius * math.sin(angle),
          ),
        );

      case VideoAnimationType.parameterSweep:
      case VideoAnimationType.custom:
        return replayableStartView;
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

    final timelineProgress = VideoFrameTimeline.progress(
      frameIndex: frameIndex,
      totalFrames: totalFrames,
    );
    final plan = VideoParameterSweepPlan.fromSweep(
      sweep: sweep,
      easing: options.easing,
      timelineProgress: timelineProgress,
    );

    return plan.toUpdates();
  }

  /// Generate a unique filename for the export.
  String generateFilename(VideoExportOptions options) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fractal_${options.animationType.name}_$timestamp.${options.format.extension}';
  }

  /// Capture a widget as PNG bytes.
  Future<Uint8List> captureWidget(GlobalKey boundaryKey,
      {double pixelRatio = 2.0}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
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
    required void Function(
            FractalViewState view, Map<String, double>? paramUpdates)
        updateView,
    required Future<Uint8List> Function() captureFrame,
    void Function(double progress, String status)? onProgress,
  }) async {
    if (kIsWeb) throw UnsupportedError('exportVideo is not supported on web');
    final encodingPlan = encodingPlanFor(options);
    final effectiveOptions = encodingPlan.applyTo(options);
    final totalFrames = options.totalFrames;

    // Capture and decode frames incrementally to avoid RAM exhaustion
    final decodedFrames = <img.Image>[];

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
      final frameBytes = await captureFrame();

      // Decode immediately and release raw bytes
      final decoded = img.decodePng(frameBytes);
      if (decoded == null) {
        throw Exception('Failed to decode frame $i');
      }
      decodedFrames.add(decoded);

      // Report progress
      final progress = (i + 1) / totalFrames;
      onProgress?.call(progress, 'Rendering frame ${i + 1} of $totalFrames');
    }

    final bytes = _encodeFrames(decodedFrames, encodingPlan.effectiveFormat);

    // Save to file
    final dir = await getTemporaryDirectory();
    final filename = generateFilename(effectiveOptions);
    final outputPath = '${dir.path}/$filename';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(bytes);

    final size = await outputFile.length();

    return VideoExportResult(
      file: outputFile,
      filePath: outputFile.path,
      frameCount: decodedFrames.length,
      duration: options.duration,
      fileSizeBytes: size,
      resolution: options.resolution,
      format: encodingPlan.effectiveFormat,
    );
  }

  Uint8List _encodeFrames(
    List<img.Image> decodedFrames,
    VideoExportFormat effectiveFormat,
  ) {
    if (decodedFrames.isEmpty) {
      throw StateError('Cannot encode video export without frames');
    }

    switch (effectiveFormat) {
      case VideoExportFormat.gif:
        final firstFrame = decodedFrames.first;
        for (var i = 1; i < decodedFrames.length; i++) {
          firstFrame.addFrame(decodedFrames[i]);
        }
        return Uint8List.fromList(img.encodeGif(firstFrame));
      case VideoExportFormat.mp4:
        throw UnsupportedError('MP4 encoding is not available');
    }
  }
}
