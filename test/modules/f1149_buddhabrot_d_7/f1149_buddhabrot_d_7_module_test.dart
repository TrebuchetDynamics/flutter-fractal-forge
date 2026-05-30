// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1149_buddhabrot_d_7/f1149_buddhabrot_d_7_module.dart';

void main() {
  test('F1149BuddhabrotD7 instantiates', () {
    final m = F1149BuddhabrotD7();
    expect(m.id, 'f1149_buddhabrot_d_7');
    expect(m.shader, 'shaders/f1149_buddhabrot_d_7_gpu.frag');
  });

  test('F1149BuddhabrotD7 presets are well-formed', () {
    final m = F1149BuddhabrotD7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1149BuddhabrotD7 metadata is consistent', () {
    final m = F1149BuddhabrotD7();
    expect(m.metadata.id, m.id);
  });
}
