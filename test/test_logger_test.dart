import 'dart:io';

import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    // Reset singleton between tests so each test starts clean.
    await TestLogger().dispose();
  });

  group('TestLogger — singleton', () {
    test('factory returns the same instance', () {
      final a = TestLogger();
      final b = TestLogger();
      expect(identical(a, b), isTrue);
    });

    test('dispose resets singleton so next call returns a new instance',
        () async {
      final first = TestLogger();
      await first.dispose();
      final second = TestLogger();
      expect(identical(first, second), isFalse);
    });
  });

  group('TestLogger — buffer', () {
    test('log adds event to buffer', () {
      final logger = TestLogger();
      expect(logger.buffer, isEmpty);
      logger.log(LogEvent(
        timestamp: DateTime.now(),
        type: 'userAction',
        category: 'tap',
        message: 'button tapped',
      ));
      expect(logger.buffer.length, 1);
      expect(logger.buffer.first.message, 'button tapped');
    });

    test('buffer is unmodifiable', () {
      final logger = TestLogger();
      logger.log(LogEvent(
        timestamp: DateTime.now(),
        type: 'userAction',
        category: 'tap',
        message: 'msg',
      ));
      expect(
        () => logger.buffer.add(LogEvent(
          timestamp: DateTime.now(),
          type: 't',
          category: 'c',
          message: 'm',
        )),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('clearBuffer empties the buffer', () {
      final logger = TestLogger();
      logger.log(LogEvent(
        timestamp: DateTime.now(),
        type: 'userAction',
        category: 'tap',
        message: 'one',
      ));
      logger.log(LogEvent(
        timestamp: DateTime.now(),
        type: 'userAction',
        category: 'tap',
        message: 'two',
      ));
      expect(logger.buffer.length, 2);
      logger.clearBuffer();
      expect(logger.buffer, isEmpty);
    });

    test('buffer is capped for long many-fractal sessions', () {
      final logger = TestLogger();

      for (var i = 0; i < TestLogger.maxBufferEntries + 50; i++) {
        logger.log(LogEvent(
          timestamp: DateTime(2026, 1, 1, 0, 0, i),
          type: 'stateChange',
          category: 'moduleSwitch',
          message: 'fractal $i',
        ));
      }

      expect(logger.buffer.length, TestLogger.maxBufferEntries);
      expect(logger.buffer.first.message, 'fractal 50');
      expect(
        logger.buffer.last.message,
        'fractal ${TestLogger.maxBufferEntries + 49}',
      );
    });
  });

  group('TestLogger — convenience methods', () {
    test('logAction creates event with type userAction', () {
      final logger = TestLogger();
      logger.logAction('tap', 'tapped submit');
      expect(logger.buffer.length, 1);
      expect(logger.buffer.first.type, 'userAction');
      expect(logger.buffer.first.category, 'tap');
      expect(logger.buffer.first.message, 'tapped submit');
    });

    test('logStateChange creates event with type stateChange', () {
      final logger = TestLogger();
      logger.logStateChange('fractal', 'zoom changed');
      expect(logger.buffer.first.type, 'stateChange');
      expect(logger.buffer.first.category, 'fractal');
      expect(logger.buffer.first.message, 'zoom changed');
    });

    test(
        'logNavigation creates event with type navigation and category navigation',
        () {
      final logger = TestLogger();
      logger.logNavigation('went to catalog');
      expect(logger.buffer.first.type, 'navigation');
      expect(logger.buffer.first.category, 'navigation');
      expect(logger.buffer.first.message, 'went to catalog');
    });

    test(
        'logScreenshot creates event with type screenshot and category screenshot',
        () {
      final logger = TestLogger();
      logger.logScreenshot('screen01');
      expect(logger.buffer.first.type, 'screenshot');
      expect(logger.buffer.first.category, 'screenshot');
      expect(logger.buffer.first.message, 'screen01');
    });
  });

  group('LogEvent.toString()', () {
    test('contains timestamp, type, category, message, and metadata', () {
      final ts = DateTime(2024, 6, 1, 12, 0, 0);
      final event = LogEvent(
        timestamp: ts,
        type: 'userAction',
        category: 'tap',
        message: 'button pressed',
        metadata: {'key': 'value'},
      );
      final str = event.toString();
      expect(str, contains(ts.toIso8601String()));
      expect(str, contains('userAction'));
      expect(str, contains('tap'));
      expect(str, contains('button pressed'));
      expect(str, contains('key'));
      expect(str, contains('value'));
    });

    test('omits metadata section when metadata is null', () {
      final event = LogEvent(
        timestamp: DateTime.now(),
        type: 'navigation',
        category: 'navigation',
        message: 'home',
        metadata: null,
      );
      final str = event.toString();
      // Should end with the message — no trailing map representation.
      expect(str, endsWith('home'));
    });
  });

  group('TestLogger — file I/O', () {
    test('init with customPath creates file at that path', () async {
      final dir = Directory.systemTemp.createTempSync('test_logger_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final logPath = '${dir.path}/test.log';
      final logger = TestLogger();
      await logger.init(customPath: logPath);

      expect(File(logPath).existsSync(), isTrue);
    });

    test('log writes to file when initialized', () async {
      final dir = Directory.systemTemp.createTempSync('test_logger_write_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final logPath = '${dir.path}/out.log';
      final logger = TestLogger();
      await logger.init(customPath: logPath);
      logger.logAction('test', 'hello file');

      // dispose flushes the sink before we read the file.
      await logger.dispose();

      final contents = File(logPath).readAsStringSync();
      expect(contents, contains('hello file'));
    });

    test('init skips re-initialization when already initialized', () async {
      final dir = Directory.systemTemp.createTempSync('test_logger_skip_');

      final path1 = '${dir.path}/first.log';
      final path2 = '${dir.path}/second.log';

      final logger = TestLogger();
      await logger.init(customPath: path1);
      await logger.init(customPath: path2); // should be a no-op

      // second file should NOT have been created.
      expect(File(path2).existsSync(), isFalse);

      // Dispose before deleting the dir so the sink is flushed/closed first.
      await logger.dispose();
      dir.deleteSync(recursive: true);
    });
  });
}
