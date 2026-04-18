// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i_presets.dart';
import 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i_variants.dart';
import 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i_metadata.dart';

/// Möbius (a=1+i b=1 c=1 d=1-i) — Escape-Time (Complex Plane).
class F1218MBiusA1IB1C1D1I extends EscapeTimeModule {
  F1218MBiusA1IB1C1D1I()
      : super(
          id: 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i',
          shader: 'shaders/f1218_m_bius_a_1_i_b_1_c_1_d_1_i_gpu.frag',
        );

  @override
  F1218MBiusA1IB1C1D1IMetadata get metadata => F1218MBiusA1IB1C1D1IMetadata.instance;

  @override
  List<F1218MBiusA1IB1C1D1IPreset> get presets => F1218MBiusA1IB1C1D1IPresets.all;

  @override
  List<F1218MBiusA1IB1C1D1IVariant> get variants => F1218MBiusA1IB1C1D1IVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
