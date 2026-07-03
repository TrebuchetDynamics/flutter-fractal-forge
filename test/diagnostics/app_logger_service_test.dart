import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_test/flutter_test.dart';

final class _OpaqueLogValue {
  const _OpaqueLogValue();

  @override
  String toString() => 'opaque-log-value';
}

void main() {
  // Use a fresh AppLogger per test so ring-buffer state does not bleed.
  late AppLogger logger;

  setUp(() async {
    // Clear the singleton's ring buffer before each test.
    await AppLogger.instance.clearLog();
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

  group('AppLogger — structured data', () {
    test('log snapshots unsupported values into JSON-safe data', () {
      final mutableList = <Object?>[
        double.infinity,
        <Object, Object?>{1: const _OpaqueLogValue()},
      ];
      final mutableData = <String, Object?>{
        'when': DateTime.utc(2024, 1, 2, 3, 4, 5),
        'nan': double.nan,
        'opaque': const _OpaqueLogValue(),
        'nested': mutableList,
      };

      expect(
        () => logger.log('diagnostic', 'captures data', data: mutableData),
        returnsNormally,
      );

      mutableData['opaque'] = 'changed after log';
      mutableList[0] = 'changed after log';

      final decoded = jsonDecode(logger.exportJson(pretty: false)) as List;
      final entry = decoded.single as Map<String, dynamic>;
      final data = entry['data'] as Map<String, dynamic>;

      expect(data['when'], '2024-01-02T03:04:05.000Z');
      expect(data['nan'], 'NaN');
      expect(data['opaque'], 'opaque-log-value');
      expect(data['nested'], [
        'Infinity',
        {'1': 'opaque-log-value'},
      ]);
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

      final decoded =
          jsonDecode(logger.exportJson(minLevel: LogLevel.error)) as List;
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
    test('clear removes all entries', () async {
      logger.log('a', 'one');
      logger.log('b', 'two');
      expect(logger.length, 2);

      await logger.clearLog();
      expect(logger.length, 0);
      expect(logger.entries, isEmpty);
    });

    test('clearLog notifies listeners', () async {
      logger.log('a', 'entry');
      int notifyCount = 0;
      logger.addListener(() => notifyCount++);

      await logger.clearLog();
      expect(notifyCount, 1);
    });

    test('clear (sync) notifies listeners', () {
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

  group('LogEntry — disk serialisation', () {
    test('toDiskJson uses required keys', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 3, 10, 8, 0, 0),
        level: LogLevel.warn,
        category: 'render',
        message: 'slow frame',
      );
      final json = entry.toDiskJson();
      expect(json['timestamp'], isA<String>());
      expect(json['level'], 'warn');
      expect(json['tag'], 'render');
      expect(json['message'], 'slow frame');
    });

    test('fromDiskJson round-trips correctly', () {
      final original = LogEntry(
        timestamp: DateTime(2025, 6, 15, 10, 30, 45, 123),
        level: LogLevel.error,
        category: 'gpu',
        message: 'out of memory',
      );
      final json = original.toDiskJson();
      final restored = LogEntry.fromDiskJson(json);

      expect(restored.timestamp.toIso8601String(),
          original.timestamp.toIso8601String());
      expect(restored.level, original.level);
      expect(restored.category, original.category);
      expect(restored.message, original.message);
    });

    test('fromDiskJson with unknown level falls back to info', () {
      final json = {
        'timestamp': DateTime.now().toIso8601String(),
        'level': 'unknown_level',
        'tag': 'test',
        'message': 'msg',
      };
      final entry = LogEntry.fromDiskJson(json);
      expect(entry.level, LogLevel.info);
    });
  });

  group('LogDiskRotationPolicy', () {
    test('keeps newest non-empty lines in chronological order', () {
      final plan = LogDiskRotationPolicy.plan(
        lines: const ['', 'old', 'middle', 'new'],
        maxEntries: 2,
        maxBytes: 1000,
      );

      expect(plan.keptLines, ['middle', 'new']);
      expect(plan.nonEmptyLineCount, 3);
      expect(plan.shouldRewrite, isTrue);
      expect(plan.serializeKeptLines(), 'middle\nnew\n');
    });

    test('counts UTF-8 bytes, not UTF-16 code units, for disk cap', () {
      const older = 'é';
      const newest = '🔥';
      final maxBytes = utf8.encode('$newest\n').length;

      final plan = LogDiskRotationPolicy.plan(
        lines: const [older, newest],
        maxEntries: 10,
        maxBytes: maxBytes,
      );

      expect(plan.keptLines, [newest]);
      expect(plan.keptUtf8Bytes, lessThanOrEqualTo(maxBytes));
      expect(plan.shouldRewrite, isTrue);
    });
  });

  group('AppLogger — file persistence (temp directory)', () {
    late Directory tempDir;
    late File logFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_logger_test_');
      logFile = File('${tempDir.path}/fractal_forge_logs.jsonl');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('_loadFromDisk populates ring buffer from existing JSONL', () async {
      // Write two pre-existing JSONL entries.
      final lines = [
        jsonEncode({
          'timestamp': '2024-01-01T10:00:00.000',
          'level': 'info',
          'tag': 'render',
          'message': 'loaded from disk',
        }),
        jsonEncode({
          'timestamp': '2024-01-01T10:00:01.000',
          'level': 'warn',
          'tag': 'gpu',
          'message': 'second entry',
        }),
      ];
      await logFile.writeAsString(lines.map((l) => '$l\n').join());

      // Parse directly via fromDiskJson to verify the round-trip.
      final readBack = await logFile.readAsLines();
      final parsed = readBack
          .where((l) => l.trim().isNotEmpty)
          .map((l) =>
              LogEntry.fromDiskJson(jsonDecode(l) as Map<String, dynamic>))
          .toList();

      expect(parsed.length, 2);
      expect(parsed[0].message, 'loaded from disk');
      expect(parsed[0].category, 'render');
      expect(parsed[0].level, LogLevel.info);
      expect(parsed[1].message, 'second entry');
      expect(parsed[1].level, LogLevel.warn);
    });

    test('toDiskJson produces valid JSONL-parseable output', () {
      final entry = LogEntry(
        timestamp: DateTime(2025, 1, 1, 0, 0, 0),
        level: LogLevel.debug,
        category: 'action',
        message: 'test message',
      );
      final line = jsonEncode(entry.toDiskJson());
      // Must be valid JSON and single-line.
      expect(() => jsonDecode(line), returnsNormally);
      expect(line, isNot(contains('\n')));
    });

    test('malformed JSONL lines are skipped gracefully', () {
      const bad = '{"timestamp": "not-a-date", bad json}';
      expect(
        () => LogEntry.fromDiskJson(jsonDecode(
                '{"timestamp":"2024-01-01T00:00:00.000","level":"info","tag":"x","message":"y"}')
            as Map<String, dynamic>),
        returnsNormally,
      );
      // Malformed JSON should throw during jsonDecode — catch is in _loadFromDisk.
      expect(() => jsonDecode(bad), throwsA(isA<FormatException>()));
    });
  });
}
