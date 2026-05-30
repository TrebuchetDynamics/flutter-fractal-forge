// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0011_m_ller_s_method/f0011_m_ller_s_method_module.dart';

void main() {
  test('F0011MLlerSMethod instantiates', () {
    final m = F0011MLlerSMethod();
    expect(m.id, 'f0011_m_ller_s_method');
    expect(m.shader, 'shaders/f0011_m_ller_s_method_gpu.frag');
  });

  test('F0011MLlerSMethod presets are well-formed', () {
    final m = F0011MLlerSMethod();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0011MLlerSMethod metadata is consistent', () {
    final m = F0011MLlerSMethod();
    expect(m.metadata.id, m.id);
  });
}
