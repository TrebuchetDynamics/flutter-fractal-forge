import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_fractals/core/services/ar_export_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';

class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempDir;
  _FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir;

  @override
  Future<String?> getTemporaryPath() async => tempDir;
}

/// Stub [ExportService] that writes bytes directly to a temp path without
/// platform channels or MediaStore calls.
class _StubExportService extends ExportService {
  final String basePath;

  const _StubExportService(this.basePath);

  @override
  Future<Directory> getExportDirectory() async {
    final dir = Directory('$basePath/exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<File> createExportFile({required String filename}) async {
    final dir = await getExportDirectory();
    return File('${dir.path}/$filename');
  }

  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    final file = await createExportFile(filename: filename);
    return file.writeAsBytes(bytes, flush: true);
  }
}

/// Fake [CameraController] that returns a configurable initialized state.
///
/// Because [CameraController] is not abstract we can extend it. We override
/// only the fields / methods used by [ArExportService].
class _FakeCameraController extends CameraController {
  final bool initializedValue;
  final bool streamingValue;
  final File photoFileToReturn;

  _FakeCameraController({
    required this.initializedValue,
    required this.photoFileToReturn,
    this.streamingValue = false,
  }) : super(
          const CameraDescription(
            name: 'fake',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.low,
        );

  @override
  CameraValue get value => CameraValue(
        isInitialized: initializedValue,
        isStreamingImages: streamingValue,
        previewSize: const Size(640, 480),
        isRecordingVideo: false,
        isTakingPicture: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: const CameraDescription(
          name: 'fake',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
      );

  @override
  Future<XFile> takePicture() async => XFile(photoFileToReturn.path);

  @override
  Future<void> stopImageStream() async {}
}

/// Builds a small valid PNG and writes it to [path].
Future<File> _writePng(String path, {int r = 100, int g = 150, int b = 200}) async {
  final image = img.Image(width: 4, height: 4);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  final file = File(path);
  await file.writeAsBytes(img.encodePng(image), flush: true);
  return file;
}

/// Returns a minimal 4×4 PNG as [Uint8List].
Uint8List _makePng({int r = 80, int g = 160, int b = 240}) {
  final image = img.Image(width: 4, height: 4);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmpDir;
  late _StubExportService stubService;
  late ArExportService service;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('ar_export_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tmpDir.path);
    stubService = _StubExportService(tmpDir.path);
    service = ArExportService(stubService);
  });

  tearDown(() async {
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
  });

  group('ArExportService construction', () {
    test('can be instantiated with an ExportService', () {
      expect(service, isNotNull);
    });
  });

  group('ArExportService.exportBakedScreenshot – uninitialized camera', () {
    test('throws StateError when camera is not initialized', () async {
      // A photo file the controller would return; never actually used here.
      final photoFile = await _writePng('${tmpDir.path}/fake_photo.png');

      final controller = _FakeCameraController(
        initializedValue: false,
        photoFileToReturn: photoFile,
      );

      expect(
        () => service.exportBakedScreenshot(
          cameraController: controller,
          overlayPng: _makePng(),
          filename: 'out.png',
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          'Camera not initialized',
        )),
      );
    });
  });

  group('ArExportService.exportBakedScreenshot – initialized camera', () {
    test('returns a File when camera is initialized and images are valid',
        () async {
      final photoFile = await _writePng('${tmpDir.path}/photo.png');

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: _makePng(),
        filename: 'baked.png',
      );

      expect(result, isA<File>());
      expect(await result.exists(), isTrue);
    });

    test('produced file path ends with the requested filename', () async {
      final photoFile = await _writePng('${tmpDir.path}/photo2.png');

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: _makePng(),
        filename: 'my_ar_export.png',
      );

      expect(result.path, endsWith('my_ar_export.png'));
    });

    test('produced file contains valid PNG bytes', () async {
      final photoFile = await _writePng('${tmpDir.path}/photo3.png');

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: _makePng(),
        filename: 'valid_output.png',
      );

      final bytes = await result.readAsBytes();
      // PNG magic bytes: 0x89 'P' 'N' 'G'
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50); // 'P'
      expect(bytes[2], 0x4E); // 'N'
      expect(bytes[3], 0x47); // 'G'
    });

    test('composed image has same dimensions as base photo', () async {
      // 8×6 base photo.
      final baseImage = img.Image(width: 8, height: 6);
      img.fill(baseImage, color: img.ColorRgb8(200, 50, 50));
      final photoFile = File('${tmpDir.path}/base8x6.png');
      await photoFile.writeAsBytes(img.encodePng(baseImage), flush: true);

      // 4×4 overlay (different size — service must scale it).
      final overlayImage = img.Image(width: 4, height: 4);
      img.fill(overlayImage, color: img.ColorRgba8(0, 255, 0, 128));
      final overlayPng =
          Uint8List.fromList(img.encodePng(overlayImage));

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: overlayPng,
        filename: 'composed.png',
      );

      final resultBytes = await result.readAsBytes();
      final decoded = img.decodePng(resultBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 8);
      expect(decoded.height, 6);
    });

    test('same-size overlay is composited without resizing', () async {
      // Both base and overlay are 4×4.
      final photoFile = await _writePng('${tmpDir.path}/same_size.png',
          r: 200, g: 0, b: 0);

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      // 4×4 overlay with alpha.
      final overlayImage = img.Image(width: 4, height: 4);
      img.fill(overlayImage, color: img.ColorRgba8(0, 0, 200, 128));
      final overlayPng = Uint8List.fromList(img.encodePng(overlayImage));

      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: overlayPng,
        filename: 'samesize_out.png',
      );

      final resultBytes = await result.readAsBytes();
      final decoded = img.decodePng(resultBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 4);
      expect(decoded.height, 4);
    });

    test('throws when photo bytes cannot be decoded as an image', () async {
      // Write garbage bytes. img.decodeImage may return null or throw
      // depending on which internal decoder attempts to parse the bytes.
      final badFile = File('${tmpDir.path}/bad_photo.png');
      await badFile.writeAsBytes([0, 1, 2, 3], flush: true);

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: badFile,
      );

      await expectLater(
        service.exportBakedScreenshot(
          cameraController: controller,
          overlayPng: _makePng(),
          filename: 'fail.png',
        ),
        throwsA(anything),
      );
    });

    test('throws StateError when overlay PNG bytes are invalid', () async {
      final photoFile = await _writePng('${tmpDir.path}/photo_ok.png');

      final controller = _FakeCameraController(
        initializedValue: true,
        photoFileToReturn: photoFile,
      );

      // Garbage overlay bytes.
      final badOverlay = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);

      expect(
        () => service.exportBakedScreenshot(
          cameraController: controller,
          overlayPng: badOverlay,
          filename: 'bad_overlay.png',
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Failed to decode'),
        )),
      );
    });
  });

  group('ArExportService.exportBakedScreenshot – streaming camera', () {
    test('completes successfully even when camera is streaming images',
        () async {
      final photoFile = await _writePng('${tmpDir.path}/stream_photo.png');

      final controller = _FakeCameraController(
        initializedValue: true,
        streamingValue: true,
        photoFileToReturn: photoFile,
      );

      // The service stops the stream before taking a picture; stub allows it.
      final result = await service.exportBakedScreenshot(
        cameraController: controller,
        overlayPng: _makePng(),
        filename: 'after_stream.png',
      );

      expect(await result.exists(), isTrue);
    });
  });
}
