// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1146_buddhabrot_d_4/f1146_buddhabrot_d_4_module.dart';

void main() {
  test('F1146BuddhabrotD4 instantiates', () {
    final m = F1146BuddhabrotD4();
    expect(m.id, 'f1146_buddhabrot_d_4');
    expect(m.shader, 'shaders/f1146_buddhabrot_d_4_gpu.frag');
  });

  test('F1146BuddhabrotD4 presets are well-formed', () {
    final m = F1146BuddhabrotD4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1146BuddhabrotD4 metadata is consistent', () {
    final m = F1146BuddhabrotD4();
    expect(m.metadata.id, m.id);
  });
}
