// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1150_buddhabrot_d_8/f1150_buddhabrot_d_8_module.dart';

void main() {
  test('F1150BuddhabrotD8 instantiates', () {
    final m = F1150BuddhabrotD8();
    expect(m.id, 'f1150_buddhabrot_d_8');
    expect(m.shader, 'shaders/f1150_buddhabrot_d_8_gpu.frag');
  });

  test('F1150BuddhabrotD8 presets are well-formed', () {
    final m = F1150BuddhabrotD8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1150BuddhabrotD8 metadata is consistent', () {
    final m = F1150BuddhabrotD8();
    expect(m.metadata.id, m.id);
  });
}
