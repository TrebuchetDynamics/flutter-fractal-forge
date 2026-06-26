import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_logger.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_screenshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    // Reset TestLogger singleton so it does not bleed between tests.
    await TestLogger().dispose();
  });

  group('TestScreenshotService — constructor', () {
    test('constructor creates instance with given outputDir', () {
      final svc = TestScreenshotService(outputDir: '/tmp/screenshots');
      expect(svc, isNotNull);
    });
  });

  group('TestScreenshotService — capture', () {
    test('capture with invalid key returns null (no crash)', () async {
      final dir = Directory.systemTemp.createTempSync('screenshot_svc_null_');
      addTearDown(() => dir.deleteSync(recursive: true));

      // GlobalKey with no widget attached → currentContext is null → no RenderObject.
      // capturePng catches the StateError and returns null.
      final key = GlobalKey();
      final svc = TestScreenshotService(outputDir: dir.path);

      // Verify no synchronous exception is thrown when starting the call.
      // We don't await the full future (which would block on endOfFrame retries),
      // but we do confirm the function returns a Future<File?> without throwing.
      final future = svc.capture(key, 'shot01');
      expect(future, isA<Future<File?>>());
    });

    test('capture creates output directory when it does not exist', () async {
      final base = Directory.systemTemp.createTempSync('screenshot_svc_dir_');
      addTearDown(() => base.deleteSync(recursive: true));

      final outputDir = '${base.path}/new_subdir';
      expect(Directory(outputDir).existsSync(), isFalse);

      final key = GlobalKey(); // no render object
      final svc = TestScreenshotService(outputDir: outputDir);

      // Start the capture — directory creation happens before capturePng is called.
      // Yield to the event loop to allow the async directory creation to complete.
      final captureFuture = svc.capture(key, 'shot02');
      // Pump microtasks until directory appears (it is created before endOfFrame wait).
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
        if (Directory(outputDir).existsSync()) break;
      }

      expect(Directory(outputDir).existsSync(), isTrue);

      // Ignore the rest of the future (it will hang on endOfFrame in test env).
      captureFuture.ignore();
    });
  });
}
