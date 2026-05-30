// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0355_clifford_disk/f0355_clifford_disk_module.dart';

void main() {
  test('F0355CliffordDisk instantiates', () {
    final m = F0355CliffordDisk();
    expect(m.id, 'f0355_clifford_disk');
    expect(m.shader, 'shaders/f0355_clifford_disk_gpu.frag');
  });

  test('F0355CliffordDisk presets are well-formed', () {
    final m = F0355CliffordDisk();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0355CliffordDisk metadata is consistent', () {
    final m = F0355CliffordDisk();
    expect(m.metadata.id, m.id);
  });
}
