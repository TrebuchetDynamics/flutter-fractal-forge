// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0733_gray_scott_self_replicating_spots/f0733_gray_scott_self_replicating_spots_module.dart';

void main() {
  test('F0733GrayScottSelfReplicatingSpots instantiates', () {
    final m = F0733GrayScottSelfReplicatingSpots();
    expect(m.id, 'f0733_gray_scott_self_replicating_spots');
    expect(
        m.shader, 'shaders/f0733_gray_scott_self_replicating_spots_gpu.frag');
  });

  test('F0733GrayScottSelfReplicatingSpots presets are well-formed', () {
    final m = F0733GrayScottSelfReplicatingSpots();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0733GrayScottSelfReplicatingSpots metadata is consistent', () {
    final m = F0733GrayScottSelfReplicatingSpots();
    expect(m.metadata.id, m.id);
  });
}
