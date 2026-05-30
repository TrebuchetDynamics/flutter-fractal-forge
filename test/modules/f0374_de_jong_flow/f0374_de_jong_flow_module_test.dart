// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0374_de_jong_flow/f0374_de_jong_flow_module.dart';

void main() {
  test('F0374DeJongFlow instantiates', () {
    final m = F0374DeJongFlow();
    expect(m.id, 'f0374_de_jong_flow');
    expect(m.shader, 'shaders/f0374_de_jong_flow_gpu.frag');
  });

  test('F0374DeJongFlow presets are well-formed', () {
    final m = F0374DeJongFlow();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0374DeJongFlow metadata is consistent', () {
    final m = F0374DeJongFlow();
    expect(m.metadata.id, m.id);
  });
}
