// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1166_orbit_trap_text_a_presets.dart';
import 'f1166_orbit_trap_text_a_variants.dart';
import 'f1166_orbit_trap_text_a_metadata.dart';

/// Orbit Trap Text 'A' — Escape-Time (Complex Plane).
class F1166OrbitTrapTextA extends EscapeTimeModule {
  F1166OrbitTrapTextA()
      : super(
          id: 'f1166_orbit_trap_text_a',
          shader: 'shaders/f1166_orbit_trap_text_a_gpu.frag',
        );

  @override
  F1166OrbitTrapTextAMetadata get metadata => F1166OrbitTrapTextAMetadata.instance;

  @override
  List<F1166OrbitTrapTextAPreset> get presets => F1166OrbitTrapTextAPresets.all;

  @override
  List<F1166OrbitTrapTextAVariant> get variants => F1166OrbitTrapTextAVariants.all;

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
