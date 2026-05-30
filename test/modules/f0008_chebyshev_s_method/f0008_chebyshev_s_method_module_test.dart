// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0008_chebyshev_s_method/f0008_chebyshev_s_method_module.dart';

void main() {
  test('F0008ChebyshevSMethod instantiates', () {
    final m = F0008ChebyshevSMethod();
    expect(m.id, 'f0008_chebyshev_s_method');
    expect(m.shader, 'shaders/f0008_chebyshev_s_method_gpu.frag');
  });

  test('F0008ChebyshevSMethod presets are well-formed', () {
    final m = F0008ChebyshevSMethod();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0008ChebyshevSMethod metadata is consistent', () {
    final m = F0008ChebyshevSMethod();
    expect(m.metadata.id, m.id);
  });
}
