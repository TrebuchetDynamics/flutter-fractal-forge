import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production diagnostics use structured logging', () {
    const sinkFiles = <String>{
      'lib/core/services/diagnostics/app_logger_service.dart',
      'lib/core/services/diagnostics/crash_reporter.dart',
      'lib/core/services/diagnostics/test_logger.dart',
    };
    final violations = <String>[];
    final calls = RegExp(r'\b(?:debugPrint|print)\s*\(');

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (sinkFiles.contains(entity.path)) continue;
      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (!calls.hasMatch(line)) continue;
        final snippet = lines.skip(index).take(3).join(' ');
        if (snippet.contains('PLAYWRIGHT_')) continue;
        violations.add('${entity.path}:${index + 1}: ${line.trim()}');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use AppLogger for production diagnostics. Only logger sinks and '
          'explicit PLAYWRIGHT protocol output are exempt.\n'
          '${violations.join('\n')}',
    );
  });
}
