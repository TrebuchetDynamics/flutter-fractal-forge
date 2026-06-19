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

List<String> expectDeclaredShaderAssetsForRoot(
  Set<String> declaredShaderAssets,
  String shaderRoot, {
  Object? matcher,
  String fileReason = 'must exist',
}) {
  final assets =
      declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

  expect(assets, matcher ?? isNotEmpty);
  expectAssetsExist(assets, fileReason: fileReason);
  return assets;
}

List<String> expectCatalogShaderAssetsForRoot(
  Set<String> declaredShaderAssets,
  String shaderRoot, {
  Object? matcher,
  String fileReason = 'must exist',
}) {
  final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

  expect(assets, matcher ?? isNotEmpty);
  expectAssetsDeclaredAndExist(
    assets,
    declaredShaderAssets,
    fileReason: fileReason,
  );
  return assets;
}

void expectAssetsUnderSubfolders(
  Iterable<String> assets,
  String shaderRoot, {
  Object? matcher,
  String? reason,
}) {
  expect(
    assets.where((asset) => asset.substring(shaderRoot.length).contains('/')),
    matcher ?? hasLength(assets.length),
    reason: reason,
  );
}

void expectNoRootShaderFiles(String shaderRoot, {String? reason}) {
  final rootShaderFiles = Directory(shaderRoot)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.frag'))
      .map((file) => file.path)
      .toList()
    ..sort();

  expect(rootShaderFiles, isEmpty, reason: reason);
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
