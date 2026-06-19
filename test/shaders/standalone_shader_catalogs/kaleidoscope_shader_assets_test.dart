import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/kaleidoscopes/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared kaleidoscope shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
  });

  test('catalog kaleidoscope shader assets are declared in pubspec', () {
    expectCatalogShaderAssetsForRoot(declaredShaderAssets, shaderRoot);
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
    expect(
        subfolders, {'classic_symmetry', 'radial_ornaments', 'textured_light'});
    expect(directlyNestedAssets, isEmpty,
        reason: 'kaleidoscope shaders should live exactly one subfolder deep');
    expectNoRootShaderFiles(shaderRoot,
        reason: 'root-level kaleidoscope .frag files are topology debt');
  });
}
