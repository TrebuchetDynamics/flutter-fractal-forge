// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0734_gray_scott_chaos/f0734_gray_scott_chaos_module.dart';

void main() {
  test('F0734GrayScottChaos instantiates', () {
    final m = F0734GrayScottChaos();
    expect(m.id, 'f0734_gray_scott_chaos');
    expect(m.shader, 'shaders/f0734_gray_scott_chaos_gpu.frag');
  });

  test('F0734GrayScottChaos presets are well-formed', () {
    final m = F0734GrayScottChaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0734GrayScottChaos metadata is consistent', () {
    final m = F0734GrayScottChaos();
    expect(m.metadata.id, m.id);
  });
}
