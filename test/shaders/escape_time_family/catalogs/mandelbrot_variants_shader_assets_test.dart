import 'package:flutter_test/flutter_test.dart';

import '../../support/shader_asset_expectations.dart';

void main() {
  const shaderRoot = 'shaders/escape_time_family/mandelbrot_variants/';
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    declaredShaderAssets = loadDeclaredShaderAssets();
  });

  test('catalog Mandelbrot variant shader assets are declared and present', () {
    final assets = escapeTimeShaderAssetsStartingWith(shaderRoot);

    expect(
      assets.map((asset) => asset.split('/').last).toSet(),
      containsAll(<String>{
        'angrybrot_gpu.frag',
        'crazybrot_gpu.frag',
        'damaged_doublebrot_gpu.frag',
        'exp_additive_mandelbrot_gpu.frag',
        'inverse_mandelbrot_gpu.frag',
        'lightningbrot_gpu.frag',
        'mandelbrot_curvature_avg_gpu.frag',
        'mandelbrot_de_gpu.frag',
        'mandelbrot_orbit_trap_gpu.frag',
        'mandelbrot_stripe_avg_gpu.frag',
        'mandelbrot_tia_gpu.frag',
        'mandelpinski_gpu.frag',
        'simonbrot_gpu.frag',
        'undefined_gpu.frag',
      }),
    );

    expectAssetsDeclaredAndExist(assets, declaredShaderAssets,
        fileReason: 'file must exist');
  });
}
