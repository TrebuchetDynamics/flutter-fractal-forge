// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0751_lengyel_epstein_cima/f0751_lengyel_epstein_cima_module.dart';

void main() {
  test('F0751LengyelEpsteinCima instantiates', () {
    final m = F0751LengyelEpsteinCima();
    expect(m.id, 'f0751_lengyel_epstein_cima');
    expect(m.shader, 'shaders/f0751_lengyel_epstein_cima_gpu.frag');
  });

  test('F0751LengyelEpsteinCima presets are well-formed', () {
    final m = F0751LengyelEpsteinCima();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0751LengyelEpsteinCima metadata is consistent', () {
    final m = F0751LengyelEpsteinCima();
    expect(m.metadata.id, m.id);
  });
}
