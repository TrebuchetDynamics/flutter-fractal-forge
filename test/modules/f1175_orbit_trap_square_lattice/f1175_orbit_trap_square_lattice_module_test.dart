// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1175_orbit_trap_square_lattice/f1175_orbit_trap_square_lattice_module.dart';

void main() {
  test('F1175OrbitTrapSquareLattice instantiates', () {
    final m = F1175OrbitTrapSquareLattice();
    expect(m.id, 'f1175_orbit_trap_square_lattice');
    expect(m.shader, 'shaders/f1175_orbit_trap_square_lattice_gpu.frag');
  });

  test('F1175OrbitTrapSquareLattice presets are well-formed', () {
    final m = F1175OrbitTrapSquareLattice();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1175OrbitTrapSquareLattice metadata is consistent', () {
    final m = F1175OrbitTrapSquareLattice();
    expect(m.metadata.id, m.id);
  });
}
