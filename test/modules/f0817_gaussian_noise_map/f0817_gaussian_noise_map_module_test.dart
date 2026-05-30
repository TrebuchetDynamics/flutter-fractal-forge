// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0817_gaussian_noise_map/f0817_gaussian_noise_map_module.dart';

void main() {
  test('F0817GaussianNoiseMap instantiates', () {
    final m = F0817GaussianNoiseMap();
    expect(m.id, 'f0817_gaussian_noise_map');
    expect(m.shader, 'shaders/f0817_gaussian_noise_map_gpu.frag');
  });

  test('F0817GaussianNoiseMap presets are well-formed', () {
    final m = F0817GaussianNoiseMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0817GaussianNoiseMap metadata is consistent', () {
    final m = F0817GaussianNoiseMap();
    expect(m.metadata.id, m.id);
  });
}
