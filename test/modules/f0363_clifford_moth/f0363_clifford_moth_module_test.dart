// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0363_clifford_moth/f0363_clifford_moth_module.dart';

void main() {
  test('F0363CliffordMoth instantiates', () {
    final m = F0363CliffordMoth();
    expect(m.id, 'f0363_clifford_moth');
    expect(m.shader, 'shaders/f0363_clifford_moth_gpu.frag');
  });

  test('F0363CliffordMoth presets are well-formed', () {
    final m = F0363CliffordMoth();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0363CliffordMoth metadata is consistent', () {
    final m = F0363CliffordMoth();
    expect(m.metadata.id, m.id);
  });
}
