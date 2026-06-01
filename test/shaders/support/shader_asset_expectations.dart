import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

Set<String> loadDeclaredShaderAssets() {
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  final flutter = pubspec['flutter'] as YamlMap;
  return (flutter['shaders'] as YamlList).cast<String>().toSet();
}

List<String> escapeTimeShaderAssetsStartingWith(String shaderRoot) {
  return escapeTimeCatalog
      .map((config) => config.shaderAsset)
      .where((asset) => asset.startsWith(shaderRoot))
      .toList()
    ..sort();
}

List<String> declaredShaderAssetsStartingWith(
  Set<String> declaredShaderAssets,
  String shaderRoot,
) {
  return declaredShaderAssets
      .where((asset) => asset.startsWith(shaderRoot))
      .toList()
    ..sort();
}

void expectAssetsExist(Iterable<String> assets,
    {String fileReason = 'must exist'}) {
  for (final asset in assets) {
    expect(File(asset).existsSync(), isTrue, reason: '$asset $fileReason');
  }
}

void expectAssetsDeclaredAndExist(
  Iterable<String> assets,
  Set<String> declaredShaderAssets, {
  String fileReason = 'must exist',
}) {
  for (final asset in assets) {
    expect(declaredShaderAssets, contains(asset),
        reason: '$asset must be declared');
    expect(File(asset).existsSync(), isTrue, reason: '$asset $fileReason');
  }
}
