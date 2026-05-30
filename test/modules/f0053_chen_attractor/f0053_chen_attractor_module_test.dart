// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0053_chen_attractor/f0053_chen_attractor_module.dart';

void main() {
  test('F0053ChenAttractor instantiates', () {
    final m = F0053ChenAttractor();
    expect(m.id, 'f0053_chen_attractor');
    expect(m.shader, 'shaders/f0053_chen_attractor_gpu.frag');
  });

  test('F0053ChenAttractor presets are well-formed', () {
    final m = F0053ChenAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0053ChenAttractor metadata is consistent', () {
    final m = F0053ChenAttractor();
    expect(m.metadata.id, m.id);
  });
}
