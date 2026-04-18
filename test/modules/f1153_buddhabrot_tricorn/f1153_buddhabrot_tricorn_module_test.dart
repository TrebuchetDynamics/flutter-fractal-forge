// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1153_buddhabrot_tricorn/f1153_buddhabrot_tricorn_module.dart';

void main() {
  test('F1153BuddhabrotTricorn instantiates', () {
    final m = F1153BuddhabrotTricorn();
    expect(m.id, 'f1153_buddhabrot_tricorn');
    expect(m.shader, 'shaders/f1153_buddhabrot_tricorn_gpu.frag');
  });

  test('F1153BuddhabrotTricorn presets are well-formed', () {
    final m = F1153BuddhabrotTricorn();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1153BuddhabrotTricorn metadata is consistent', () {
    final m = F1153BuddhabrotTricorn();
    expect(m.metadata.id, m.id);
  });
}
