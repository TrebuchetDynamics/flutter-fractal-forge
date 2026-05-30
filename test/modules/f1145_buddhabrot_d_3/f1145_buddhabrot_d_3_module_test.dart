// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1145_buddhabrot_d_3/f1145_buddhabrot_d_3_module.dart';

void main() {
  test('F1145BuddhabrotD3 instantiates', () {
    final m = F1145BuddhabrotD3();
    expect(m.id, 'f1145_buddhabrot_d_3');
    expect(m.shader, 'shaders/f1145_buddhabrot_d_3_gpu.frag');
  });

  test('F1145BuddhabrotD3 presets are well-formed', () {
    final m = F1145BuddhabrotD3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1145BuddhabrotD3 metadata is consistent', () {
    final m = F1145BuddhabrotD3();
    expect(m.metadata.id, m.id);
  });
}
