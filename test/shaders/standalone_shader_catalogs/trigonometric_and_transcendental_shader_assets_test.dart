import 'package:flutter_test/flutter_test.dart';

import '../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/trigonometric_and_transcendental/';
  const elementaryTrigRoot = '${shaderRoot}elementary_trig/';
  const hyperbolicRoot = '${shaderRoot}hyperbolic/';
  const exponentialIterationRoot = '${shaderRoot}exponential_iteration/';
  const specialFunctionsRoot = '${shaderRoot}special_functions/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared trigonometric and transcendental shader assets exist on disk',
      () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(assets, hasLength(35));
    expect(assets.where((asset) => asset.startsWith(elementaryTrigRoot)),
        hasLength(16));
    expect(assets.where((asset) => asset.startsWith(hyperbolicRoot)),
        hasLength(7));
    expect(assets.where((asset) => asset.startsWith(exponentialIterationRoot)),
        hasLength(4));
    expect(assets.where((asset) => asset.startsWith(specialFunctionsRoot)),
        hasLength(8));
    expect(
      assets.where((asset) => asset.substring(shaderRoot.length).contains('/')),
      hasLength(35),
      reason:
          'Trigonometric and transcendental shaders belong in responsibility subfolders',
    );
    expectAssetsExist(assets);
  });

  test(
      'catalog trigonometric and transcendental shader assets are declared in pubspec',
      () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(catalogAssets, hasLength(35));
    expect(catalogAssets.where((asset) => asset.startsWith(elementaryTrigRoot)),
        hasLength(16));
    expect(catalogAssets.where((asset) => asset.startsWith(hyperbolicRoot)),
        hasLength(7));
    expect(
        catalogAssets
            .where((asset) => asset.startsWith(exponentialIterationRoot)),
        hasLength(4));
    expect(
        catalogAssets.where((asset) => asset.startsWith(specialFunctionsRoot)),
        hasLength(8));
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
