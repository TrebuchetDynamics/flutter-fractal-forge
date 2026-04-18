// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_presets.dart';
import 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_variants.dart';
import 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_metadata.dart';

/// Möbius (a=cos+i sin / b=1 / c=1 / d=cos-i sin) — Escape-Time (Complex Plane).
class F1220MBiusACosISinB1C1DCosISin extends EscapeTimeModule {
  F1220MBiusACosISinB1C1DCosISin()
      : super(
          id: 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin',
          shader: 'shaders/f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin_gpu.frag',
        );

  @override
  F1220MBiusACosISinB1C1DCosISinMetadata get metadata => F1220MBiusACosISinB1C1DCosISinMetadata.instance;

  @override
  List<F1220MBiusACosISinB1C1DCosISinPreset> get presets => F1220MBiusACosISinB1C1DCosISinPresets.all;

  @override
  List<F1220MBiusACosISinB1C1DCosISinVariant> get variants => F1220MBiusACosISinB1C1DCosISinVariants.all;

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
