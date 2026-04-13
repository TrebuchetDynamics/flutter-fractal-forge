// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0101_multibrot_d_7_5_presets.dart';
import 'f0101_multibrot_d_7_5_variants.dart';
import 'f0101_multibrot_d_7_5_metadata.dart';

/// Multibrot d=7.5 — Escape-Time (Complex Plane).
class F0101MultibrotD75 extends EscapeTimeModule {
  F0101MultibrotD75()
      : super(
          id: 'f0101_multibrot_d_7_5',
          shader: 'shaders/f0101_multibrot_d_7_5_gpu.frag',
        );

  @override
  F0101MultibrotD75Metadata get metadata => F0101MultibrotD75Metadata.instance;

  @override
  List<F0101MultibrotD75Preset> get presets => F0101MultibrotD75Presets.all;

  @override
  List<F0101MultibrotD75Variant> get variants => F0101MultibrotD75Variants.all;

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
