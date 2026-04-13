// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0451_misiurewicz_m_3_1_presets.dart';
import 'f0451_misiurewicz_m_3_1_variants.dart';
import 'f0451_misiurewicz_m_3_1_metadata.dart';

/// Misiurewicz M(3,1) — Escape-Time (Complex Plane).
class F0451MisiurewiczM31 extends EscapeTimeModule {
  F0451MisiurewiczM31()
      : super(
          id: 'f0451_misiurewicz_m_3_1',
          shader: 'shaders/f0451_misiurewicz_m_3_1_gpu.frag',
        );

  @override
  F0451MisiurewiczM31Metadata get metadata => F0451MisiurewiczM31Metadata.instance;

  @override
  List<F0451MisiurewiczM31Preset> get presets => F0451MisiurewiczM31Presets.all;

  @override
  List<F0451MisiurewiczM31Variant> get variants => F0451MisiurewiczM31Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
