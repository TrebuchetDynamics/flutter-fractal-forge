import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/mandelbrot_variants/';
  const expectedShaderAssetsByResponsibility = <String, Set<String>>{
    'exterior_coloring': <String>{
      'mandelbrot_curvature_avg_gpu.frag',
      'mandelbrot_de_gpu.frag',
      'mandelbrot_orbit_trap_gpu.frag',
      'mandelbrot_stripe_avg_gpu.frag',
      'mandelbrot_tia_gpu.frag',
    },
    'iterative_maps': <String>{
      'angrybrot_gpu.frag',
      'crazybrot_gpu.frag',
      'damaged_doublebrot_gpu.frag',
      'exp_additive_mandelbrot_gpu.frag',
      'inverse_mandelbrot_gpu.frag',
      'lightningbrot_gpu.frag',
      'simonbrot_gpu.frag',
      'undefined_gpu.frag',
    },
    'singular_perturbations': <String>{
      'mandelpinski_gpu.frag',
    },
  };
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('catalog Mandelbrot variant shader assets are declared and present', () {
    final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    final expectedAssets = expectedShaderAssetsByResponsibility.entries
        .expand(
          (entry) => entry.value.map(
            (asset) => '$shaderRoot${entry.key}/$asset',
          ),
        )
        .toSet();
    final rootAssets = assets.where((asset) {
      final relativeAsset = asset.substring(shaderRoot.length);
      return !relativeAsset.contains('/');
    }).toList();

    expect(assets.toSet(), containsAll(expectedAssets));
    expect(rootAssets, isEmpty,
        reason: 'Mandelbrot variants should live in responsibility subfolders');
    expectAssetsDeclaredAndExist(assets, declaredShaderAssets,
        fileReason: 'file must exist');
  });
}
