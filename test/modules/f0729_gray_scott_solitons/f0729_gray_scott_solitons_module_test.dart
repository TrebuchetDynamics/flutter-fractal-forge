// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0729_gray_scott_solitons/f0729_gray_scott_solitons_module.dart';

void main() {
  test('F0729GrayScottSolitons instantiates', () {
    final m = F0729GrayScottSolitons();
    expect(m.id, 'f0729_gray_scott_solitons');
    expect(m.shader, 'shaders/f0729_gray_scott_solitons_gpu.frag');
  });

  test('F0729GrayScottSolitons presets are well-formed', () {
    final m = F0729GrayScottSolitons();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0729GrayScottSolitons metadata is consistent', () {
    final m = F0729GrayScottSolitons();
    expect(m.metadata.id, m.id);
  });
}
