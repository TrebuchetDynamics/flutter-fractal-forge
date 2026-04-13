// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0642_phoenix_d_2_p_0_2_presets.dart';
import 'f0642_phoenix_d_2_p_0_2_variants.dart';
import 'f0642_phoenix_d_2_p_0_2_metadata.dart';

/// Phoenix d=2 p=-0.2 — Escape-Time (Complex Plane).
class F0642PhoenixD2P02 extends EscapeTimeModule {
  F0642PhoenixD2P02()
      : super(
          id: 'f0642_phoenix_d_2_p_0_2',
          shader: 'shaders/f0642_phoenix_d_2_p_0_2_gpu.frag',
        );

  @override
  F0642PhoenixD2P02Metadata get metadata => F0642PhoenixD2P02Metadata.instance;

  @override
  List<F0642PhoenixD2P02Preset> get presets => F0642PhoenixD2P02Presets.all;

  @override
  List<F0642PhoenixD2P02Variant> get variants => F0642PhoenixD2P02Variants.all;

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
