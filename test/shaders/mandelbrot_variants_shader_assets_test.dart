import 'dart:io';

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late final Set<String> declaredShaderAssets;

  setUpAll(() {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    declaredShaderAssets = (flutter['shaders'] as YamlList).cast<String>().toSet();
  });

  test('catalog Mandelbrot variant shader assets are declared and present', () {
    final assets = escapeTimeCatalog
        .map((config) => config.shaderAsset)
        .where((asset) => asset.startsWith('shaders/escape_time_family/mandelbrot_variants/'))
        .toList();

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

    for (final asset in assets) {
      expect(declaredShaderAssets, contains(asset), reason: '$asset must be declared');
      expect(File(asset).existsSync(), isTrue, reason: '$asset file must exist');
    }
  });
}
