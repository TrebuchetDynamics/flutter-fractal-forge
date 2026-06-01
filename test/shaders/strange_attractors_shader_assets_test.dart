import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    declaredShaderAssets = (flutter['shaders'] as YamlList).cast<String>().toSet();
  });

  test('declared strange-attractor shader assets exist on disk', () {
    final strangeAttractorAssets = declaredShaderAssets
        .where((asset) => asset.startsWith('shaders/strange_attractors/'))
        .toList()
      ..sort();

    expect(strangeAttractorAssets, isNotEmpty);

    for (final asset in strangeAttractorAssets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });

  test('catalog strange-attractor shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) => asset.startsWith('shaders/strange_attractors/'))
        .toList()
      ..sort();

    expect(catalogAssets, isNotEmpty);

    for (final asset in catalogAssets) {
      expect(declaredShaderAssets, contains(asset), reason: '$asset must be declared');
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });
}
