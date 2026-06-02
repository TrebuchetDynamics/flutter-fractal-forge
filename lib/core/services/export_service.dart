import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_fractals/core/models/export_options.dart';

/// Replayable filename contract for exported files.
///
/// Both caller-supplied prefix and fractal type become path-safe filename
/// segments. Empty or fully-unsafe prefixes fall back to `fractal` so the
/// generated filename is never hidden, absolute, or parent-relative.
class ExportFilenameParts {
  final String prefix;
  final ExportFormat format;
  final String? fractalType;
  final int timestampMillis;

  const ExportFilenameParts({
    required this.prefix,
    required this.format,
    required this.timestampMillis,
    this.fractalType,
  });

  String get safePrefix => _sanitizeSegment(prefix, fallback: 'fractal')!;

  String? get safeFractalType {
    final value = fractalType;
    if (value == null) return null;
    return _sanitizeSegment(value, fallback: null);
  }

  String get filename {
    final type = safeFractalType;
    final typePart = type == null ? '' : '_$type';
    return '$safePrefix${typePart}_$timestampMillis.${format.extension}';
  }

  static String? _sanitizeSegment(String value, {required String? fallback}) {
    final sanitized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[_\-.]+|[_\-.]+$'), '');
    if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
      return fallback;
    }
    return sanitized;
  }
}

enum _WallpaperOverlayEdge { top, bottom }

/// Replayable vertical gradient used by wallpaper legibility overlays.
///
/// A one-row overlay should still apply full edge strength. For taller overlays,
/// the outer edge reaches [strength] and the inner edge fades to transparent.
final class _WallpaperOverlayGradient {
  final int imageHeight;
  final double coverage;
  final double strength;
  final _WallpaperOverlayEdge edge;

  const _WallpaperOverlayGradient({
    required this.imageHeight,
    required this.coverage,
    required this.strength,
    required this.edge,
  }) : assert(imageHeight > 0, 'imageHeight must be positive');

  int get overlayHeight =>
      (imageHeight * coverage).round().clamp(1, imageHeight).toInt();

  int get startY =>
      edge == _WallpaperOverlayEdge.top ? 0 : imageHeight - overlayHeight;

  int get endYExclusive =>
      edge == _WallpaperOverlayEdge.top ? overlayHeight : imageHeight;

  int alphaForY(int y) {
    final localY = y - startY;
    final edgeWeight = _edgeWeight(localY);
    return (255 * strength * edgeWeight).round().clamp(0, 255).toInt();
  }

  double _edgeWeight(int localY) {
    if (overlayHeight <= 1) return 1.0;

    final progress = (localY / (overlayHeight - 1)).clamp(0.0, 1.0);
    return switch (edge) {
      _WallpaperOverlayEdge.top => 1.0 - progress,
      _WallpaperOverlayEdge.bottom => progress,
    };
  }
}

class ExportService {
  static const MethodChannel _mediaStoreChannel =
      MethodChannel('fractalforge/media_store');
  const ExportService();

  /// Returns the actual format we can encode today.
  ///
  /// WebP is exposed in the UI, but the current pure-Dart image pipeline
  /// cannot encode WebP yet. We explicitly fall back to PNG so filename,
  /// MIME expectations, and snackbar text stay truthful.
  ExportFormat resolveEffectiveFormat(ExportFormat requested) {
    if (requested == ExportFormat.webp) {
      return ExportFormat.png;
    }
    return requested;
  }

  /// Apply simple legibility overlays for wallpaper usage.
  ///
  /// This keeps the fractal intact while slightly darkening common UI areas.
  Uint8List applyWallpaperStyle(Uint8List pngBytes, {required String style}) {
    try {
      final decoded = img.decodePng(pngBytes);
      if (decoded == null) return pngBytes;

      // style: plain|homeOptimized|lockOptimized
      switch (style) {
        case 'homeOptimized':
          return Uint8List.fromList(
              img.encodePng(_applyBottomGradient(decoded, strength: 0.28)));
        case 'lockOptimized':
          var out = _applyTopGradient(decoded, strength: 0.30);
          out = _applyBottomGradient(out, strength: 0.18);
          return Uint8List.fromList(img.encodePng(out));
        default:
          return pngBytes;
      }
    } catch (_) {
      // If any processing fails, return original bytes.
      return pngBytes;
    }
  }

  img.Image _applyTopGradient(img.Image src, {required double strength}) {
    return _applyVerticalGradient(
      src,
      gradient: _WallpaperOverlayGradient(
        imageHeight: src.height,
        coverage: 0.22,
        strength: strength,
        edge: _WallpaperOverlayEdge.top,
      ),
    );
  }

  img.Image _applyBottomGradient(img.Image src, {required double strength}) {
    return _applyVerticalGradient(
      src,
      gradient: _WallpaperOverlayGradient(
        imageHeight: src.height,
        coverage: 0.28,
        strength: strength,
        edge: _WallpaperOverlayEdge.bottom,
      ),
    );
  }

  img.Image _applyVerticalGradient(
    img.Image src, {
    required _WallpaperOverlayGradient gradient,
  }) {
    final out = img.Image.from(src);

    for (int y = gradient.startY; y < gradient.endYExclusive; y++) {
      final alpha = gradient.alphaForY(y);
      if (alpha == 0) continue;

      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);
        // Alpha-blend black over pixel (new image package API).
        final r = _darkenChannel(p.r.toInt(), alpha);
        final g = _darkenChannel(p.g.toInt(), alpha);
        final b = _darkenChannel(p.b.toInt(), alpha);
        out.setPixelRgba(x, y, r, g, b, p.a.toInt());
      }
    }

    return out;
  }

  int _darkenChannel(int value, int alpha) {
    return (value * (255 - alpha) / 255).round();
  }

  Future<Directory> getExportDirectory() async {
    if (!kIsWeb && Platform.isAndroid) {
      // Avoid runtime storage permission prompts. Use app-scoped external
      // pictures dir when available; otherwise fall back to app documents.
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.pictures,
      );
      final baseDir = dirs?.isNotEmpty == true ? dirs!.first : null;
      if (baseDir != null) {
        final exportDir = Directory('${baseDir.path}/FlutterFractals');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<File> createExportFile({required String filename}) async {
    final dir = await getExportDirectory();
    return File('${dir.path}/$filename');
  }

  /// Capture the widget as raw RGBA bytes at the specified pixel ratio
  Future<Uint8List> capturePng(GlobalKey boundaryKey,
      {double pixelRatio = 2.0}) async {
    Object? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        RenderRepaintBoundary? boundary = boundaryKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          throw StateError('Boundary not found');
        }

        // Defensive: boundary.toImage() can throw if the layer hasn't painted yet.
        if (boundary.debugNeedsPaint) {
          await WidgetsBinding.instance.endOfFrame;
          boundary = boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
          if (boundary == null) {
            throw StateError('Boundary not found');
          }
        }

        final image = await boundary.toImage(pixelRatio: pixelRatio);
        try {
          final byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData == null) {
            throw StateError('Failed to encode PNG');
          }
          return byteData.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      } catch (error) {
        lastError = error;
        if (attempt == 2) {
          rethrow;
        }
        await WidgetsBinding.instance.endOfFrame;
      }
    }

    throw StateError('Failed to capture PNG: $lastError');
  }

  /// Capture with advanced options (format, resolution, metadata)
  Future<Uint8List> captureWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);

    // Calculate pixel ratio for target resolution
    final pixelRatio = options.calculatePixelRatio(screenWidth, screenHeight);

    // Capture raw PNG from Flutter
    final rawPng = await capturePng(boundaryKey, pixelRatio: pixelRatio);
    onProgress?.call(0.4);

    // Decode the PNG for processing
    final decodedImage = img.decodePng(rawPng);
    if (decodedImage == null) {
      throw StateError('Failed to decode captured image');
    }
    onProgress?.call(0.5);

    // Resize if needed for target resolution
    final targetDims = options.getTargetDimensions(screenWidth, screenHeight);
    img.Image processedImage;

    if (decodedImage.width != targetDims.$1 ||
        decodedImage.height != targetDims.$2) {
      processedImage = img.copyResize(
        decodedImage,
        width: targetDims.$1,
        height: targetDims.$2,
        interpolation: img.Interpolation.cubic,
      );
    } else {
      processedImage = decodedImage;
    }
    onProgress?.call(0.6);

    // Add watermark if requested
    if (options.addWatermark && options.watermarkText != null) {
      processedImage = _addWatermark(processedImage, options.watermarkText!);
    }
    onProgress?.call(0.7);

    // Embed metadata
    if (options.embedMetadata && options.metadata != null) {
      processedImage = _embedMetadata(processedImage, options.metadata!);
    }
    onProgress?.call(0.8);

    // Encode to target format
    final effectiveFormat = resolveEffectiveFormat(options.format);
    final encoded = _encodeToFormat(processedImage, options, effectiveFormat);
    onProgress?.call(1.0);

    return Uint8List.fromList(encoded);
  }

  img.Image _addWatermark(img.Image image, String text) {
    // Simple text watermark in bottom-right corner
    final fontSize = (image.width / 40).round().clamp(12, 48);
    final padding = fontSize;

    img.drawString(
      image,
      text,
      font: img.arial14,
      x: image.width - (text.length * fontSize ~/ 2) - padding,
      y: image.height - fontSize - padding,
      color: img.ColorRgba8(255, 255, 255, 128),
    );

    return image;
  }

  img.Image _embedMetadata(img.Image image, ExportMetadata metadata) {
    // The image package stores metadata in the image object
    // This will be preserved when encoding to formats that support it
    final exifData = metadata.toExifMap();

    // Add metadata as text chunks (supported in PNG)
    for (final entry in exifData.entries) {
      image.textData ??= {};
      image.textData![entry.key] = entry.value;
    }

    return image;
  }

  Uint8List _encodeToFormat(
    img.Image image,
    ExportOptions options,
    ExportFormat effectiveFormat,
  ) {
    switch (effectiveFormat) {
      case ExportFormat.png:
        return Uint8List.fromList(img.encodePng(image, level: 6));

      case ExportFormat.jpg:
        // JPG doesn't support transparency - always composite onto background
        // transparentBackground option is ignored for JPG (use black background)
        final rgbImage = _removeAlpha(image);
        return Uint8List.fromList(
          img.encodeJpg(rgbImage, quality: options.quality),
        );

      case ExportFormat.webp:
        // Guard rail: resolveEffectiveFormat currently maps WebP->PNG.
        return Uint8List.fromList(img.encodePng(image));
    }
  }

  img.Image _removeAlpha(img.Image image) {
    // Create a new RGB image (no alpha channel) for JPG export
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );

    // Fill with black (space around fractals is typically black/transparent)
    img.fill(result, color: img.ColorRgb8(0, 0, 0));

    // Composite the original image over the black background
    img.compositeImage(result, image);

    return result;
  }

  /// Generate a filename with timestamp and format extension
  String generateFilename({
    String prefix = 'fractal',
    required ExportFormat format,
    String? fractalType,
  }) {
    return ExportFilenameParts(
      prefix: prefix,
      format: format,
      fractalType: fractalType,
      timestampMillis: DateTime.now().millisecondsSinceEpoch,
    ).filename;
  }

  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    final file = await createExportFile(filename: filename);
    final written = await file.writeAsBytes(bytes, flush: true);
    await _mirrorImageToMediaStoreIfNeeded(bytes, filename);
    return written;
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }

  bool _isImageFilename(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  String _mimeTypeForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/png';
  }

  Future<void> _mirrorImageToMediaStoreIfNeeded(
    Uint8List bytes,
    String filename,
  ) async {
    if (kIsWeb || !Platform.isAndroid || !_isImageFilename(filename)) {
      return;
    }

    try {
      await _mediaStoreChannel.invokeMethod<String>('saveImage', {
        'bytes': bytes,
        'filename': filename,
        'mimeType': _mimeTypeForFilename(filename),
      });
    } catch (_) {
      // Best-effort only: keep local export path working even if MediaStore fails.
    }
  }

  /// Export with full options and sharing
  Future<ExportResult> exportWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    required String fractalType,
    required Map<String, Object> parameters,
    void Function(double progress)? onProgress,
  }) async {
    // Create metadata if embedding is enabled
    final metadata = options.embedMetadata
        ? ExportMetadata(
            fractalType: fractalType,
            parameters: parameters,
            createdAt: DateTime.now(),
          )
        : null;

    final effectiveFormat = resolveEffectiveFormat(options.format);

    final finalOptions = options.copyWith(
      metadata: metadata,
      format: effectiveFormat,
    );

    // Capture and process the image
    final bytes = await captureWithOptions(
      boundaryKey,
      options: finalOptions,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onProgress: onProgress,
    );

    // Generate filename and save
    final filename = generateFilename(
      format: effectiveFormat,
      fractalType: fractalType,
    );

    final file = await saveBytes(bytes, filename: filename);
    final targetDims =
        finalOptions.getTargetDimensions(screenWidth, screenHeight);

    return ExportResult(
      file: file,
      format: effectiveFormat,
      width: targetDims.$1,
      height: targetDims.$2,
      fileSize: bytes.length,
    );
  }
}

/// Result of an export operation
class ExportResult {
  final File file;
  final ExportFormat format;
  final int width;
  final int height;
  final int fileSize;

  const ExportResult({
    required this.file,
    required this.format,
    required this.width,
    required this.height,
    required this.fileSize,
  });

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get resolution => '$width×$height';
}
