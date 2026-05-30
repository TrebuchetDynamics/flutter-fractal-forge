// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0740_turing_stripes_anisotropic/f0740_turing_stripes_anisotropic_module.dart';

void main() {
  test('F0740TuringStripesAnisotropic instantiates', () {
    final m = F0740TuringStripesAnisotropic();
    expect(m.id, 'f0740_turing_stripes_anisotropic');
    expect(m.shader, 'shaders/f0740_turing_stripes_anisotropic_gpu.frag');
  });

  test('F0740TuringStripesAnisotropic presets are well-formed', () {
    final m = F0740TuringStripesAnisotropic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0740TuringStripesAnisotropic metadata is consistent', () {
    final m = F0740TuringStripesAnisotropic();
    expect(m.metadata.id, m.id);
  });
}
