// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0476_triple_antenna_point/f0476_triple_antenna_point_module.dart';

void main() {
  test('F0476TripleAntennaPoint instantiates', () {
    final m = F0476TripleAntennaPoint();
    expect(m.id, 'f0476_triple_antenna_point');
    expect(m.shader, 'shaders/f0476_triple_antenna_point_gpu.frag');
  });

  test('F0476TripleAntennaPoint presets are well-formed', () {
    final m = F0476TripleAntennaPoint();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0476TripleAntennaPoint metadata is consistent', () {
    final m = F0476TripleAntennaPoint();
    expect(m.metadata.id, m.id);
  });
}
