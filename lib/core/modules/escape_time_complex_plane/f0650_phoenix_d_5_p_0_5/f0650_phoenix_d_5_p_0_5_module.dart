// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0650_phoenix_d_5_p_0_5_presets.dart';
import 'f0650_phoenix_d_5_p_0_5_variants.dart';
import 'f0650_phoenix_d_5_p_0_5_metadata.dart';

/// Phoenix d=5 p=-0.5 — Escape-Time (Complex Plane).
class F0650PhoenixD5P05 extends EscapeTimeModule {
  F0650PhoenixD5P05()
      : super(
          id: 'f0650_phoenix_d_5_p_0_5',
          shader: 'shaders/f0650_phoenix_d_5_p_0_5_gpu.frag',
        );

  @override
  F0650PhoenixD5P05Metadata get metadata => F0650PhoenixD5P05Metadata.instance;

  @override
  List<F0650PhoenixD5P05Preset> get presets => F0650PhoenixD5P05Presets.all;

  @override
  List<F0650PhoenixD5P05Variant> get variants => F0650PhoenixD5P05Variants.all;

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
