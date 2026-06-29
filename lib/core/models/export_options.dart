import 'package:equatable/equatable.dart';

/// Supported export image formats
enum ExportFormat {
  png,
  jpg,
  webp,
}

extension ExportFormatExtension on ExportFormat {
  String get extension {
    switch (this) {
      case ExportFormat.png:
        return 'png';
      case ExportFormat.jpg:
        return 'jpg';
      case ExportFormat.webp:
        return 'webp';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.png:
        return 'image/png';
      case ExportFormat.jpg:
        return 'image/jpeg';
      case ExportFormat.webp:
        return 'image/webp';
    }
  }

  String get displayName {
    switch (this) {
      case ExportFormat.png:
        return 'PNG';
      case ExportFormat.jpg:
        return 'JPG';
      case ExportFormat.webp:
        return 'WebP';
    }
  }
}

/// Shared export dimension validation.
///
/// Screen dimensions and user-provided custom dimensions must resolve through
/// the same upper bound. Otherwise a typed custom size can bypass the safety
/// clamp used for invalid screen metrics and request an unreplayably huge
/// capture surface.
class ExportDimensionPolicy {
  static const int maxPixelDimension = 1 << 30;

  const ExportDimensionPolicy._();

  static int positiveRoundedScreenDimension(double value) {
    if (!value.isFinite || value <= 0) return 1;
    return value.round().clamp(1, maxPixelDimension);
  }

  static int? positiveCustomDimension(int? value) {
    if (value == null || value <= 0) return null;
    return value.clamp(1, maxPixelDimension);
  }
}

/// Preset resolution options for export
enum ExportResolution {
  screen, // Current screen resolution
  hd, // 1280x720
  fullHd, // 1920x1080
  quadHd, // 2560x1440
  uhd4k, // 3840x2160
  instagram, // 1080x1080 (square)
  instagramStory, // 1080x1920 (9:16)
  twitter, // 1200x675 (16:9)
  custom,
}

extension ExportResolutionExtension on ExportResolution {
  String get displayName {
    switch (this) {
      case ExportResolution.screen:
        return 'Screen';
      case ExportResolution.hd:
        return 'HD (1280×720)';
      case ExportResolution.fullHd:
        return 'Full HD (1920×1080)';
      case ExportResolution.quadHd:
        return '2K (2560×1440)';
      case ExportResolution.uhd4k:
        return '4K (3840×2160)';
      case ExportResolution.instagram:
        return 'Instagram (1080×1080)';
      case ExportResolution.instagramStory:
        return 'Instagram Story (1080×1920)';
      case ExportResolution.twitter:
        return 'Twitter (1200×675)';
      case ExportResolution.custom:
        return 'Custom';
    }
  }

  /// Returns (width, height) for preset resolutions
  /// Returns null for screen (use device size) or custom (user specified)
  (int, int)? get dimensions {
    switch (this) {
      case ExportResolution.screen:
        return null;
      case ExportResolution.hd:
        return (1280, 720);
      case ExportResolution.fullHd:
        return (1920, 1080);
      case ExportResolution.quadHd:
        return (2560, 1440);
      case ExportResolution.uhd4k:
        return (3840, 2160);
      case ExportResolution.instagram:
        return (1080, 1080);
      case ExportResolution.instagramStory:
        return (1080, 1920);
      case ExportResolution.twitter:
        return (1200, 675);
      case ExportResolution.custom:
        return null;
    }
  }

  bool get isSocialPreset {
    return this == ExportResolution.instagram ||
        this == ExportResolution.instagramStory ||
        this == ExportResolution.twitter;
  }
}

/// Replayable export parameter snapshot for embedded metadata.
///
/// Export metadata may be created from live controller parameter maps. Snapshot
/// the map and common collection values at construction so EXIF/user-comment
/// provenance cannot drift if the controller changes before encoding or sharing
/// finishes.
final class ExportMetadataParameters {
  const ExportMetadataParameters._();

  static Map<String, Object> snapshot(Map<String, Object> parameters) {
    if (parameters.isEmpty) return const <String, Object>{};
    return Map<String, Object>.unmodifiable({
      for (final entry in parameters.entries)
        entry.key: _snapshotValue(entry.value) as Object,
    });
  }

  static Object? _snapshotValue(Object? value) {
    if (value is Map) {
      return Map<Object?, Object?>.unmodifiable({
        for (final entry in value.entries)
          _snapshotValue(entry.key): _snapshotValue(entry.value),
      });
    }
    if (value is List) {
      return List<Object?>.unmodifiable(value.map(_snapshotValue));
    }
    if (value is Set) {
      return Set<Object?>.unmodifiable(value.map(_snapshotValue));
    }
    return value;
  }
}

/// Metadata to embed in exported images
class ExportMetadata extends Equatable {
  final String? title;
  final String? description;
  final String fractalType;
  final Map<String, Object> parameters;
  final DateTime createdAt;
  final String appVersion;

  ExportMetadata({
    this.title,
    this.description,
    required this.fractalType,
    required Map<String, Object> parameters,
    required this.createdAt,
    this.appVersion = '1.0.0',
  }) : parameters = ExportMetadataParameters.snapshot(parameters);

  Map<String, String> toExifMap() {
    return {
      'Software': 'Flutter Fractals $appVersion',
      'ImageDescription':
          description ?? 'Fractal artwork created with Flutter Fractals',
      'Artist': 'Flutter Fractals',
      'Copyright': '© ${createdAt.year} Flutter Fractals',
      'UserComment': _buildUserComment(),
    };
  }

  String _buildUserComment() {
    final buffer = StringBuffer();
    buffer.writeln('Fractal Type: $fractalType');
    buffer.writeln('Created: ${createdAt.toIso8601String()}');
    buffer.writeln('Parameters:');
    for (final entry in parameters.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props =>
      [title, description, fractalType, parameters, createdAt, appVersion];
}

/// Complete export configuration
class ExportOptions extends Equatable {
  static const Object _unset = Object();

  final ExportFormat format;
  final ExportResolution resolution;
  final int? customWidth;
  final int? customHeight;
  final bool transparentBackground;
  final int quality; // 1-100, for JPG/WebP
  final bool embedMetadata;
  final ExportMetadata? metadata;
  final bool addWatermark;
  final String? watermarkText;
  final String? quoteText;

  const ExportOptions({
    this.format = ExportFormat.png,
    this.resolution = ExportResolution.screen,
    this.customWidth,
    this.customHeight,
    this.transparentBackground = false,
    this.quality = 95,
    this.embedMetadata = true,
    this.metadata,
    this.addWatermark = false,
    this.watermarkText,
    this.quoteText,
  });

  static T? _nullableCopyWithValue<T>({
    required Object? candidate,
    required T? currentValue,
    required String fieldName,
  }) {
    assert(
      identical(candidate, _unset) || candidate == null || candidate is T,
      '$fieldName must be a $T? value',
    );

    return identical(candidate, _unset) ? currentValue : candidate as T?;
  }

  int _customOrScreenDimension(int? customValue, double screenValue) {
    return ExportDimensionPolicy.positiveCustomDimension(customValue) ??
        ExportDimensionPolicy.positiveRoundedScreenDimension(screenValue);
  }

  double _safeDimensionRatio(int targetDimension, double screenDimension) {
    final safeScreenDimension =
        ExportDimensionPolicy.positiveRoundedScreenDimension(screenDimension);
    return targetDimension / safeScreenDimension;
  }

  bool _preservesPresetOrientation() {
    return resolution.isSocialPreset;
  }

  (int, int)? _orientedPresetDimensions(
      double screenWidth, double screenHeight) {
    final dims = resolution.dimensions;
    if (dims == null) return null;

    final width = dims.$1;
    final height = dims.$2;
    final isPresetSquare = width == height;
    if (isPresetSquare || _preservesPresetOrientation()) return dims;

    final screenPortrait = screenHeight > screenWidth;
    final presetPortrait = height > width;

    if (screenPortrait != presetPortrait) {
      return (height, width);
    }

    return dims;
  }

  /// Calculate the pixel ratio needed to achieve target resolution
  double calculatePixelRatio(double screenWidth, double screenHeight) {
    final dims = _orientedPresetDimensions(screenWidth, screenHeight);
    if (dims != null) {
      // Use the larger ratio to ensure we meet target resolution
      final widthRatio = _safeDimensionRatio(dims.$1, screenWidth);
      final heightRatio = _safeDimensionRatio(dims.$2, screenHeight);
      // Use max to ensure we hit the target resolution on both axes
      return (widthRatio > heightRatio ? widthRatio : heightRatio)
          .clamp(1.0, 8.0);
    }

    if (resolution == ExportResolution.custom) {
      final targetWidth = _customOrScreenDimension(customWidth, screenWidth);
      final targetHeight = _customOrScreenDimension(customHeight, screenHeight);
      final widthRatio = _safeDimensionRatio(targetWidth, screenWidth);
      final heightRatio = _safeDimensionRatio(targetHeight, screenHeight);
      return (widthRatio > heightRatio ? widthRatio : heightRatio)
          .clamp(1.0, 8.0);
    }

    return 1.0; // Screen resolution
  }

  /// Get the target dimensions for this export
  (int, int) getTargetDimensions(double screenWidth, double screenHeight) {
    final dims = _orientedPresetDimensions(screenWidth, screenHeight);
    if (dims != null) {
      return dims;
    }

    if (resolution == ExportResolution.custom) {
      return (
        _customOrScreenDimension(customWidth, screenWidth),
        _customOrScreenDimension(customHeight, screenHeight),
      );
    }

    // Screen resolution
    return (
      ExportDimensionPolicy.positiveRoundedScreenDimension(screenWidth),
      ExportDimensionPolicy.positiveRoundedScreenDimension(screenHeight),
    );
  }

  ExportOptions copyWith({
    ExportFormat? format,
    ExportResolution? resolution,
    Object? customWidth = _unset,
    Object? customHeight = _unset,
    bool? transparentBackground,
    int? quality,
    bool? embedMetadata,
    Object? metadata = _unset,
    bool? addWatermark,
    Object? watermarkText = _unset,
    Object? quoteText = _unset,
  }) {
    assert(
      identical(metadata, _unset) ||
          metadata == null ||
          metadata is ExportMetadata,
      'metadata must be an ExportMetadata? value',
    );
    assert(
      identical(watermarkText, _unset) ||
          watermarkText == null ||
          watermarkText is String,
      'watermarkText must be a String? value',
    );
    assert(
      identical(quoteText, _unset) || quoteText == null || quoteText is String,
      'quoteText must be a String? value',
    );

    return ExportOptions(
      format: format ?? this.format,
      resolution: resolution ?? this.resolution,
      customWidth: _nullableCopyWithValue<int>(
        candidate: customWidth,
        currentValue: this.customWidth,
        fieldName: 'customWidth',
      ),
      customHeight: _nullableCopyWithValue<int>(
        candidate: customHeight,
        currentValue: this.customHeight,
        fieldName: 'customHeight',
      ),
      transparentBackground:
          transparentBackground ?? this.transparentBackground,
      quality: quality ?? this.quality,
      embedMetadata: embedMetadata ?? this.embedMetadata,
      metadata: _nullableCopyWithValue<ExportMetadata>(
        candidate: metadata,
        currentValue: this.metadata,
        fieldName: 'metadata',
      ),
      addWatermark: addWatermark ?? this.addWatermark,
      watermarkText: _nullableCopyWithValue<String>(
        candidate: watermarkText,
        currentValue: this.watermarkText,
        fieldName: 'watermarkText',
      ),
      quoteText: _nullableCopyWithValue<String>(
        candidate: quoteText,
        currentValue: this.quoteText,
        fieldName: 'quoteText',
      ),
    );
  }

  @override
  List<Object?> get props => [
        format,
        resolution,
        customWidth,
        customHeight,
        transparentBackground,
        quality,
        embedMetadata,
        metadata,
        addWatermark,
        watermarkText,
        quoteText,
      ];
}

/// Predefined export presets for common use cases
class ExportPresets {
  static const socialShare = ExportOptions(
    format: ExportFormat.jpg,
    resolution: ExportResolution.instagram,
    quality: 90,
    embedMetadata: true,
  );

  static const highQualityPng = ExportOptions(
    format: ExportFormat.png,
    resolution: ExportResolution.uhd4k,
    embedMetadata: true,
  );

  static const webOptimized = ExportOptions(
    format: ExportFormat.webp,
    resolution: ExportResolution.fullHd,
    quality: 85,
    embedMetadata: true,
  );

  static const transparentOverlay = ExportOptions(
    format: ExportFormat.png,
    resolution: ExportResolution.fullHd,
    transparentBackground: true,
    embedMetadata: true,
  );
}
