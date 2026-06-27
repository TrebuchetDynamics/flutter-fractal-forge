import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_target.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';

export 'package:flutter_fractals/core/models/wallpaper/wallpaper_target.dart';

/// Sets the generated fractal as the device wallpaper.
///
/// Platform notes:
/// - Android: uses [android.app.WallpaperManager] to set HOME/LOCK/BOTH.
/// - iOS: iOS does not allow setting wallpaper programmatically. We save the
///   image to Photos instead (so the user can set it from the Photos app).
class WallpaperService {
  static const MethodChannel _channel =
      MethodChannel('com.fractalforge/wallpaper');

  const WallpaperService();

  Future<bool> setWallpaper(
    Uint8List pngBytes, {
    required WallpaperTarget target,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Wallpaper setting is not supported on web.');
    }

    ExportSizePolicy.validateEncodedByteLength(pngBytes.lengthInBytes);

    if (!kIsWeb && Platform.isIOS) {
      // iOS does not allow programmatic wallpaper setting. Save to Photos.
      return saveToPhotos(pngBytes);
    }

    final ok = await _channel.invokeMethod<bool>('setWallpaper', {
      'bytes': pngBytes,
      'target': target.name,
    });

    return ok ?? false;
  }

  Future<bool> saveToPhotos(Uint8List pngBytes) async {
    if (kIsWeb) {
      throw UnsupportedError('Saving to Photos is not supported on web.');
    }

    ExportSizePolicy.validateEncodedByteLength(pngBytes.lengthInBytes);

    final ok = await _channel.invokeMethod<bool>('saveToPhotos', {
      'bytes': pngBytes,
    });

    return ok ?? false;
  }
}
