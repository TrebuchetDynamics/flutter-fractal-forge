import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

void main() {
  test('Buffalo family catalog shaders exist and are registered', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final buffaloShaderAssets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) => asset
            .contains('shaders/escape_time_family/families/buffalo/'))
        .toSet();

    expect(buffaloShaderAssets, isNotEmpty);
    for (final asset in buffaloShaderAssets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset should exist');
      expect(pubspec, contains('- $asset'),
          reason: '$asset should be registered');
    }
  });
}
