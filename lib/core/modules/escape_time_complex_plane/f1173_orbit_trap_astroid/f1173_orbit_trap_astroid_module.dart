// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1173_orbit_trap_astroid_presets.dart';
import 'f1173_orbit_trap_astroid_variants.dart';
import 'f1173_orbit_trap_astroid_metadata.dart';

/// Orbit Trap Astroid — Escape-Time (Complex Plane).
class F1173OrbitTrapAstroid extends EscapeTimeModule {
  F1173OrbitTrapAstroid()
      : super(
          id: 'f1173_orbit_trap_astroid',
          shader: 'shaders/f1173_orbit_trap_astroid_gpu.frag',
        );

  @override
  F1173OrbitTrapAstroidMetadata get metadata => F1173OrbitTrapAstroidMetadata.instance;

  @override
  List<F1173OrbitTrapAstroidPreset> get presets => F1173OrbitTrapAstroidPresets.all;

  @override
  List<F1173OrbitTrapAstroidVariant> get variants => F1173OrbitTrapAstroidVariants.all;

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
