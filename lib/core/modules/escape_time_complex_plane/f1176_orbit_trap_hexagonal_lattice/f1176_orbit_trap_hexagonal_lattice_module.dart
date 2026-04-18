// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1176_orbit_trap_hexagonal_lattice_presets.dart';
import 'f1176_orbit_trap_hexagonal_lattice_variants.dart';
import 'f1176_orbit_trap_hexagonal_lattice_metadata.dart';

/// Orbit Trap Hexagonal Lattice — Escape-Time (Complex Plane).
class F1176OrbitTrapHexagonalLattice extends EscapeTimeModule {
  F1176OrbitTrapHexagonalLattice()
      : super(
          id: 'f1176_orbit_trap_hexagonal_lattice',
          shader: 'shaders/f1176_orbit_trap_hexagonal_lattice_gpu.frag',
        );

  @override
  F1176OrbitTrapHexagonalLatticeMetadata get metadata => F1176OrbitTrapHexagonalLatticeMetadata.instance;

  @override
  List<F1176OrbitTrapHexagonalLatticePreset> get presets => F1176OrbitTrapHexagonalLatticePresets.all;

  @override
  List<F1176OrbitTrapHexagonalLatticeVariant> get variants => F1176OrbitTrapHexagonalLatticeVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
