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

  test('catalog experimental named shader assets are declared and present', () {
    final assets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) => asset.startsWith('shaders/escape_time_family/experimental_named/'))
        .toList();

    expect(assets, isNotEmpty);

    for (final asset in assets) {
      expect(declaredShaderAssets, contains(asset), reason: '$asset must be declared');
      expect(File(asset).existsSync(), isTrue, reason: '$asset file must exist');
    }
  });
}
