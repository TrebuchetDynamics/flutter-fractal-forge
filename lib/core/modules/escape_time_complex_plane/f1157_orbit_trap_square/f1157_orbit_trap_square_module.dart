// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1157_orbit_trap_square_presets.dart';
import 'f1157_orbit_trap_square_variants.dart';
import 'f1157_orbit_trap_square_metadata.dart';

/// Orbit Trap Square — Escape-Time (Complex Plane).
class F1157OrbitTrapSquare extends EscapeTimeModule {
  F1157OrbitTrapSquare()
      : super(
          id: 'f1157_orbit_trap_square',
          shader: 'shaders/f1157_orbit_trap_square_gpu.frag',
        );

  @override
  F1157OrbitTrapSquareMetadata get metadata => F1157OrbitTrapSquareMetadata.instance;

  @override
  List<F1157OrbitTrapSquarePreset> get presets => F1157OrbitTrapSquarePresets.all;

  @override
  List<F1157OrbitTrapSquareVariant> get variants => F1157OrbitTrapSquareVariants.all;

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
