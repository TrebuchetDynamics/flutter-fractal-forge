// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1228_shishikura_map/f1228_shishikura_map_module.dart';

void main() {
  test('F1228ShishikuraMap instantiates', () {
    final m = F1228ShishikuraMap();
    expect(m.id, 'f1228_shishikura_map');
    expect(m.shader, 'shaders/f1228_shishikura_map_gpu.frag');
  });

  test('F1228ShishikuraMap presets are well-formed', () {
    final m = F1228ShishikuraMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1228ShishikuraMap metadata is consistent', () {
    final m = F1228ShishikuraMap();
    expect(m.metadata.id, m.id);
  });
}
