// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0010_secant_method/f0010_secant_method_module.dart';

void main() {
  test('F0010SecantMethod instantiates', () {
    final m = F0010SecantMethod();
    expect(m.id, 'f0010_secant_method');
    expect(m.shader, 'shaders/f0010_secant_method_gpu.frag');
  });

  test('F0010SecantMethod presets are well-formed', () {
    final m = F0010SecantMethod();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0010SecantMethod metadata is consistent', () {
    final m = F0010SecantMethod();
    expect(m.metadata.id, m.id);
  });
}
