// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0264_barnsley_mutant_fern/f0264_barnsley_mutant_fern_module.dart';

void main() {
  test('F0264BarnsleyMutantFern instantiates', () {
    final m = F0264BarnsleyMutantFern();
    expect(m.id, 'f0264_barnsley_mutant_fern');
    expect(m.shader, 'shaders/f0264_barnsley_mutant_fern_gpu.frag');
  });

  test('F0264BarnsleyMutantFern presets are well-formed', () {
    final m = F0264BarnsleyMutantFern();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0264BarnsleyMutantFern metadata is consistent', () {
    final m = F0264BarnsleyMutantFern();
    expect(m.metadata.id, m.id);
  });
}
