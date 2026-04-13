// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0094_multibrot_z_19_presets.dart';
import 'f0094_multibrot_z_19_variants.dart';
import 'f0094_multibrot_z_19_metadata.dart';

/// Multibrot z^19 — Escape-Time (Complex Plane).
class F0094MultibrotZ19 extends EscapeTimeModule {
  F0094MultibrotZ19()
      : super(
          id: 'f0094_multibrot_z_19',
          shader: 'shaders/f0094_multibrot_z_19_gpu.frag',
        );

  @override
  F0094MultibrotZ19Metadata get metadata => F0094MultibrotZ19Metadata.instance;

  @override
  List<F0094MultibrotZ19Preset> get presets => F0094MultibrotZ19Presets.all;

  @override
  List<F0094MultibrotZ19Variant> get variants => F0094MultibrotZ19Variants.all;

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
