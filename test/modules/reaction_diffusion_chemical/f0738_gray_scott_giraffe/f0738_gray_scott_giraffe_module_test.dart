// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0738_gray_scott_giraffe/f0738_gray_scott_giraffe_module.dart';

void main() {
  test('F0738GrayScottGiraffe instantiates', () {
    final m = F0738GrayScottGiraffe();
    expect(m.id, 'f0738_gray_scott_giraffe');
    expect(m.shader, 'shaders/f0738_gray_scott_giraffe_gpu.frag');
  });

  test('F0738GrayScottGiraffe presets are well-formed', () {
    final m = F0738GrayScottGiraffe();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0738GrayScottGiraffe metadata is consistent', () {
    final m = F0738GrayScottGiraffe();
    expect(m.metadata.id, m.id);
  });
}
