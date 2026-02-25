import 'dart:convert';

import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Use a fresh AppLogger per test so ring-buffer state does not bleed.
  late AppLogger logger;

  setUp(() {
    // Clear the singleton's ring buffer before each test.
    AppLogger.instance.clear();
    logger = AppLogger.instance;
  });

  group('AppLogger — ring buffer', () {
    test('log adds entry to ring buffer', () {
      expect(logger.length, 0);
      logger.log('render', 'frame rendered');
      expect(logger.length, 1);
      expect(logger.entries.first.message, 'frame rendered');
      expect(logger.entries.first.category, 'render');
    });

    test('log trims to maxEntries when exceeded', () {
      // maxEntries defaults to 2000; use reflection-free approach: add
      // maxEntries+1 items and verify oldest is removed.
      final max = logger.maxEntries;
      for (int i = 0; i <= max; i++) {
        logger.log('cat', 'msg$i');
      }
      expect(logger.length, max);
      // First entry should be msg1 (msg0 was trimmed)
      expect(logger.entries.first.message, 'msg1');
      expect(logger.entries.last.message, 'msg$max');
    });

    test('entries returns oldest-first list', () {
      logger.log('a', 'first');
      logger.log('b', 'second');
      logger.log('c', 'third');

      final entries = logger.entries;
      expect(entries[0].message, 'first');
      expect(entries[1].message, 'second');
      expect(entries[2].message, 'third');
    });
  });

  group('AppLogger — convenience level methods', () {
    test('debug sets level to debug', () {
      logger.debug('cat', 'dbg msg');
      expect(logger.entries.last.level, LogLevel.debug);
    });

    test('info sets level to info', () {
      logger.info('cat', 'info msg');
      expect(logger.entries.last.level, LogLevel.info);
    });

    test('warn sets level to warn', () {
      logger.warn('cat', 'warn msg');
      expect(logger.entries.last.level, LogLevel.warn);
    });

    test('error sets level to error', () {
      logger.error('cat', 'error msg');
      expect(logger.entries.last.level, LogLevel.error);
    });

    test('log default level is info', () {
      logger.log('cat', 'default level');
      expect(logger.entries.last.level, LogLevel.info);
    });
  });

  group('AppLogger — exportText', () {
    test('exportText returns all entries as lines', () {
      logger.log('a', 'line one');
      logger.log('b', 'line two');
      logger.log('c', 'line three');

      final text = logger.exportText();
      final lines = text.split('\n');
      expect(lines.length, 3);
      expect(lines[0], contains('line one'));
      expect(lines[1], contains('line two'));
      expect(lines[2], contains('line three'));
    });

    test('exportText with minLevel filters lower levels', () {
      logger.debug('cat', 'debug entry');
      logger.info('cat', 'info entry');
      logger.warn('cat', 'warn entry');
      logger.error('cat', 'error entry');

      final text = logger.exportText(minLevel: LogLevel.warn);
      expect(text, contains('warn entry'));
      expect(text, contains('error entry'));
      expect(text, isNot(contains('debug entry')));
      expect(text, isNot(contains('info entry')));
    });
  });

  group('AppLogger — exportJson', () {
    test('exportJson returns valid JSON array', () {
      logger.log('render', 'gpu frame');
      logger.log('action', 'user tapped');

      final json = logger.exportJson();
      final decoded = jsonDecode(json);
      expect(decoded, isA<List>());
      expect((decoded as List).length, 2);
    });

    test('exportJson entries contain expected keys', () {
      logger.log('render', 'test', data: {'frames': 42});

      final decoded = jsonDecode(logger.exportJson()) as List;
      final entry = decoded.first as Map<String, dynamic>;
      expect(entry['level'], isNotNull);
      expect(entry['cat'], isNotNull);
      expect(entry['msg'], isNotNull);
      expect(entry['t'], isNotNull);
      expect(entry['data'], {'frames': 42});
    });

    test('exportJson with minLevel filters entries', () {
      logger.debug('cat', 'skip me');
      logger.error('cat', 'keep me');

      final decoded = jsonDecode(logger.exportJson(minLevel: LogLevel.error))
          as List;
      expect(decoded.length, 1);
      expect((decoded.first as Map)['msg'], 'keep me');
    });

    test('exportJson pretty=false returns compact JSON', () {
      logger.log('cat', 'compact');
      final json = logger.exportJson(pretty: false);
      // Compact JSON has no newlines
      expect(json, isNot(contains('\n')));
    });
  });

  group('AppLogger — clear', () {
    test('clear removes all entries', () {
      logger.log('a', 'one');
      logger.log('b', 'two');
      expect(logger.length, 2);

      logger.clear();
      expect(logger.length, 0);
      expect(logger.entries, isEmpty);
    });

    test('clear notifies listeners', () {
      logger.log('a', 'entry');
      int notifyCount = 0;
      logger.addListener(() => notifyCount++);

      logger.clear();
      expect(notifyCount, 1);
    });

    test('log notifies listeners', () {
      int notifyCount = 0;
      logger.addListener(() => notifyCount++);

      logger.log('cat', 'msg');
      expect(notifyCount, 1);
    });
  });

  group('LogEntry.toLogLine', () {
    test('formats correctly with HH:MM:SS.mmm prefix', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 1, 15, 9, 5, 3, 42),
        level: LogLevel.info,
        category: 'render',
        message: 'hello world',
      );

      final line = entry.toLogLine();
      expect(line, startsWith('[09:05:03.042]'));
      expect(line, contains('[info]'));
      expect(line, contains('[render]'));
      expect(line, contains('hello world'));
    });

    test('toLogLine includes JSON-encoded data when present', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 6, 1, 12, 0, 0, 0),
        level: LogLevel.warn,
        category: 'gpu',
        message: 'health check',
        data: {'status': 'failed', 'code': 3},
      );

      final line = entry.toLogLine();
      expect(line, contains('"status":"failed"'));
      expect(line, contains('"code":3'));
    });

    test('toLogLine has no data suffix when data is null', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 6, 1, 12, 0, 0, 0),
        level: LogLevel.debug,
        category: 'action',
        message: 'tap',
      );

      final line = entry.toLogLine();
      // Should end with the message, no trailing data
      expect(line, endsWith('tap'));
    });

    test('toLogLine level ordering: debug < info < warn < error', () {
      expect(LogLevel.debug.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.warn.index));
      expect(LogLevel.warn.index, lessThan(LogLevel.error.index));
    });
  });
}
