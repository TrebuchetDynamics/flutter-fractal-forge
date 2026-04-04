import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_fractals/features/debug/log_viewer_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogViewerStateFactory', () {
    final entries = [
      LogEntry(
        timestamp: DateTime(2024, 1, 1, 12),
        level: LogLevel.debug,
        category: 'debug',
        message: 'debug',
      ),
      LogEntry(
        timestamp: DateTime(2024, 1, 1, 12, 0, 1),
        level: LogLevel.warn,
        category: 'warn',
        message: 'warn',
      ),
      LogEntry(
        timestamp: DateTime(2024, 1, 1, 12, 0, 2),
        level: LogLevel.error,
        category: 'error',
        message: 'error',
      ),
    ];

    test('build returns all entries when no filter is selected', () {
      final state = LogViewerStateFactory.build(
        entries: entries,
        filter: null,
      );

      expect(state.totalCount, 3);
      expect(state.visibleCount, 3);
      expect(state.visibleEntries.map((entry) => entry.message), [
        'debug',
        'warn',
        'error',
      ]);
    });

    test('build applies threshold filtering by log level', () {
      final state = LogViewerStateFactory.build(
        entries: entries,
        filter: LogLevel.warn,
      );

      expect(state.totalCount, 3);
      expect(state.visibleCount, 2);
      expect(state.visibleEntries.map((entry) => entry.message), [
        'warn',
        'error',
      ]);
    });

    test('buildExportData creates deterministic filenames and payloads', () {
      final exportData = LogViewerStateFactory.buildExportData(
        text: 'plain text',
        json: '{"items":[]}',
        timestamp: DateTime.fromMillisecondsSinceEpoch(12345),
      );

      expect(exportData.text, 'plain text');
      expect(exportData.json, '{"items":[]}');
      expect(exportData.textFilename, 'fractal_log_12345.txt');
      expect(exportData.jsonFilename, 'fractal_log_12345.json');
    });

    test('colorForLevel maps each level to a stable color', () {
      expect(LogViewerStateFactory.colorForLevel(LogLevel.debug), Colors.grey);
      expect(LogViewerStateFactory.colorForLevel(LogLevel.info), Colors.white);
      expect(LogViewerStateFactory.colorForLevel(LogLevel.warn), Colors.amber);
      expect(
        LogViewerStateFactory.colorForLevel(LogLevel.error),
        Colors.redAccent,
      );
    });
  });
}
