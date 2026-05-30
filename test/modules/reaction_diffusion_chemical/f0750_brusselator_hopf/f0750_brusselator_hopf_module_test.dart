// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0750_brusselator_hopf/f0750_brusselator_hopf_module.dart';

void main() {
  test('F0750BrusselatorHopf instantiates', () {
    final m = F0750BrusselatorHopf();
    expect(m.id, 'f0750_brusselator_hopf');
    expect(m.shader, 'shaders/f0750_brusselator_hopf_gpu.frag');
  });

  test('F0750BrusselatorHopf presets are well-formed', () {
    final m = F0750BrusselatorHopf();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0750BrusselatorHopf metadata is consistent', () {
    final m = F0750BrusselatorHopf();
    expect(m.metadata.id, m.id);
  });
}
