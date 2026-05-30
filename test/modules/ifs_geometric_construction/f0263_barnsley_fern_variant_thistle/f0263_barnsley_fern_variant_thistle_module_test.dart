// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0263_barnsley_fern_variant_thistle/f0263_barnsley_fern_variant_thistle_module.dart';

void main() {
  test('F0263BarnsleyFernVariantThistle instantiates', () {
    final m = F0263BarnsleyFernVariantThistle();
    expect(m.id, 'f0263_barnsley_fern_variant_thistle');
    expect(m.shader, 'shaders/f0263_barnsley_fern_variant_thistle_gpu.frag');
  });

  test('F0263BarnsleyFernVariantThistle presets are well-formed', () {
    final m = F0263BarnsleyFernVariantThistle();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0263BarnsleyFernVariantThistle metadata is consistent', () {
    final m = F0263BarnsleyFernVariantThistle();
    expect(m.metadata.id, m.id);
  });
}
