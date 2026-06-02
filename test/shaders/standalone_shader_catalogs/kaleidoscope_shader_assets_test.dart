import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/kaleidoscopes/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared kaleidoscope shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, isNotEmpty);
    expectAssetsExist(assets);
  });

  test('catalog kaleidoscope shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, isNotEmpty);
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });

  test('kaleidoscope shader assets are grouped by responsibility', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);
    final subfolders = assets
        .map((asset) => asset.substring(shaderRoot.length).split('/').first)
        .toSet();
    final directlyNestedAssets = assets
        .where((asset) =>
            asset.substring(shaderRoot.length).split('/').length != 2)
        .toList();
    final rootShaderFiles = Directory(shaderRoot)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.frag'))
        .map((file) => file.path)
        .toList();

    expect(
        subfolders, {'classic_symmetry', 'radial_ornaments', 'textured_light'});
    expect(directlyNestedAssets, isEmpty,
        reason: 'kaleidoscope shaders should live exactly one subfolder deep');
    expect(rootShaderFiles, isEmpty,
        reason: 'root-level kaleidoscope .frag files are topology debt');
  });
}
