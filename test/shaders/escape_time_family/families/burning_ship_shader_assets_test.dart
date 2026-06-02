import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/families/burning_ship/';
  const parameterPlaneRoot = '${shaderRoot}parameter_plane/';
  const juliaSetsRoot = '${shaderRoot}julia_sets/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Burning Ship shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, hasLength(14));
    expect(assets.where((asset) => asset.startsWith(parameterPlaneRoot)),
        hasLength(7));
    expect(assets.where((asset) => asset.startsWith(juliaSetsRoot)),
        hasLength(7));
    expect(
      assets.where((asset) => asset.substring(shaderRoot.length).contains('/')),
      hasLength(14),
      reason: 'Burning Ship shaders belong in responsibility subfolders',
    );
    expectAssetsExist(assets);
  });

  test('catalog Burning Ship shader assets are declared in pubspec', () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, hasLength(14));
    expect(catalogAssets.where((asset) => asset.startsWith(parameterPlaneRoot)),
        hasLength(7));
    expect(catalogAssets.where((asset) => asset.startsWith(juliaSetsRoot)),
        hasLength(7));
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
