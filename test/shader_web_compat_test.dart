import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shader integer bounds use float clamp for CanvasKit compatibility', () {
    final intClampPattern = RegExp(
      r'int\s+\w+\s*=\s*clamp\([^;]*,\s*\d+\s*,\s*\d+\s*\)',
    );
    final intVectorClampPattern = RegExp(r'clamp\([^;]*ivec\d?\(');
    final offenders = <String>[];

    for (final file in Directory('shaders').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.frag')) continue;
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final line = lines[index];
        if (intClampPattern.hasMatch(line) ||
            intVectorClampPattern.hasMatch(line)) {
          offenders.add('${file.path}:${index + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected integer clamp overloads at runtime. '
          'Cast the integer expression to float, clamp with float literals, '
          'then cast the result back to int.',
    );
  });

  test('shader min/max bounds use float overloads for CanvasKit compatibility',
      () {
    final intMinMaxPattern = RegExp(
      r'\b(?:min|max)\([^;]*(?:,\s*-?\d+\s*\)|\(\s*-?\d+\s*,)',
    );
    final offenders = <String>[];

    for (final file in Directory('shaders').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.frag')) continue;
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (intMinMaxPattern.hasMatch(codeBeforeComment)) {
          offenders.add('${file.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected integer min/max overloads at runtime. '
          'Use float bounds, e.g. max(float(n), 1.0).',
    );
  });

  test('shaders avoid integer bitshift operators for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final file in Directory('shaders').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.frag')) continue;
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (codeBeforeComment.contains('<<') ||
            codeBeforeComment.contains('>>')) {
          offenders.add('${file.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected integer bitshift operators at runtime. '
          'Use arithmetic equivalents such as int(exp2(float(n))).',
    );
  });

  test('shaders avoid percent modulus operator for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final file in Directory('shaders').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.frag')) continue;
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (codeBeforeComment.contains('%')) {
          offenders.add('${file.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected the GLSL % operator at runtime. '
          'Use integer division arithmetic instead, e.g. n - (n / m) * m.',
    );
  });
}
