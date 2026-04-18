// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1154_buddhabrot_newton_z_3_1/f1154_buddhabrot_newton_z_3_1_module.dart';

void main() {
  test('F1154BuddhabrotNewtonZ31 instantiates', () {
    final m = F1154BuddhabrotNewtonZ31();
    expect(m.id, 'f1154_buddhabrot_newton_z_3_1');
    expect(m.shader, 'shaders/f1154_buddhabrot_newton_z_3_1_gpu.frag');
  });

  test('F1154BuddhabrotNewtonZ31 presets are well-formed', () {
    final m = F1154BuddhabrotNewtonZ31();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1154BuddhabrotNewtonZ31 metadata is consistent', () {
    final m = F1154BuddhabrotNewtonZ31();
    expect(m.metadata.id, m.id);
  });
}
