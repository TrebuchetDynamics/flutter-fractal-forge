import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

void main() {
  test('polynomial map catalog shaders exist and are registered', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final polynomialShaderAssets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) =>
            asset.contains('shaders/escape_time_family/polynomial_maps/'))
        .toSet();

    expect(polynomialShaderAssets, isNotEmpty);
    for (final asset in polynomialShaderAssets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset should exist');
      expect(pubspec, contains('- $asset'),
          reason: '$asset should be registered');
    }
  });
}
