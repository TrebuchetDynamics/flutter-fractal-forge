// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1167_orbit_trap_text_m_presets.dart';
import 'f1167_orbit_trap_text_m_variants.dart';
import 'f1167_orbit_trap_text_m_metadata.dart';

/// Orbit Trap Text 'M' — Escape-Time (Complex Plane).
class F1167OrbitTrapTextM extends EscapeTimeModule {
  F1167OrbitTrapTextM()
      : super(
          id: 'f1167_orbit_trap_text_m',
          shader: 'shaders/f1167_orbit_trap_text_m_gpu.frag',
        );

  @override
  F1167OrbitTrapTextMMetadata get metadata => F1167OrbitTrapTextMMetadata.instance;

  @override
  List<F1167OrbitTrapTextMPreset> get presets => F1167OrbitTrapTextMPresets.all;

  @override
  List<F1167OrbitTrapTextMVariant> get variants => F1167OrbitTrapTextMVariants.all;

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
