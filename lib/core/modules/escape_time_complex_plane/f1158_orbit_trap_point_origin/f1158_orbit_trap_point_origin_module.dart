// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1158_orbit_trap_point_origin_presets.dart';
import 'f1158_orbit_trap_point_origin_variants.dart';
import 'f1158_orbit_trap_point_origin_metadata.dart';

/// Orbit Trap Point (Origin) — Escape-Time (Complex Plane).
class F1158OrbitTrapPointOrigin extends EscapeTimeModule {
  F1158OrbitTrapPointOrigin()
      : super(
          id: 'f1158_orbit_trap_point_origin',
          shader: 'shaders/f1158_orbit_trap_point_origin_gpu.frag',
        );

  @override
  F1158OrbitTrapPointOriginMetadata get metadata => F1158OrbitTrapPointOriginMetadata.instance;

  @override
  List<F1158OrbitTrapPointOriginPreset> get presets => F1158OrbitTrapPointOriginPresets.all;

  @override
  List<F1158OrbitTrapPointOriginVariant> get variants => F1158OrbitTrapPointOriginVariants.all;

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
