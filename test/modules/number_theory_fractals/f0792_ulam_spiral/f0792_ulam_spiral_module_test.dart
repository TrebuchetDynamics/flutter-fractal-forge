// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0792_ulam_spiral/f0792_ulam_spiral_module.dart';

void main() {
  test('F0792UlamSpiral instantiates', () {
    final m = F0792UlamSpiral();
    expect(m.id, 'f0792_ulam_spiral');
    expect(m.shader, 'shaders/f0792_ulam_spiral_gpu.frag');
  });

  test('F0792UlamSpiral presets are well-formed', () {
    final m = F0792UlamSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0792UlamSpiral metadata is consistent', () {
    final m = F0792UlamSpiral();
    expect(m.metadata.id, m.id);
  });
}
