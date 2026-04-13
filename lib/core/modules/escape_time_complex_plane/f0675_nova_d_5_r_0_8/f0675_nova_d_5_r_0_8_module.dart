// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0675_nova_d_5_r_0_8_presets.dart';
import 'f0675_nova_d_5_r_0_8_variants.dart';
import 'f0675_nova_d_5_r_0_8_metadata.dart';

/// Nova d=5 r=0.8 — Escape-Time (Complex Plane).
class F0675NovaD5R08 extends EscapeTimeModule {
  F0675NovaD5R08()
      : super(
          id: 'f0675_nova_d_5_r_0_8',
          shader: 'shaders/f0675_nova_d_5_r_0_8_gpu.frag',
        );

  @override
  F0675NovaD5R08Metadata get metadata => F0675NovaD5R08Metadata.instance;

  @override
  List<F0675NovaD5R08Preset> get presets => F0675NovaD5R08Presets.all;

  @override
  List<F0675NovaD5R08Variant> get variants => F0675NovaD5R08Variants.all;

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
