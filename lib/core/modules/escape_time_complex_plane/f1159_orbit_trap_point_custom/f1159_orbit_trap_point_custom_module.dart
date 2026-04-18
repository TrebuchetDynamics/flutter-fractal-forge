// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1159_orbit_trap_point_custom_presets.dart';
import 'f1159_orbit_trap_point_custom_variants.dart';
import 'f1159_orbit_trap_point_custom_metadata.dart';

/// Orbit Trap Point (Custom) — Escape-Time (Complex Plane).
class F1159OrbitTrapPointCustom extends EscapeTimeModule {
  F1159OrbitTrapPointCustom()
      : super(
          id: 'f1159_orbit_trap_point_custom',
          shader: 'shaders/f1159_orbit_trap_point_custom_gpu.frag',
        );

  @override
  F1159OrbitTrapPointCustomMetadata get metadata => F1159OrbitTrapPointCustomMetadata.instance;

  @override
  List<F1159OrbitTrapPointCustomPreset> get presets => F1159OrbitTrapPointCustomPresets.all;

  @override
  List<F1159OrbitTrapPointCustomVariant> get variants => F1159OrbitTrapPointCustomVariants.all;

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
