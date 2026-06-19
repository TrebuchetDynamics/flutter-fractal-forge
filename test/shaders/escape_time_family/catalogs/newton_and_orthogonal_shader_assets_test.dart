import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/newton_and_orthogonal/';
  const expectedCatalogAssets = <String>{
    '${shaderRoot}high_order_root_methods/chebyshev_fractal_gpu.frag',
    '${shaderRoot}high_order_root_methods/laguerre_fractal_gpu.frag',
    '${shaderRoot}magnet_maps/magnet1_gpu.frag',
    '${shaderRoot}magnet_maps/magnet2_gpu.frag',
    '${shaderRoot}magnet_maps/magnet3_gpu.frag',
    '${shaderRoot}orthogonal_polynomial_maps/chebyshev_gpu.frag',
    '${shaderRoot}orthogonal_polynomial_maps/hermite_gpu.frag',
    '${shaderRoot}orthogonal_polynomial_maps/laguerre_gpu.frag',
    '${shaderRoot}orthogonal_polynomial_maps/legendre_gpu.frag',
    '${shaderRoot}series_maps/virial_gpu.frag',
  };

  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('declared Newton and orthogonal shader assets exist on disk', () {
    expectDeclaredShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: containsAll(expectedCatalogAssets),
    );
  });

  test('Newton and orthogonal shader assets stay in responsibility subfolders',
      () {
    final assets = <String>{
      ...declaredShaderAssetsStartingWith(declaredShaderAssets, shaderRoot),
      ...escapeTimeShaderAssetsStartingWith(shaderRoot),
    };

    final rootAssets = assets.where((asset) {
      final relativeAsset = asset.substring(shaderRoot.length);
      return !relativeAsset.contains('/');
    }).toList();

    expect(rootAssets, isEmpty);
  });

  test('catalog Newton and orthogonal shader assets are declared in pubspec',
      () {
    expectCatalogShaderAssetsForRoot(
      declaredShaderAssets,
      shaderRoot,
      matcher: containsAll(expectedCatalogAssets),
    );
  });
}
