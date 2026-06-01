import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  const shaderRoot = 'shaders/root_finding/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    declaredShaderAssets = (flutter['shaders'] as YamlList).cast<String>().toSet();
  });

  test('declared root-finding shader assets exist on disk', () {
    final assets = declaredShaderAssets
        .where((asset) => asset.startsWith(shaderRoot))
        .toList()
      ..sort();

    expect(assets, isNotEmpty);

    for (final asset in assets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });

  test('catalog root-finding shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) => asset.startsWith(shaderRoot))
        .toList()
      ..sort();

    expect(catalogAssets, isNotEmpty);

    for (final asset in catalogAssets) {
      expect(declaredShaderAssets, contains(asset), reason: '$asset must be declared');
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });
}
