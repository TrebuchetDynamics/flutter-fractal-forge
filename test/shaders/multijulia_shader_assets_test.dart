import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

void main() {
  group('Multijulia shader assets', () {
    late final Set<String> declaredShaders;

    setUpAll(() {
      final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
      final flutter = pubspec['flutter'] as YamlMap;
      declaredShaders = (flutter['shaders'] as YamlList).cast<String>().toSet();
    });

    test('catalog paths exist on disk and are declared in pubspec', () {
      final multijuliaAssets = escapeTimeCatalog
          .where((config) => config.id.startsWith('multijulia'))
          .where((config) => config.shaderAsset.contains('/families/multijulia/'))
          .map((config) => config.shaderAsset)
          .toSet();

      expect(multijuliaAssets, hasLength(10));

      for (final shaderAsset in multijuliaAssets) {
        expect(File(shaderAsset).existsSync(), isTrue, reason: '$shaderAsset must exist');
        expect(declaredShaders, contains(shaderAsset), reason: '$shaderAsset must be in pubspec.yaml');
      }
    });
  });
}
