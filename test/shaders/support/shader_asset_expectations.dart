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

List<String> missingShaderAssets(Iterable<String> assets) {
  return assets.where((asset) => !File(asset).existsSync()).toSet().toList()
    ..sort();
}

List<String> undeclaredShaderAssets(
  Iterable<String> assets,
  Set<String> declaredShaderAssets,
) {
  return assets
      .where((asset) => !declaredShaderAssets.contains(asset))
      .toSet()
      .toList()
    ..sort();
}

void expectAssetsExist(Iterable<String> assets,
    {String fileReason = 'must exist'}) {
  final missingAssets = missingShaderAssets(assets);

  expect(
    missingAssets,
    isEmpty,
    reason: 'Missing shader assets ($fileReason): ${missingAssets.join(', ')}',
  );
}

void expectAssetsDeclaredAndExist(
  Iterable<String> assets,
  Set<String> declaredShaderAssets, {
  String fileReason = 'must exist',
}) {
  final undeclaredAssets = undeclaredShaderAssets(assets, declaredShaderAssets);
  final missingAssets = missingShaderAssets(assets);

  expect(
    undeclaredAssets,
    isEmpty,
    reason: 'Undeclared shader assets: ${undeclaredAssets.join(', ')}',
  );
  expect(
    missingAssets,
    isEmpty,
    reason: 'Missing shader assets ($fileReason): ${missingAssets.join(', ')}',
  );
}
