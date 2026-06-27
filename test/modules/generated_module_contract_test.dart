import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated module files have valid local contracts', () {
    final modules = Directory('lib/core/modules')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_module.dart'))
        .where((file) => file.readAsStringSync().startsWith('// GENERATED'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(modules.length, greaterThan(1000));

    final failures = <String>[];
    for (final moduleFile in modules) {
      final moduleSource = moduleFile.readAsStringSync();
      final idMatch = RegExp(r"id: '([^']+)'").firstMatch(moduleSource);
      final classMatch =
          RegExp(r'class\s+(\w+)\s+extends').firstMatch(moduleSource);
      final shaderMatch =
          RegExp(r"shader:\s*'([^']+)'").firstMatch(moduleSource);

      if (idMatch == null) {
        failures.add('${moduleFile.path}: missing id literal');
        continue;
      }
      final id = idMatch.group(1)!;
      if (shaderMatch == null) {
        failures.add('${moduleFile.path}: missing shader path');
      }
      if (classMatch == null) {
        failures.add('${moduleFile.path}: missing generated class declaration');
      }

      File? metadataFile;
      for (final importMatch
          in RegExp(r"import '([^']+)';").allMatches(moduleSource)) {
        final importPath = importMatch.group(1)!;
        if (importPath.startsWith('../../base_classes/')) continue;
        final companion = File('${moduleFile.parent.path}/$importPath');
        if (!companion.existsSync()) {
          failures.add('${moduleFile.path}: missing ${companion.path}');
        }
        if (importPath.contains('metadata')) metadataFile = companion;
      }

      if (metadataFile == null || !metadataFile.existsSync()) {
        failures.add('${moduleFile.path}: missing metadata import for $id');
      } else {
        final metadataSource = metadataFile.readAsStringSync();
        if (!metadataSource.contains("String get id => '$id'")) {
          failures.add('${metadataFile.path}: metadata id mismatch');
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
