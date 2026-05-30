// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0371_de_jong_peacock/f0371_de_jong_peacock_module.dart';

void main() {
  test('F0371DeJongPeacock instantiates', () {
    final m = F0371DeJongPeacock();
    expect(m.id, 'f0371_de_jong_peacock');
    expect(m.shader, 'shaders/f0371_de_jong_peacock_gpu.frag');
  });

  test('F0371DeJongPeacock presets are well-formed', () {
    final m = F0371DeJongPeacock();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0371DeJongPeacock metadata is consistent', () {
    final m = F0371DeJongPeacock();
    expect(m.metadata.id, m.id);
  });
}
