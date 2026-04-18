// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1176_orbit_trap_hexagonal_lattice/f1176_orbit_trap_hexagonal_lattice_module.dart';

void main() {
  test('F1176OrbitTrapHexagonalLattice instantiates', () {
    final m = F1176OrbitTrapHexagonalLattice();
    expect(m.id, 'f1176_orbit_trap_hexagonal_lattice');
    expect(m.shader, 'shaders/f1176_orbit_trap_hexagonal_lattice_gpu.frag');
  });

  test('F1176OrbitTrapHexagonalLattice presets are well-formed', () {
    final m = F1176OrbitTrapHexagonalLattice();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1176OrbitTrapHexagonalLattice metadata is consistent', () {
    final m = F1176OrbitTrapHexagonalLattice();
    expect(m.metadata.id, m.id);
  });
}
