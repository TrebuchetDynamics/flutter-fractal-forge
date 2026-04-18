// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1221_m_bius_a_i_b_1_c_1_d_i_presets.dart';
import 'f1221_m_bius_a_i_b_1_c_1_d_i_variants.dart';
import 'f1221_m_bius_a_i_b_1_c_1_d_i_metadata.dart';

/// Möbius (a=I b=1 c=1 d=-I) — Escape-Time (Complex Plane).
class F1221MBiusAIB1C1DI extends EscapeTimeModule {
  F1221MBiusAIB1C1DI()
      : super(
          id: 'f1221_m_bius_a_i_b_1_c_1_d_i',
          shader: 'shaders/f1221_m_bius_a_i_b_1_c_1_d_i_gpu.frag',
        );

  @override
  F1221MBiusAIB1C1DIMetadata get metadata => F1221MBiusAIB1C1DIMetadata.instance;

  @override
  List<F1221MBiusAIB1C1DIPreset> get presets => F1221MBiusAIB1C1DIPresets.all;

  @override
  List<F1221MBiusAIB1C1DIVariant> get variants => F1221MBiusAIB1C1DIVariants.all;

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
