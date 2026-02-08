import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_fractals/core/models/export_options.dart';

class ExportService {
  const ExportService();

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
          return Uint8List.fromList(img.encodePng(_applyBottomGradient(decoded, strength: 0.28)));
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
    final out = img.Image.from(src);
    final h = out.height;
    final overlayH = (h * 0.22).round().clamp(1, h);

    for (int y = 0; y < overlayH; y++) {
      final t = 1.0 - (y / overlayH);
      final a = (255 * strength * t).round().clamp(0, 255);
      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);
        // Alpha-blend black over pixel.
        final r = (img.getRed(p) * (255 - a) / 255).round();
        final g = (img.getGreen(p) * (255 - a) / 255).round();
        final b = (img.getBlue(p) * (255 - a) / 255).round();
        out.setPixelRgba(x, y, r, g, b, img.getAlpha(p));
      }
    }

    return out;
  }

  img.Image _applyBottomGradient(img.Image src, {required double strength}) {
    final out = img.Image.from(src);
    final h = out.height;
    final overlayH = (h * 0.28).round().clamp(1, h);

    for (int y = h - overlayH; y < h; y++) {
      final t = (y - (h - overlayH)) / overlayH; // 0..1
      final a = (255 * strength * t).round().clamp(0, 255);
      for (int x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);
        final r = (img.getRed(p) * (255 - a) / 255).round();
        final g = (img.getGreen(p) * (255 - a) / 255).round();
        final b = (img.getBlue(p) * (255 - a) / 255).round();
        out.setPixelRgba(x, y, r, g, b, img.getAlpha(p));
      }
    }

    return out;
  }

  Future<Directory> getExportDirectory() async {
    if (Platform.isAndroid) {
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
  Future<Uint8List> capturePng(GlobalKey boundaryKey, {double pixelRatio = 2.0}) async {
    RenderRepaintBoundary? boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('Boundary not found');
    }

    // Defensive: boundary.toImage() can throw if the layer hasn't painted yet.
    if (boundary.debugNeedsPaint) {
      // Wait for one frame and re-acquire boundary (it can change).
      await WidgetsBinding.instance.endOfFrame;
      boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Boundary not found');
      }
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode PNG');
    }
    return byteData.buffer.asUint8List();
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
    
    if (decodedImage.width != targetDims.$1 || decodedImage.height != targetDims.$2) {
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
    final encoded = _encodeToFormat(processedImage, options);
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

  Uint8List _encodeToFormat(img.Image image, ExportOptions options) {
    switch (options.format) {
      case ExportFormat.png:
        return Uint8List.fromList(img.encodePng(image, level: 6));
      
      case ExportFormat.jpg:
        // For JPG, we need to remove alpha channel if present
        final rgbImage = options.transparentBackground
            ? image
            : _removeAlpha(image);
        return Uint8List.fromList(img.encodeJpg(rgbImage, quality: options.quality));
      
      case ExportFormat.webp:
        // WebP encoding not available in image package, fallback to PNG
        return Uint8List.fromList(img.encodePng(image));
    }
  }

  img.Image _removeAlpha(img.Image image) {
    // Create a new image with white background
    final result = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );
    
    // Fill with black (fractal background)
    img.fill(result, color: img.ColorRgb8(0, 0, 0));
    
    // Composite the original image over the background
    img.compositeImage(result, image);
    
    return result;
  }

  /// Generate a filename with timestamp and format extension
  String generateFilename({
    String prefix = 'fractal',
    required ExportFormat format,
    String? fractalType,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final typePart = fractalType != null ? '_${fractalType.toLowerCase()}' : '';
    return '$prefix${typePart}_$timestamp.${format.extension}';
  }

  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    final file = await createExportFile(filename: filename);
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
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

    final finalOptions = options.copyWith(metadata: metadata);

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
      format: options.format,
      fractalType: fractalType,
    );
    
    final file = await saveBytes(bytes, filename: filename);
    final targetDims = options.getTargetDimensions(screenWidth, screenHeight);

    return ExportResult(
      file: file,
      format: options.format,
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
