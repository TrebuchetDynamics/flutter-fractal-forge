// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1175_orbit_trap_square_lattice_presets.dart';
import 'f1175_orbit_trap_square_lattice_variants.dart';
import 'f1175_orbit_trap_square_lattice_metadata.dart';

/// Orbit Trap Square Lattice — Escape-Time (Complex Plane).
class F1175OrbitTrapSquareLattice extends EscapeTimeModule {
  F1175OrbitTrapSquareLattice()
      : super(
          id: 'f1175_orbit_trap_square_lattice',
          shader:
              'shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag',
        );

  @override
  F1175OrbitTrapSquareLatticeMetadata get metadata =>
      F1175OrbitTrapSquareLatticeMetadata.instance;

  @override
  List<F1175OrbitTrapSquareLatticePreset> get presets =>
      F1175OrbitTrapSquareLatticePresets.all;

  @override
  List<F1175OrbitTrapSquareLatticeVariant> get variants =>
      F1175OrbitTrapSquareLatticeVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.none;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
    p.setInt('trapMode', 20);
  }
}
