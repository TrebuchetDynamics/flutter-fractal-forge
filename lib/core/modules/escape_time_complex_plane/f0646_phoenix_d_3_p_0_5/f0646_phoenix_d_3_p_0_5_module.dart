// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0646_phoenix_d_3_p_0_5_presets.dart';
import 'f0646_phoenix_d_3_p_0_5_variants.dart';
import 'f0646_phoenix_d_3_p_0_5_metadata.dart';

/// Phoenix d=3 p=-0.5 — Escape-Time (Complex Plane).
class F0646PhoenixD3P05 extends EscapeTimeModule {
  F0646PhoenixD3P05()
      : super(
          id: 'f0646_phoenix_d_3_p_0_5',
          shader: 'shaders/f0646_phoenix_d_3_p_0_5_gpu.frag',
        );

  @override
  F0646PhoenixD3P05Metadata get metadata => F0646PhoenixD3P05Metadata.instance;

  @override
  List<F0646PhoenixD3P05Preset> get presets => F0646PhoenixD3P05Presets.all;

  @override
  List<F0646PhoenixD3P05Variant> get variants => F0646PhoenixD3P05Variants.all;

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
