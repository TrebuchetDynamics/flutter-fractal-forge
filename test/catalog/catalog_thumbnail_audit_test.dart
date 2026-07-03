import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('static catalog thumbnail PNG bundle is not shipped', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('assets/catalog_thumbs/')));
    expect(Directory('assets/catalog_thumbs').existsSync(), isFalse);
  });
}
