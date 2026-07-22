import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declared shaders do not use Windows-incompatible local includes', () {
    final shaderPaths = File('pubspec.yaml')
        .readAsLinesSync()
        .map((line) => line.trim())
        .where(
            (line) => line.startsWith('- shaders/') && line.endsWith('.frag'))
        .map((line) => line.substring(2));

    for (final path in shaderPaths) {
      expect(
        File(path).readAsStringSync(),
        isNot(matches(RegExp(r'^\s*#include\s+"', multiLine: true))),
        reason:
            '$path uses a local include that Flutter cannot resolve on Windows',
      );
    }
  });
}
