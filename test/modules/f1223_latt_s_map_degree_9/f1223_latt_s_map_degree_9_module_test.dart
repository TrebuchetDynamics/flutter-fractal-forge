// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1223_latt_s_map_degree_9/f1223_latt_s_map_degree_9_module.dart';

void main() {
  test('F1223LattSMapDegree9 instantiates', () {
    final m = F1223LattSMapDegree9();
    expect(m.id, 'f1223_latt_s_map_degree_9');
    expect(m.shader, 'shaders/f1223_latt_s_map_degree_9_gpu.frag');
  });

  test('F1223LattSMapDegree9 presets are well-formed', () {
    final m = F1223LattSMapDegree9();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1223LattSMapDegree9 metadata is consistent', () {
    final m = F1223LattSMapDegree9();
    expect(m.metadata.id, m.id);
  });
}
