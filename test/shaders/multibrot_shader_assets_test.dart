import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

void main() {
  group('Multibrot shader assets', () {
    final multibrotAssetPattern = RegExp(
      r'shaders/escape_time_family/families/multibrot/.+\.frag$',
    );

    test('catalog multibrot assets exist on disk', () {
      final assets = escapeTimeCatalog
          .map((config) => config.shaderAsset)
          .where(multibrotAssetPattern.hasMatch)
          .toList()
        ..sort();

      expect(assets, isNotEmpty);
      for (final asset in assets) {
        expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
      }
    });

    test('catalog multibrot assets are registered in pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final assets = escapeTimeCatalog
          .map((config) => config.shaderAsset)
          .where(multibrotAssetPattern.hasMatch)
          .toList()
        ..sort();

      expect(assets, isNotEmpty);
      for (final asset in assets) {
        expect(pubspec, contains('- $asset'));
      }
    });
  });
}
