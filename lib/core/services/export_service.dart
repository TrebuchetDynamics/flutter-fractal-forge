import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  const ExportService();

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

  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    final file = await createExportFile(filename: filename);
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }
}
