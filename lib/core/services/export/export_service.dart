import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export/share_service.dart';
import 'package:flutter_fractals/shared/utils/byte_format.dart';
import 'package:flutter_fractals/shared/utils/slugify.dart';

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

  String get safePrefix =>
      slugify(prefix, allowHyphen: true, emptyFallback: 'fractal')!;

  String? get safeFractalType {
    final value = fractalType;
    if (value == null) return null;
    return slugify(value, allowHyphen: true, emptyFallback: null);
  }

  String get filename {
    final type = safeFractalType;
    final typePart = type == null ? '' : '_$type';
    return '$safePrefix${typePart}_$timestampMillis.${format.extension}';
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

/// Pure center-crop geometry for matching a capture to an export aspect ratio.
///
/// The export capture is taken at the screen aspect ratio. Scaling it straight
/// to a preset of a different aspect would stretch the fractal, so the capture
/// is first cropped to the largest centered rectangle that matches the target
/// aspect. Keeping this geometry pure makes the no-distortion contract testable
/// without decoding real images.
final class ExportAspectCrop {
  final int x;
  final int y;
  final int width;
  final int height;

  const ExportAspectCrop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory ExportAspectCrop.center({
    required int sourceWidth,
    required int sourceHeight,
    required int targetWidth,
    required int targetHeight,
  }) {
    assert(sourceWidth > 0 && sourceHeight > 0, 'source must be positive');
    assert(targetWidth > 0 && targetHeight > 0, 'target must be positive');

    final sourceAspect = sourceWidth / sourceHeight;
    final targetAspect = targetWidth / targetHeight;

    int cropW;
    int cropH;
    if (sourceAspect > targetAspect) {
      // Source is wider than the target: keep full height, trim the sides.
      cropH = sourceHeight;
      cropW = (sourceHeight * targetAspect).round();
    } else {
      // Source is taller than the target: keep full width, trim top/bottom.
      cropW = sourceWidth;
      cropH = (sourceWidth / targetAspect).round();
    }
    cropW = cropW.clamp(1, sourceWidth);
    cropH = cropH.clamp(1, sourceHeight);

    final x = ((sourceWidth - cropW) / 2).round().clamp(0, sourceWidth - cropW);
    final y =
        ((sourceHeight - cropH) / 2).round().clamp(0, sourceHeight - cropH);

    return ExportAspectCrop(x: x, y: y, width: cropW, height: cropH);
  }
}

class ExportSizePolicy {
  /// Enough for 4K presets with headroom for square/social custom exports.
  static const int maxPixelCount = 16 * 1024 * 1024;

  /// Guard against accidentally routing huge byte payloads through file IO or
  /// Android MethodChannels. PNG/JPG exports that exceed this should be reduced
  /// before save/share instead of failing late in platform code.
  static const int maxEncodedImageBytes = 64 * 1024 * 1024;

  const ExportSizePolicy._();

  static void validateTargetDimensions(int width, int height) {
    if (width <= 0 || height <= 0) {
      throw StateError('Export dimensions must be positive.');
    }
    final pixels = width * height;
    if (pixels > maxPixelCount) {
      throw StateError(
        'Export is too large: $width×$height exceeds '
        '$maxPixelCount pixels.',
      );
    }
  }

  static void validateEncodedByteLength(int byteLength) {
    if (byteLength < 0) {
      throw StateError('Export byte length must be non-negative.');
    }
    if (byteLength > maxEncodedImageBytes) {
      throw StateError(
        'Export file is too large: $byteLength bytes exceeds '
        '$maxEncodedImageBytes bytes.',
      );
    }
  }

  /// Rejects export filenames that could escape the export directory.
  ///
  /// Export filenames are expected to be plain basenames produced by
  /// [ExportService.generateFilename] / the slug helpers. A name containing a
  /// path separator (`/`, `\`), a NUL byte, or that is `.`/`..` could traverse
  /// out of the app export dir when joined as `${dir}/${filename}`, so the file
  /// boundary rejects it. A literal `..` inside a longer segment (e.g.
  /// `my..name`) is harmless and allowed.
  static void validateExportFilename(String filename) {
    if (filename.isEmpty || filename == '.' || filename == '..') {
      throw StateError('Invalid export filename: "$filename".');
    }
    if (filename.contains('/') ||
        filename.contains(r'\') ||
        filename.contains('\u0000')) {
      throw StateError(
        'Export filename must be a plain basename (no path separators): '
        '"$filename".',
      );
    }
  }
}

Future<void> _shareFileWithPlatform(File file, {String? text}) {
  return const AppShareService().shareFile(file, text: text);
}

typedef DirectoryPickerCallback = Future<String?> Function({
  String? initialDirectory,
  String? confirmButtonText,
});

Future<String?> _pickDirectoryWithPlatform({
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return file_selector.getDirectoryPath(
    initialDirectory: initialDirectory,
    confirmButtonText: confirmButtonText,
  );
}

class ExportService {
  static const MethodChannel _mediaStoreChannel =
      MethodChannel('fractalforge/media_store');

  static const String _linuxExportDirectoryPreferenceKey =
      'linux_export_directory';

  final ShareFileCallback shareFileAdapter;
  final DirectoryPickerCallback directoryPicker;

  const ExportService({
    ShareFileCallback shareFile = _shareFileWithPlatform,
    DirectoryPickerCallback pickDirectory = _pickDirectoryWithPlatform,
  })  : shareFileAdapter = shareFile,
        directoryPicker = pickDirectory;

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

  Future<String?> getPreferredExportDirectoryPath() async {
    if (kIsWeb || !Platform.isLinux) return null;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_linuxExportDirectoryPreferenceKey)?.trim();
    return path == null || path.isEmpty ? null : path;
  }

  Future<void> setPreferredExportDirectory(Directory directory) async {
    if (kIsWeb || !Platform.isLinux) return;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_linuxExportDirectoryPreferenceKey, directory.path);
  }

  Future<bool> chooseLinuxExportDirectory() async {
    if (kIsWeb || !Platform.isLinux) return true;
    final initial = await getPreferredExportDirectoryPath() ??
        (await getExportDirectory()).path;
    final selected = await directoryPicker(
      initialDirectory: initial,
      confirmButtonText: 'Save Here',
    );
    if (selected == null || selected.trim().isEmpty) return false;
    await setPreferredExportDirectory(Directory(selected));
    return true;
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
    final preferredLinuxDir = await getPreferredExportDirectoryPath();
    if (preferredLinuxDir != null) {
      final dir = Directory(preferredLinuxDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<File> createExportFile({required String filename}) async {
    // Boundary guard: an exported file must stay inside the app export dir.
    // Callers pass sanitized basenames (generateFilename / slug helpers), but
    // validate here too so a future unsanitized filename cannot write or share
    // outside the export dir via a path separator or a `..` segment.
    ExportSizePolicy.validateExportFilename(filename);
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

        // Wait for a completed paint without using Flutter's debug-only paint
        // dirtiness getter, which throws in release builds.
        await WidgetsBinding.instance.endOfFrame;
        boundary = boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary == null) {
          throw StateError('Boundary not found');
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

    final targetDims = options.getTargetDimensions(screenWidth, screenHeight);
    ExportSizePolicy.validateTargetDimensions(targetDims.$1, targetDims.$2);

    // Calculate pixel ratio for target resolution
    final pixelRatio = options.calculatePixelRatio(screenWidth, screenHeight);

    // Capture raw PNG from Flutter
    final rawPng = await capturePng(boundaryKey, pixelRatio: pixelRatio);
    ExportSizePolicy.validateEncodedByteLength(rawPng.lengthInBytes);
    onProgress?.call(0.4);

    // Decode the PNG for processing
    final decodedImage = img.decodePng(rawPng);
    if (decodedImage == null) {
      throw StateError('Failed to decode captured image');
    }
    onProgress?.call(0.5);

    // Resize if needed for target resolution.
    img.Image processedImage;
    final targetW = targetDims.$1;
    final targetH = targetDims.$2;

    if (decodedImage.width != targetW || decodedImage.height != targetH) {
      // Center-crop to the target aspect ratio first, then scale to the exact
      // size. The capture is at the screen aspect, so resizing straight to a
      // preset of a different aspect (square Instagram, 16:9 Twitter, 9:16
      // story on a portrait phone) would stretch and distort the fractal.
      final crop = ExportAspectCrop.center(
        sourceWidth: decodedImage.width,
        sourceHeight: decodedImage.height,
        targetWidth: targetW,
        targetHeight: targetH,
      );
      final cropped = (crop.width == decodedImage.width &&
              crop.height == decodedImage.height)
          ? decodedImage
          : img.copyCrop(
              decodedImage,
              x: crop.x,
              y: crop.y,
              width: crop.width,
              height: crop.height,
            );
      processedImage = (cropped.width == targetW && cropped.height == targetH)
          ? cropped
          : img.copyResize(
              cropped,
              width: targetW,
              height: targetH,
              // Avoid cubic on mobile: Play Console ANRs showed
              // Image.getPixelCubic.cubic blocking input dispatch.
              interpolation: img.Interpolation.average,
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
    ExportSizePolicy.validateEncodedByteLength(encoded.lengthInBytes);
    onProgress?.call(1.0);

    return Uint8List.fromList(encoded);
  }

  img.Image _addWatermark(img.Image image, String text) {
    // Simple text watermark in bottom-right corner.
    //
    // NOTE: the x/y/padding math below sizes the layout to [fontSize], but
    // drawString renders with the fixed img.arial14 bitmap font (~14px). On
    // large/4K exports the watermark therefore looks small and sits further
    // from the corner than intended, since the offset over-estimates the real
    // text width. This is cosmetic; a proper fix needs a scalable font, which
    // the pure-Dart image package does not currently provide.
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
        // encodeJpg expects quality in [1, 100]. The UI slider stays within
        // that range, but ExportOptions can be constructed directly, so clamp
        // defensively at the encode boundary.
        final jpgQuality = options.quality.clamp(1, 100);
        return Uint8List.fromList(
          img.encodeJpg(rgbImage, quality: jpgQuality),
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
    ExportSizePolicy.validateEncodedByteLength(bytes.lengthInBytes);
    final file = await createExportFile(filename: filename);
    final written = await file.writeAsBytes(bytes, flush: true);
    await _mirrorImageToMediaStoreIfNeeded(bytes, filename);
    return written;
  }

  Future<void> shareFile(File file, {String? text}) async {
    await shareFileAdapter(file, text: text);
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

  String get formattedSize => formatByteSize(fileSize);

  String get resolution => '$width×$height';
}
