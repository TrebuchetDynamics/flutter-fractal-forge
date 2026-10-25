import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_logger.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_screenshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Allow real directory IO and the capture's endOfFrame retries to finish.
/// Readiness is the capture Future itself, not an assumed number of IO turns.
Future<File?> _completeCapture(
    WidgetTester tester, Future<File?> capture) async {
  var completed = false;
  unawaited(capture.then<void>((_) {
    completed = true;
  }, onError: (Object _, StackTrace __) {
    completed = true;
  }));
  final elapsed = Stopwatch()..start();
  while (!completed && elapsed.elapsed < const Duration(seconds: 10)) {
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  expect(completed, isTrue,
      reason: 'capture must settle before fixture teardown');
  return capture;
}

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
    testWidgets('capture with invalid key returns null (no crash)',
        (tester) async {
      final dir = Directory.systemTemp.createTempSync('screenshot_svc_null_');
      addTearDown(() => dir.deleteSync(recursive: true));

      // GlobalKey with no widget attached → currentContext is null → no RenderObject.
      // capturePng catches the StateError and returns null.
      final key = GlobalKey();
      final svc = TestScreenshotService(outputDir: dir.path);

      // Starting capture must not throw, and the retried capture must return
      // null before the temporary directory and logger are disposed.
      final future = svc.capture(key, 'shot01');
      expect(future, isA<Future<File?>>());
      expect(await _completeCapture(tester, future), isNull);
    });

    test('capture rejects path-like screenshot names before capture', () async {
      final dir = Directory.systemTemp.createTempSync('screenshot_svc_name_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final key = GlobalKey();
      final svc = TestScreenshotService(outputDir: dir.path);

      final result = await svc.capture(key, '../escape');

      expect(result, isNull);
      expect(File('${dir.parent.path}/escape.png').existsSync(), isFalse);
    });

    testWidgets('capture creates output directory when it does not exist',
        (tester) async {
      final base = Directory.systemTemp.createTempSync('screenshot_svc_dir_');
      addTearDown(() => base.deleteSync(recursive: true));

      final outputDir = '${base.path}/new_subdir';
      expect(Directory(outputDir).existsSync(), isFalse);

      final key = GlobalKey(); // no render object
      final svc = TestScreenshotService(outputDir: outputDir);

      final captureFuture = svc.capture(key, 'shot02');
      expect(await _completeCapture(tester, captureFuture), isNull);
      expect(Directory(outputDir).existsSync(), isTrue);
    });
  });
}
