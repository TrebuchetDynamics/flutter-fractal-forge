// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0644_phoenix_d_2_p_0_25_presets.dart';
import 'f0644_phoenix_d_2_p_0_25_variants.dart';
import 'f0644_phoenix_d_2_p_0_25_metadata.dart';

/// Phoenix d=2 p=0.25 — Escape-Time (Complex Plane).
class F0644PhoenixD2P025 extends EscapeTimeModule {
  F0644PhoenixD2P025()
      : super(
          id: 'f0644_phoenix_d_2_p_0_25',
          shader: 'shaders/f0644_phoenix_d_2_p_0_25_gpu.frag',
        );

  @override
  F0644PhoenixD2P025Metadata get metadata => F0644PhoenixD2P025Metadata.instance;

  @override
  List<F0644PhoenixD2P025Preset> get presets => F0644PhoenixD2P025Presets.all;

  @override
  List<F0644PhoenixD2P025Variant> get variants => F0644PhoenixD2P025Variants.all;

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
