// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0730_gray_scott_stripes/f0730_gray_scott_stripes_module.dart';

void main() {
  test('F0730GrayScottStripes instantiates', () {
    final m = F0730GrayScottStripes();
    expect(m.id, 'f0730_gray_scott_stripes');
    expect(m.shader, 'shaders/f0730_gray_scott_stripes_gpu.frag');
  });

  test('F0730GrayScottStripes presets are well-formed', () {
    final m = F0730GrayScottStripes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0730GrayScottStripes metadata is consistent', () {
    final m = F0730GrayScottStripes();
    expect(m.metadata.id, m.id);
  });
}
