// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0165_unit_circle/f0165_unit_circle_module.dart';

void main() {
  test('F0165UnitCircle instantiates', () {
    final m = F0165UnitCircle();
    expect(m.id, 'f0165_unit_circle');
    expect(m.shader, 'shaders/f0165_unit_circle_gpu.frag');
  });

  test('F0165UnitCircle presets are well-formed', () {
    final m = F0165UnitCircle();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0165UnitCircle metadata is consistent', () {
    final m = F0165UnitCircle();
    expect(m.metadata.id, m.id);
  });
}
