// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1151_buddhabrot_d_10/f1151_buddhabrot_d_10_module.dart';

void main() {
  test('F1151BuddhabrotD10 instantiates', () {
    final m = F1151BuddhabrotD10();
    expect(m.id, 'f1151_buddhabrot_d_10');
    expect(m.shader, 'shaders/f1151_buddhabrot_d_10_gpu.frag');
  });

  test('F1151BuddhabrotD10 presets are well-formed', () {
    final m = F1151BuddhabrotD10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1151BuddhabrotD10 metadata is consistent', () {
    final m = F1151BuddhabrotD10();
    expect(m.metadata.id, m.id);
  });
}
