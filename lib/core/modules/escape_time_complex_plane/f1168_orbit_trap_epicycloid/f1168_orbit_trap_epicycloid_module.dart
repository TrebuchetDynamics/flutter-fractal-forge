// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1168_orbit_trap_epicycloid_presets.dart';
import 'f1168_orbit_trap_epicycloid_variants.dart';
import 'f1168_orbit_trap_epicycloid_metadata.dart';

/// Orbit Trap Epicycloid — Escape-Time (Complex Plane).
class F1168OrbitTrapEpicycloid extends EscapeTimeModule {
  F1168OrbitTrapEpicycloid()
      : super(
          id: 'f1168_orbit_trap_epicycloid',
          shader: 'shaders/f1168_orbit_trap_epicycloid_gpu.frag',
        );

  @override
  F1168OrbitTrapEpicycloidMetadata get metadata => F1168OrbitTrapEpicycloidMetadata.instance;

  @override
  List<F1168OrbitTrapEpicycloidPreset> get presets => F1168OrbitTrapEpicycloidPresets.all;

  @override
  List<F1168OrbitTrapEpicycloidVariant> get variants => F1168OrbitTrapEpicycloidVariants.all;

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
