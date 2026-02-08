import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';

void main() {
  group('CrashReporter', () {
    setUpAll(() {
      // Initialize crash reporter
      CrashReporter.install(maxEvents: 50, persistToDisk: false);
    });

    setUp(() {
      // Clear events before each test
      CrashReporter.instance.clear();
    });

    test('instance is initialized after install', () {
      expect(CrashReporter.instance, isNotNull);
      expect(CrashReporter.instanceOrNull, isNotNull);
    });

    test('has session ID', () {
      expect(CrashReporter.instance.sessionId, isNotEmpty);
      expect(CrashReporter.instance.sessionId.startsWith('FF'), isTrue);
    });

    test('has session start time', () {
      final now = DateTime.now().toUtc();
      final sessionStart = CrashReporter.instance.sessionStart;

      expect(sessionStart.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      expect(sessionStart.isAfter(now.subtract(const Duration(hours: 1))), isTrue);
    });

    test('records error events', () {
      CrashReporter.instance.record(
        Exception('Test error'),
        StackTrace.current,
        source: 'test',
        fatal: false,
      );

      expect(CrashReporter.instance.errorCount, equals(1));
      expect(CrashReporter.instance.recentEvents, hasLength(1));
    });

    test('records fatal events', () {
      CrashReporter.instance.record(
        Exception('Fatal error'),
        StackTrace.current,
        source: 'test',
        fatal: true,
      );

      expect(CrashReporter.instance.fatalCount, equals(1));
      expect(CrashReporter.instance.fatalEvents, hasLength(1));
    });

    test('records events with context', () {
      CrashReporter.instance.record(
        Exception('Error with context'),
        null,
        source: 'test',
        fatal: false,
        context: 'During shader compilation',
      );

      final event = CrashReporter.instance.recentEvents.first;
      expect(event.context, equals('During shader compilation'));
    });

    test('records events with tags', () {
      CrashReporter.instance.record(
        Exception('Tagged error'),
        null,
        source: 'test',
        fatal: false,
        tags: {'module': 'mandelbrot', 'attempt': '1'},
      );

      final event = CrashReporter.instance.recentEvents.first;
      expect(event.tags['module'], equals('mandelbrot'));
      expect(event.tags['attempt'], equals('1'));
    });

    test('tracks error counts by source', () {
      CrashReporter.instance.record(
        Exception('Error 1'),
        null,
        source: 'shader',
        fatal: false,
      );
      CrashReporter.instance.record(
        Exception('Error 2'),
        null,
        source: 'shader',
        fatal: false,
      );
      CrashReporter.instance.record(
        Exception('Error 3'),
        null,
        source: 'network',
        fatal: false,
      );

      expect(CrashReporter.instance.errorCountsBySource['shader'], equals(2));
      expect(CrashReporter.instance.errorCountsBySource['network'], equals(1));
    });

    test('limits events to maxEvents', () {
      // Install with small limit for testing
      // Note: Can't reinstall, so we test with existing instance
      for (var i = 0; i < 100; i++) {
        CrashReporter.instance.record(
          Exception('Error $i'),
          null,
          source: 'test',
          fatal: false,
        );
      }

      // Should be capped at 50 (the maxEvents we set in setUpAll)
      expect(CrashReporter.instance.errorCount, equals(50));
    });

    test('clears events', () {
      CrashReporter.instance.record(
        Exception('Error'),
        null,
        source: 'test',
        fatal: false,
      );

      expect(CrashReporter.instance.errorCount, greaterThan(0));

      CrashReporter.instance.clear();

      expect(CrashReporter.instance.errorCount, equals(0));
      expect(CrashReporter.instance.errorCountsBySource, isEmpty);
    });

    test('filters events by source', () {
      CrashReporter.instance.record(
        Exception('Shader error'),
        null,
        source: 'shader',
        fatal: false,
      );
      CrashReporter.instance.record(
        Exception('Network error'),
        null,
        source: 'network',
        fatal: false,
      );

      final shaderEvents = CrashReporter.instance.getEventsBySource('shader');
      expect(shaderEvents, hasLength(1));
      expect(shaderEvents.first.source, equals('shader'));
    });

    test('adds breadcrumbs', () {
      CrashReporter.instance.addBreadcrumb(
        'User navigated to settings',
        category: 'navigation',
      );

      final events = CrashReporter.instance.recentEvents;
      expect(events.last.error, contains('BREADCRUMB'));
      expect(events.last.source, equals('breadcrumb_navigation'));
    });

    test('exports logs as text', () {
      CrashReporter.instance.record(
        Exception('Test export error'),
        null,
        source: 'test',
        fatal: false,
      );

      final logs = CrashReporter.instance.exportRecentLogs();

      expect(logs, contains('Fractal Forge Crash Report'));
      expect(logs, contains('Session:'));
      expect(logs, contains('Test export error'));
    });

    test('exports logs with line limit', () {
      for (var i = 0; i < 10; i++) {
        CrashReporter.instance.record(
          Exception('Error $i'),
          null,
          source: 'test',
          fatal: false,
        );
      }

      final logs = CrashReporter.instance.exportRecentLogs(maxLines: 3);
      // Should contain header plus last 3 events
      expect(logs, contains('Error 7'));
      expect(logs, contains('Error 8'));
      expect(logs, contains('Error 9'));
    });

    test('exports as JSON', () {
      CrashReporter.instance.record(
        Exception('JSON test error'),
        null,
        source: 'test',
        fatal: false,
      );

      final json = CrashReporter.instance.exportAsJson();

      expect(json, contains('"session_id"'));
      expect(json, contains('"events"'));
      expect(json, contains('JSON test error'));
    });

    test('event stream broadcasts events', () async {
      final events = <CrashEvent>[];
      final subscription = CrashReporter.instance.eventStream.listen((event) {
        events.add(event);
      });

      CrashReporter.instance.record(
        Exception('Stream test'),
        null,
        source: 'test',
        fatal: false,
      );

      // Wait for event to be broadcast
      await Future.delayed(const Duration(milliseconds: 10));

      expect(events, hasLength(1));
      expect(events.first.error, contains('Stream test'));

      await subscription.cancel();
    });

    test('sanitizes file paths in errors', () {
      CrashReporter.instance.record(
        Exception('Error at /Users/testuser/project/file.dart'),
        null,
        source: 'test',
        fatal: false,
      );

      final event = CrashReporter.instance.recentEvents.first;
      expect(event.error, isNot(contains('testuser')));
    });

    test('truncates long error messages', () {
      final longMessage = 'x' * 1000;
      CrashReporter.instance.record(
        Exception(longMessage),
        null,
        source: 'test',
        fatal: false,
      );

      final event = CrashReporter.instance.recentEvents.first;
      expect(event.error.length, lessThan(850)); // 800 + some overhead
      expect(event.error, contains('truncated'));
    });
  });

  group('CrashEvent', () {
    test('creates from required parameters', () {
      final event = CrashEvent(
        timestamp: DateTime.utc(2024, 1, 15, 10, 30),
        sessionId: 'FF123',
        source: 'test',
        fatal: false,
        error: 'Test error',
        errorType: 'Exception',
      );

      expect(event.timestamp, equals(DateTime.utc(2024, 1, 15, 10, 30)));
      expect(event.sessionId, equals('FF123'));
      expect(event.source, equals('test'));
      expect(event.fatal, isFalse);
      expect(event.error, equals('Test error'));
      expect(event.errorType, equals('Exception'));
      expect(event.stack, isNull);
      expect(event.context, isNull);
      expect(event.tags, isEmpty);
    });

    test('converts to single line string', () {
      final event = CrashEvent(
        timestamp: DateTime.utc(2024, 1, 15, 10, 30),
        sessionId: 'FF123',
        source: 'shader',
        fatal: true,
        error: 'Shader compilation failed',
        errorType: 'ShaderException',
      );

      final line = event.toSingleLineString();

      expect(line, contains('[FATAL]'));
      expect(line, contains('[shader]'));
      expect(line, contains('Shader compilation failed'));
    });

    test('converts to multiline string', () {
      final event = CrashEvent(
        timestamp: DateTime.utc(2024, 1, 15, 10, 30),
        sessionId: 'FF123',
        source: 'test',
        fatal: false,
        error: 'Test error',
        errorType: 'Exception',
        context: 'During initialization',
        stack: 'line1\nline2',
        tags: {'key': 'value'},
      );

      final multiline = event.toMultilineString();

      expect(multiline, contains('Test error'));
      expect(multiline, contains('Context: During initialization'));
      expect(multiline, contains('Tags: key=value'));
      expect(multiline, contains('Stack:'));
    });

    test('converts to and from JSON', () {
      final original = CrashEvent(
        timestamp: DateTime.utc(2024, 1, 15, 10, 30),
        sessionId: 'FF123',
        source: 'test',
        fatal: true,
        error: 'Test error',
        errorType: 'Exception',
        context: 'Test context',
        stack: 'test stack',
        tags: {'key': 'value'},
      );

      final json = original.toJson();
      final restored = CrashEvent.fromJson(json);

      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.sessionId, equals(original.sessionId));
      expect(restored.source, equals(original.source));
      expect(restored.fatal, equals(original.fatal));
      expect(restored.error, equals(original.error));
      expect(restored.errorType, equals(original.errorType));
      expect(restored.context, equals(original.context));
      expect(restored.stack, equals(original.stack));
      expect(restored.tags, equals(original.tags));
    });

    test('toString returns single line', () {
      final event = CrashEvent(
        timestamp: DateTime.utc(2024, 1, 15),
        sessionId: 'FF123',
        source: 'test',
        fatal: false,
        error: 'Error',
        errorType: 'Exception',
      );

      expect(event.toString(), equals(event.toSingleLineString()));
    });
  });

  group('BreadcrumbMarker', () {
    test('stores message', () {
      const marker = BreadcrumbMarker('Navigation event');
      expect(marker.message, equals('Navigation event'));
    });

    test('toString returns message', () {
      const marker = BreadcrumbMarker('Test breadcrumb');
      expect(marker.toString(), equals('Test breadcrumb'));
    });
  });

  group('CrashReporterExtension', () {
    test('withCrashReporting catches errors', () async {
      CrashReporter.instance.clear();

      try {
        await Future<void>.error(Exception('Async error'))
            .withCrashReporting<void>('async_test');
      } catch (_) {
        // Expected
      }

      expect(CrashReporter.instance.errorCount, equals(1));
      expect(
        CrashReporter.instance.recentEvents.first.source,
        equals('async_test'),
      );
    });

    test('withCrashReporting passes through successful results', () async {
      final result = await Future.value(42).withCrashReporting<int>('test');
      expect(result, equals(42));
    });
  });
}
