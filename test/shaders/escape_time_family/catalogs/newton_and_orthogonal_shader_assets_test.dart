import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/newton_and_orthogonal/';
  const expectedCatalogBasenames = <String>{
    'chebyshev_fractal_gpu.frag',
    'chebyshev_gpu.frag',
    'hermite_gpu.frag',
    'laguerre_fractal_gpu.frag',
    'laguerre_gpu.frag',
    'legendre_gpu.frag',
    'magnet1_gpu.frag',
    'magnet2_gpu.frag',
    'magnet3_gpu.frag',
    'virial_gpu.frag',
  };

  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Newton and orthogonal shader assets exist on disk', () {
    final assets =
        declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot);

    expect(
      assets.map((asset) => asset.split('/').last).toSet(),
      containsAll(expectedCatalogBasenames),
    );
    expectAssetsExist(assets);
  });

  test('catalog Newton and orthogonal shader assets are declared in pubspec',
      () {
    final catalogAssets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(
      catalogAssets.map((asset) => asset.split('/').last).toSet(),
      containsAll(expectedCatalogBasenames),
    );
    expectAssetsDeclaredAndExist(catalogAssets, declaredShaderAssets);
  });
}
