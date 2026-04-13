// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0643_phoenix_d_2_p_0_1_presets.dart';
import 'f0643_phoenix_d_2_p_0_1_variants.dart';
import 'f0643_phoenix_d_2_p_0_1_metadata.dart';

/// Phoenix d=2 p=0.1 — Escape-Time (Complex Plane).
class F0643PhoenixD2P01 extends EscapeTimeModule {
  F0643PhoenixD2P01()
      : super(
          id: 'f0643_phoenix_d_2_p_0_1',
          shader: 'shaders/f0643_phoenix_d_2_p_0_1_gpu.frag',
        );

  @override
  F0643PhoenixD2P01Metadata get metadata => F0643PhoenixD2P01Metadata.instance;

  @override
  List<F0643PhoenixD2P01Preset> get presets => F0643PhoenixD2P01Presets.all;

  @override
  List<F0643PhoenixD2P01Variant> get variants => F0643PhoenixD2P01Variants.all;

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
