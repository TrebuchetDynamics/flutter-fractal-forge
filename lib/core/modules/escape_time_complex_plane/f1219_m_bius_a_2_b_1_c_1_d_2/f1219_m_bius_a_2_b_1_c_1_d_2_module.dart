// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1219_m_bius_a_2_b_1_c_1_d_2_presets.dart';
import 'f1219_m_bius_a_2_b_1_c_1_d_2_variants.dart';
import 'f1219_m_bius_a_2_b_1_c_1_d_2_metadata.dart';

/// Möbius (a=2 b=1 c=1 d=2) — Escape-Time (Complex Plane).
class F1219MBiusA2B1C1D2 extends EscapeTimeModule {
  F1219MBiusA2B1C1D2()
      : super(
          id: 'f1219_m_bius_a_2_b_1_c_1_d_2',
          shader: 'shaders/f1219_m_bius_a_2_b_1_c_1_d_2_gpu.frag',
        );

  @override
  F1219MBiusA2B1C1D2Metadata get metadata => F1219MBiusA2B1C1D2Metadata.instance;

  @override
  List<F1219MBiusA2B1C1D2Preset> get presets => F1219MBiusA2B1C1D2Presets.all;

  @override
  List<F1219MBiusA2B1C1D2Variant> get variants => F1219MBiusA2B1C1D2Variants.all;

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
