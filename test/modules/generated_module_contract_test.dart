import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy generated module files stay removed', () {
    final modules = Directory('lib/core/modules')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_module.dart'))
        .where((file) => file.readAsStringSync().startsWith('// GENERATED'))
        .toList();

    expect(modules, isEmpty);
  });
}
