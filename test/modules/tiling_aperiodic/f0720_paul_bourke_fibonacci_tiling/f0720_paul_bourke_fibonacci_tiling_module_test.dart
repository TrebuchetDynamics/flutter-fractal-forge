// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0720_paul_bourke_fibonacci_tiling/f0720_paul_bourke_fibonacci_tiling_module.dart';

void main() {
  test('F0720PaulBourkeFibonacciTiling instantiates', () {
    final m = F0720PaulBourkeFibonacciTiling();
    expect(m.id, 'f0720_paul_bourke_fibonacci_tiling');
    expect(m.shader, 'shaders/f0720_paul_bourke_fibonacci_tiling_gpu.frag');
  });

  test('F0720PaulBourkeFibonacciTiling presets are well-formed', () {
    final m = F0720PaulBourkeFibonacciTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0720PaulBourkeFibonacciTiling metadata is consistent', () {
    final m = F0720PaulBourkeFibonacciTiling();
    expect(m.metadata.id, m.id);
  });
}
