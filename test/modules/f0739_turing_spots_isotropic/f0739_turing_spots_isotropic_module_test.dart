// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0739_turing_spots_isotropic/f0739_turing_spots_isotropic_module.dart';

void main() {
  test('F0739TuringSpotsIsotropic instantiates', () {
    final m = F0739TuringSpotsIsotropic();
    expect(m.id, 'f0739_turing_spots_isotropic');
    expect(m.shader, 'shaders/f0739_turing_spots_isotropic_gpu.frag');
  });

  test('F0739TuringSpotsIsotropic presets are well-formed', () {
    final m = F0739TuringSpotsIsotropic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0739TuringSpotsIsotropic metadata is consistent', () {
    final m = F0739TuringSpotsIsotropic();
    expect(m.metadata.id, m.id);
  });
}
