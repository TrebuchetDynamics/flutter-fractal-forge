// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1164_orbit_trap_star_5_pointed_presets.dart';
import 'f1164_orbit_trap_star_5_pointed_variants.dart';
import 'f1164_orbit_trap_star_5_pointed_metadata.dart';

/// Orbit Trap Star (5-pointed) — Escape-Time (Complex Plane).
class F1164OrbitTrapStar5Pointed extends EscapeTimeModule {
  F1164OrbitTrapStar5Pointed()
      : super(
          id: 'f1164_orbit_trap_star_5_pointed',
          shader: 'shaders/f1164_orbit_trap_star_5_pointed_gpu.frag',
        );

  @override
  F1164OrbitTrapStar5PointedMetadata get metadata => F1164OrbitTrapStar5PointedMetadata.instance;

  @override
  List<F1164OrbitTrapStar5PointedPreset> get presets => F1164OrbitTrapStar5PointedPresets.all;

  @override
  List<F1164OrbitTrapStar5PointedVariant> get variants => F1164OrbitTrapStar5PointedVariants.all;

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
