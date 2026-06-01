import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    declaredShaderAssets =
        (flutter['shaders'] as YamlList).cast<String>().toSet();
  });

  test('declared IFS and geometric shader assets exist on disk', () {
    final ifsAssets = declaredShaderAssets
        .where((asset) => asset.startsWith('shaders/ifs_and_geometric/'))
        .toList()
      ..sort();

    expect(ifsAssets, isNotEmpty);

    for (final asset in ifsAssets) {
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });

  test('catalog IFS and geometric shader assets are declared in pubspec', () {
    final catalogAssets = [
      ...escapeTimeCatalog.map((config) => config.shaderAsset),
      ...raymarched3dCatalog.map((module) => module.shaderAsset),
    ].where((asset) => asset.startsWith('shaders/ifs_and_geometric/')).toList()
      ..sort();

    expect(catalogAssets, isNotEmpty);

    for (final asset in catalogAssets) {
      expect(declaredShaderAssets, contains(asset),
          reason: '$asset must be declared');
      expect(File(asset).existsSync(), isTrue, reason: '$asset must exist');
    }
  });
}
