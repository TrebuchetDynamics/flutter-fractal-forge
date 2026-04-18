// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1148_buddhabrot_d_6/f1148_buddhabrot_d_6_module.dart';

void main() {
  test('F1148BuddhabrotD6 instantiates', () {
    final m = F1148BuddhabrotD6();
    expect(m.id, 'f1148_buddhabrot_d_6');
    expect(m.shader, 'shaders/f1148_buddhabrot_d_6_gpu.frag');
  });

  test('F1148BuddhabrotD6 presets are well-formed', () {
    final m = F1148BuddhabrotD6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1148BuddhabrotD6 metadata is consistent', () {
    final m = F1148BuddhabrotD6();
    expect(m.metadata.id, m.id);
  });
}
