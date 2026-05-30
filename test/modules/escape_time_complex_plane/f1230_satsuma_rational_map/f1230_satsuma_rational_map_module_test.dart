// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1230_satsuma_rational_map/f1230_satsuma_rational_map_module.dart';

void main() {
  test('F1230SatsumaRationalMap instantiates', () {
    final m = F1230SatsumaRationalMap();
    expect(m.id, 'f1230_satsuma_rational_map');
    expect(m.shader, 'shaders/f1230_satsuma_rational_map_gpu.frag');
  });

  test('F1230SatsumaRationalMap presets are well-formed', () {
    final m = F1230SatsumaRationalMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1230SatsumaRationalMap metadata is consistent', () {
    final m = F1230SatsumaRationalMap();
    expect(m.metadata.id, m.id);
  });
}
