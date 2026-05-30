// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1222_latt_s_map_degree_4_weierstrass/f1222_latt_s_map_degree_4_weierstrass_module.dart';

void main() {
  test('F1222LattSMapDegree4Weierstrass instantiates', () {
    final m = F1222LattSMapDegree4Weierstrass();
    expect(m.id, 'f1222_latt_s_map_degree_4_weierstrass');
    expect(m.shader, 'shaders/f1222_latt_s_map_degree_4_weierstrass_gpu.frag');
  });

  test('F1222LattSMapDegree4Weierstrass presets are well-formed', () {
    final m = F1222LattSMapDegree4Weierstrass();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1222LattSMapDegree4Weierstrass metadata is consistent', () {
    final m = F1222LattSMapDegree4Weierstrass();
    expect(m.metadata.id, m.id);
  });
}
