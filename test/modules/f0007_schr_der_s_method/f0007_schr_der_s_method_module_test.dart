// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0007_schr_der_s_method/f0007_schr_der_s_method_module.dart';

void main() {
  test('F0007SchrDerSMethod instantiates', () {
    final m = F0007SchrDerSMethod();
    expect(m.id, 'f0007_schr_der_s_method');
    expect(m.shader, 'shaders/f0007_schr_der_s_method_gpu.frag');
  });

  test('F0007SchrDerSMethod presets are well-formed', () {
    final m = F0007SchrDerSMethod();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0007SchrDerSMethod metadata is consistent', () {
    final m = F0007SchrDerSMethod();
    expect(m.metadata.id, m.id);
  });
}
