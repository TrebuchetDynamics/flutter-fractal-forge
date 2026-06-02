import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hydrogen Orbital module is registered with volumetric controls', () {
    final module = ModuleRegistry().byId('hydrogen_orbital');

    expect(module.dimension, FractalDimension.threeD);
    expect(
      module.shaderAsset,
      'shaders/3d_and_hypercomplex/raymarched_volumes/hydrogen_orbital_gpu.frag',
    );
    expect(
      module.parameters.map((p) => p.id),
      containsAll([
        'densityGain',
        'noiseStrength',
        'radialScale',
        'steps',
        'colorScheme',
      ]),
    );
    expect(module.defaultPreset.params['noiseStrength'], 1.0);
    expect(module.builtInPresets.map((p) => p.name), contains('Clean Y20'));
  });
}
