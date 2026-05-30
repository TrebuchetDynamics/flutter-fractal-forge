// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0275_menger_sponge_2d_carpet/f0275_menger_sponge_2d_carpet_module.dart';

void main() {
  test('F0275MengerSponge2dCarpet instantiates', () {
    final m = F0275MengerSponge2dCarpet();
    expect(m.id, 'f0275_menger_sponge_2d_carpet');
    expect(m.shader, 'shaders/f0275_menger_sponge_2d_carpet_gpu.frag');
  });

  test('F0275MengerSponge2dCarpet presets are well-formed', () {
    final m = F0275MengerSponge2dCarpet();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0275MengerSponge2dCarpet metadata is consistent', () {
    final m = F0275MengerSponge2dCarpet();
    expect(m.metadata.id, m.id);
  });
}
