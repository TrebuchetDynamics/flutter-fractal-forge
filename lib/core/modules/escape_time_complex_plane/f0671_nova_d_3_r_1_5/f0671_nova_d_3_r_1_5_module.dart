// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0671_nova_d_3_r_1_5_presets.dart';
import 'f0671_nova_d_3_r_1_5_variants.dart';
import 'f0671_nova_d_3_r_1_5_metadata.dart';

/// Nova d=3 r=1.5 — Escape-Time (Complex Plane).
class F0671NovaD3R15 extends EscapeTimeModule {
  F0671NovaD3R15()
      : super(
          id: 'f0671_nova_d_3_r_1_5',
          shader: 'shaders/f0671_nova_d_3_r_1_5_gpu.frag',
        );

  @override
  F0671NovaD3R15Metadata get metadata => F0671NovaD3R15Metadata.instance;

  @override
  List<F0671NovaD3R15Preset> get presets => F0671NovaD3R15Presets.all;

  @override
  List<F0671NovaD3R15Variant> get variants => F0671NovaD3R15Variants.all;

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
