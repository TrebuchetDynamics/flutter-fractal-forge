// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0276_menger_sponge_3d/f0276_menger_sponge_3d_module.dart';

void main() {
  test('F0276MengerSponge3d instantiates', () {
    final m = F0276MengerSponge3d();
    expect(m.id, 'f0276_menger_sponge_3d');
    expect(m.shader, 'shaders/f0276_menger_sponge_3d_gpu.frag');
  });

  test('F0276MengerSponge3d presets are well-formed', () {
    final m = F0276MengerSponge3d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0276MengerSponge3d metadata is consistent', () {
    final m = F0276MengerSponge3d();
    expect(m.metadata.id, m.id);
  });
}
