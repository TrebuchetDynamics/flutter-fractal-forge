// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0673_nova_d_4_r_0_7_presets.dart';
import 'f0673_nova_d_4_r_0_7_variants.dart';
import 'f0673_nova_d_4_r_0_7_metadata.dart';

/// Nova d=4 r=0.7 — Escape-Time (Complex Plane).
class F0673NovaD4R07 extends EscapeTimeModule {
  F0673NovaD4R07()
      : super(
          id: 'f0673_nova_d_4_r_0_7',
          shader: 'shaders/f0673_nova_d_4_r_0_7_gpu.frag',
        );

  @override
  F0673NovaD4R07Metadata get metadata => F0673NovaD4R07Metadata.instance;

  @override
  List<F0673NovaD4R07Preset> get presets => F0673NovaD4R07Presets.all;

  @override
  List<F0673NovaD4R07Variant> get variants => F0673NovaD4R07Variants.all;

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
