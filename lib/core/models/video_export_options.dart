import 'package:flutter/material.dart';

/// Video export format.
enum VideoExportFormat {
  mp4('MP4', 'mp4'),
  gif('GIF', 'gif');

  final String label;
  final String extension;
  const VideoExportFormat(this.label, this.extension);
  
  String get displayName => label;
}

/// Animation type for video export.
enum VideoAnimationType {
  zoomIn('Zoom In', Icons.zoom_in),
  zoomOut('Zoom Out', Icons.zoom_out),
  rotate('Rotate', Icons.rotate_right),
  pan('Pan', Icons.pan_tool),
  parameterSweep('Parameter Sweep', Icons.tune),
  custom('Custom', Icons.settings);

  final String label;
  final IconData icon;
  const VideoAnimationType(this.label, this.icon);
}

/// Video resolution presets.
enum VideoResolution {
  sd(480, 'SD (480p)'),
  hd(720, 'HD (720p)'),
  fullHd(1080, 'Full HD (1080p)'),
  qhd(1440, 'QHD (1440p)');

  final int height;
  final String label;
  const VideoResolution(this.height, this.label);
  
  int get width => (height * 16 / 9).round();
}

/// Frame rate options.
enum VideoFrameRate {
  fps15(15),
  fps24(24),
  fps30(30),
  fps60(60);

  final int fps;
  const VideoFrameRate(this.fps);
  
  String get label => '$fps fps';
}

/// Quality presets.
enum VideoQualityPreset {
  draft('Draft', 0.5),
  standard('Standard', 0.7),
  high('High', 0.85),
  maximum('Maximum', 1.0);

  final String label;
  final double quality;
  const VideoQualityPreset(this.label, this.quality);
}

/// Animation easing functions.
enum AnimationEasing {
  linear('Linear'),
  easeIn('Ease In'),
  easeOut('Ease Out'),
  easeInOut('Ease In-Out');

  final String label;
  const AnimationEasing(this.label);

  double apply(double t) {
    return switch (this) {
      AnimationEasing.linear => t,
      AnimationEasing.easeIn => t * t,
      AnimationEasing.easeOut => 1 - (1 - t) * (1 - t),
      AnimationEasing.easeInOut => t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) / 2,
    };
  }
}

/// Configuration for parameter sweep animation.
class ParameterSweepConfig {
  final String parameterId;
  final double startValue;
  final double endValue;
  final bool pingPong;

  const ParameterSweepConfig({
    required this.parameterId,
    required this.startValue,
    required this.endValue,
    this.pingPong = false,
  });
}

/// Video export configuration options.
class VideoExportOptions {
  final VideoExportFormat format;
  final VideoAnimationType animationType;
  final VideoResolution resolution;
  final VideoFrameRate frameRate;
  final VideoQualityPreset quality;
  final AnimationEasing easing;
  final Duration duration;
  final double zoomFactor;
  final ParameterSweepConfig? parameterSweep;
  final bool loop;
  final bool includeWatermark;

  const VideoExportOptions({
    this.format = VideoExportFormat.mp4,
    this.animationType = VideoAnimationType.zoomIn,
    this.resolution = VideoResolution.fullHd,
    this.frameRate = VideoFrameRate.fps30,
    this.quality = VideoQualityPreset.high,
    this.easing = AnimationEasing.easeInOut,
    this.duration = const Duration(seconds: 5),
    this.zoomFactor = 10.0,
    this.parameterSweep,
    this.loop = false,
    this.includeWatermark = false,
  });

  VideoExportOptions copyWith({
    VideoExportFormat? format,
    VideoAnimationType? animationType,
    VideoResolution? resolution,
    VideoFrameRate? frameRate,
    VideoQualityPreset? quality,
    AnimationEasing? easing,
    Duration? duration,
    double? zoomFactor,
    ParameterSweepConfig? parameterSweep,
    bool? loop,
    bool? includeWatermark,
  }) {
    return VideoExportOptions(
      format: format ?? this.format,
      animationType: animationType ?? this.animationType,
      resolution: resolution ?? this.resolution,
      frameRate: frameRate ?? this.frameRate,
      quality: quality ?? this.quality,
      easing: easing ?? this.easing,
      duration: duration ?? this.duration,
      zoomFactor: zoomFactor ?? this.zoomFactor,
      parameterSweep: parameterSweep ?? this.parameterSweep,
      loop: loop ?? this.loop,
      includeWatermark: includeWatermark ?? this.includeWatermark,
    );
  }

  int get totalFrames => duration.inSeconds * frameRate.fps;
  
  /// Estimated file size in MB (rough approximation).
  double get estimatedSizeMb {
    final pixels = resolution.width * resolution.height;
    final bitsPerPixel = format == VideoExportFormat.gif ? 8.0 : 0.15;
    return (pixels * bitsPerPixel * totalFrames) / 8 / 1024 / 1024;
  }
}

/// Preset configurations for quick selection.
class VideoExportPresets {
  static const socialQuick = VideoExportOptions(
    format: VideoExportFormat.gif,
    resolution: VideoResolution.sd,
    frameRate: VideoFrameRate.fps15,
    duration: Duration(seconds: 3),
    quality: VideoQualityPreset.standard,
  );

  static const socialMp4 = VideoExportOptions(
    format: VideoExportFormat.mp4,
    resolution: VideoResolution.hd,
    frameRate: VideoFrameRate.fps30,
    duration: Duration(seconds: 5),
    quality: VideoQualityPreset.high,
  );

  static const highQuality = VideoExportOptions(
    format: VideoExportFormat.mp4,
    resolution: VideoResolution.fullHd,
    frameRate: VideoFrameRate.fps60,
    duration: Duration(seconds: 10),
    quality: VideoQualityPreset.maximum,
  );

  static const gifLoop = VideoExportOptions(
    format: VideoExportFormat.gif,
    resolution: VideoResolution.sd,
    frameRate: VideoFrameRate.fps24,
    duration: Duration(seconds: 4),
    loop: true,
  );
}
