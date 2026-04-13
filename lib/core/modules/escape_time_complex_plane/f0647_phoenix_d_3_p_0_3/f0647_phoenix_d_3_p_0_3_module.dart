// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0647_phoenix_d_3_p_0_3_presets.dart';
import 'f0647_phoenix_d_3_p_0_3_variants.dart';
import 'f0647_phoenix_d_3_p_0_3_metadata.dart';

/// Phoenix d=3 p=0.3 — Escape-Time (Complex Plane).
class F0647PhoenixD3P03 extends EscapeTimeModule {
  F0647PhoenixD3P03()
      : super(
          id: 'f0647_phoenix_d_3_p_0_3',
          shader: 'shaders/f0647_phoenix_d_3_p_0_3_gpu.frag',
        );

  @override
  F0647PhoenixD3P03Metadata get metadata => F0647PhoenixD3P03Metadata.instance;

  @override
  List<F0647PhoenixD3P03Preset> get presets => F0647PhoenixD3P03Presets.all;

  @override
  List<F0647PhoenixD3P03Variant> get variants => F0647PhoenixD3P03Variants.all;

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
