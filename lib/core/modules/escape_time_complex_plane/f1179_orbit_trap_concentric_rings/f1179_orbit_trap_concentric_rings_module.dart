// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1179_orbit_trap_concentric_rings_presets.dart';
import 'f1179_orbit_trap_concentric_rings_variants.dart';
import 'f1179_orbit_trap_concentric_rings_metadata.dart';

/// Orbit Trap Concentric Rings — Escape-Time (Complex Plane).
class F1179OrbitTrapConcentricRings extends EscapeTimeModule {
  F1179OrbitTrapConcentricRings()
      : super(
          id: 'f1179_orbit_trap_concentric_rings',
          shader: 'shaders/f1179_orbit_trap_concentric_rings_gpu.frag',
        );

  @override
  F1179OrbitTrapConcentricRingsMetadata get metadata => F1179OrbitTrapConcentricRingsMetadata.instance;

  @override
  List<F1179OrbitTrapConcentricRingsPreset> get presets => F1179OrbitTrapConcentricRingsPresets.all;

  @override
  List<F1179OrbitTrapConcentricRingsVariant> get variants => F1179OrbitTrapConcentricRingsVariants.all;

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
