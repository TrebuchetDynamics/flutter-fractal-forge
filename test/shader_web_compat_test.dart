import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shader integer bounds use float clamp for CanvasKit compatibility', () {
    final intClampPattern = RegExp(
      r'int\s+\w+\s*=\s*clamp\([^;]*,\s*\d+\s*,\s*\d+\s*\)',
    );
    final intVectorClampPattern = RegExp(r'clamp\([^;]*ivec\d?\(');
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      for (var index = 0; index < lines.length; index += 1) {
        final line = lines[index];
        if (intClampPattern.hasMatch(line) ||
            intVectorClampPattern.hasMatch(line)) {
          offenders.add('${shaderFile.path}:${index + 1}: ${line.trim()}');
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
    final literalIntMinMaxPattern = RegExp(
      r'\b(?:min|max)\([^;]*(?:,\s*-?\d+\s*\)|\(\s*-?\d+\s*,)',
    );
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      final intIdentifiers = _intIdentifiers(lines);
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (literalIntMinMaxPattern.hasMatch(codeBeforeComment) ||
            _usesIntegerIntrinsic(
              codeBeforeComment,
              intIdentifiers,
              functions: const {'min', 'max'},
            )) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
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

  test(
      'shader int clamp assignments use float clamp for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      final intIdentifiers = _intIdentifiers(lines);
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (_usesIntegerIntrinsic(
          codeBeforeComment,
          intIdentifiers,
          functions: const {'clamp'},
        )) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
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

  test('shader abs calls avoid integer overloads for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      final intIdentifiers = _intIdentifiers(lines);
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (_usesIntegerIntrinsic(
          codeBeforeComment,
          intIdentifiers,
          functions: const {'abs'},
        )) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected integer abs overloads at runtime. '
          'Use integer comparisons or cast through float first.',
    );
  });

  test('shaders avoid integer bitwise operators for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (codeBeforeComment.contains('<<') ||
            codeBeforeComment.contains('>>') ||
            codeBeforeComment.replaceAll('&&', '').contains('&')) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'CanvasKit/SkSL rejected integer bitwise operators at runtime. '
          'Use arithmetic equivalents such as int(exp2(float(n))) or '
          'n - (n / m) * m.',
    );
  });

  test('shaders avoid non-constant array indexes for CanvasKit compatibility',
      () {
    final dynamicIndexPattern = RegExp(
      r'\[\s*(?!(?:i|j|k|m|n|p)\b|\d+)([A-Za-z_]\w*)\s*\]',
    );
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (dynamicIndexPattern.hasMatch(codeBeforeComment)) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'CanvasKit/SkSL rejected array indexes that were not compile-time '
          'constants or simple loop counters at runtime. Copy the selected '
          'array value inside a loop instead of using a uniform-derived index.',
    );
  });

  test('shaders avoid percent modulus operator for CanvasKit compatibility',
      () {
    final offenders = <String>[];

    for (final shaderFile in _shaderFiles()) {
      final lines = shaderFile.lines;
      for (var index = 0; index < lines.length; index += 1) {
        final codeBeforeComment = lines[index].split('//').first;
        if (codeBeforeComment.contains('%')) {
          offenders
              .add('${shaderFile.path}:${index + 1}: ${lines[index].trim()}');
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

Iterable<({String path, List<String> lines})> _shaderFiles() sync* {
  for (final file in Directory('shaders').listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.frag')) {
      yield (path: file.path, lines: file.readAsLinesSync());
    }
  }
}

Set<String> _intIdentifiers(List<String> lines) {
  final intDeclarationPattern = RegExp(r'\bint\s+([A-Za-z_]\w*)');
  return {
    for (final line in lines)
      for (final match in intDeclarationPattern.allMatches(line))
        match.group(1)!,
  };
}

bool _usesIntegerIntrinsic(
  String line,
  Set<String> intIdentifiers, {
  required Set<String> functions,
}) {
  if (intIdentifiers.isEmpty) return false;

  for (final function in functions) {
    final callPattern = RegExp('\\b$function\\s*\\(([^;]*)\\)');
    for (final match in callPattern.allMatches(line)) {
      final args = match.group(1)!;
      if (_looksFloatExpression(args)) continue;
      if (_containsIntIdentifier(args, intIdentifiers)) return true;
    }
  }

  return false;
}

bool _containsIntIdentifier(String text, Set<String> intIdentifiers) {
  final tokenPattern = RegExp(r'\b[A-Za-z_]\w*\b');
  return tokenPattern
      .allMatches(text)
      .any((match) => intIdentifiers.contains(match.group(0)));
}

bool _looksFloatExpression(String text) {
  final floatLiteralPattern = RegExp(
    r'(?:\d+\.\d*|\.\d+|\d+e[+-]?\d+)',
    caseSensitive: false,
  );
  return text.contains('float(') ||
      text.contains('vec') ||
      floatLiteralPattern.hasMatch(text);
}
