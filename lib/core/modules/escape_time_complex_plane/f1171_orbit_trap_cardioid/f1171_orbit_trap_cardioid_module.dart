// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1171_orbit_trap_cardioid_presets.dart';
import 'f1171_orbit_trap_cardioid_variants.dart';
import 'f1171_orbit_trap_cardioid_metadata.dart';

/// Orbit Trap Cardioid — Escape-Time (Complex Plane).
class F1171OrbitTrapCardioid extends EscapeTimeModule {
  F1171OrbitTrapCardioid()
      : super(
          id: 'f1171_orbit_trap_cardioid',
          shader: 'shaders/f1171_orbit_trap_cardioid_gpu.frag',
        );

  @override
  F1171OrbitTrapCardioidMetadata get metadata => F1171OrbitTrapCardioidMetadata.instance;

  @override
  List<F1171OrbitTrapCardioidPreset> get presets => F1171OrbitTrapCardioidPresets.all;

  @override
  List<F1171OrbitTrapCardioidVariant> get variants => F1171OrbitTrapCardioidVariants.all;

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
