// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0640_phoenix_d_2_p_0_4_presets.dart';
import 'f0640_phoenix_d_2_p_0_4_variants.dart';
import 'f0640_phoenix_d_2_p_0_4_metadata.dart';

/// Phoenix d=2 p=-0.4 — Escape-Time (Complex Plane).
class F0640PhoenixD2P04 extends EscapeTimeModule {
  F0640PhoenixD2P04()
      : super(
          id: 'f0640_phoenix_d_2_p_0_4',
          shader: 'shaders/f0640_phoenix_d_2_p_0_4_gpu.frag',
        );

  @override
  F0640PhoenixD2P04Metadata get metadata => F0640PhoenixD2P04Metadata.instance;

  @override
  List<F0640PhoenixD2P04Preset> get presets => F0640PhoenixD2P04Presets.all;

  @override
  List<F0640PhoenixD2P04Variant> get variants => F0640PhoenixD2P04Variants.all;

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
