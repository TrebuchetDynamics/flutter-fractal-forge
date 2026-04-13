// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0102_multibrot_d_8_5_presets.dart';
import 'f0102_multibrot_d_8_5_variants.dart';
import 'f0102_multibrot_d_8_5_metadata.dart';

/// Multibrot d=8.5 — Escape-Time (Complex Plane).
class F0102MultibrotD85 extends EscapeTimeModule {
  F0102MultibrotD85()
      : super(
          id: 'f0102_multibrot_d_8_5',
          shader: 'shaders/f0102_multibrot_d_8_5_gpu.frag',
        );

  @override
  F0102MultibrotD85Metadata get metadata => F0102MultibrotD85Metadata.instance;

  @override
  List<F0102MultibrotD85Preset> get presets => F0102MultibrotD85Presets.all;

  @override
  List<F0102MultibrotD85Variant> get variants => F0102MultibrotD85Variants.all;

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
