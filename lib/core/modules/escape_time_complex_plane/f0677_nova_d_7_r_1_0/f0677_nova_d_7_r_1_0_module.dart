// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0677_nova_d_7_r_1_0_presets.dart';
import 'f0677_nova_d_7_r_1_0_variants.dart';
import 'f0677_nova_d_7_r_1_0_metadata.dart';

/// Nova d=7 r=1.0 — Escape-Time (Complex Plane).
class F0677NovaD7R10 extends EscapeTimeModule {
  F0677NovaD7R10()
      : super(
          id: 'f0677_nova_d_7_r_1_0',
          shader: 'shaders/f0677_nova_d_7_r_1_0_gpu.frag',
        );

  @override
  F0677NovaD7R10Metadata get metadata => F0677NovaD7R10Metadata.instance;

  @override
  List<F0677NovaD7R10Preset> get presets => F0677NovaD7R10Presets.all;

  @override
  List<F0677NovaD7R10Variant> get variants => F0677NovaD7R10Variants.all;

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
