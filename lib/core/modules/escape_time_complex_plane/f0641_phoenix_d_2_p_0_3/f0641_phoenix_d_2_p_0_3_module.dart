// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0641_phoenix_d_2_p_0_3_presets.dart';
import 'f0641_phoenix_d_2_p_0_3_variants.dart';
import 'f0641_phoenix_d_2_p_0_3_metadata.dart';

/// Phoenix d=2 p=-0.3 — Escape-Time (Complex Plane).
class F0641PhoenixD2P03 extends EscapeTimeModule {
  F0641PhoenixD2P03()
      : super(
          id: 'f0641_phoenix_d_2_p_0_3',
          shader: 'shaders/f0641_phoenix_d_2_p_0_3_gpu.frag',
        );

  @override
  F0641PhoenixD2P03Metadata get metadata => F0641PhoenixD2P03Metadata.instance;

  @override
  List<F0641PhoenixD2P03Preset> get presets => F0641PhoenixD2P03Presets.all;

  @override
  List<F0641PhoenixD2P03Variant> get variants => F0641PhoenixD2P03Variants.all;

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
