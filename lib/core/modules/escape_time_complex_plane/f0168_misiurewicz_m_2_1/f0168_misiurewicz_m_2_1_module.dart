// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0168_misiurewicz_m_2_1_presets.dart';
import 'f0168_misiurewicz_m_2_1_variants.dart';
import 'f0168_misiurewicz_m_2_1_metadata.dart';

/// Misiurewicz M_{2,1} — Escape-Time (Complex Plane).
class F0168MisiurewiczM21 extends EscapeTimeModule {
  F0168MisiurewiczM21()
      : super(
          id: 'f0168_misiurewicz_m_2_1',
          shader: 'shaders/f0168_misiurewicz_m_2_1_gpu.frag',
        );

  @override
  F0168MisiurewiczM21Metadata get metadata => F0168MisiurewiczM21Metadata.instance;

  @override
  List<F0168MisiurewiczM21Preset> get presets => F0168MisiurewiczM21Presets.all;

  @override
  List<F0168MisiurewiczM21Variant> get variants => F0168MisiurewiczM21Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
