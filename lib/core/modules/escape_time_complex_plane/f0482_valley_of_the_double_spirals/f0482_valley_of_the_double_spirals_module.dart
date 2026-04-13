// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0482_valley_of_the_double_spirals_presets.dart';
import 'f0482_valley_of_the_double_spirals_variants.dart';
import 'f0482_valley_of_the_double_spirals_metadata.dart';

/// Valley of the Double Spirals — Escape-Time (Complex Plane).
class F0482ValleyOfTheDoubleSpirals extends EscapeTimeModule {
  F0482ValleyOfTheDoubleSpirals()
      : super(
          id: 'f0482_valley_of_the_double_spirals',
          shader: 'shaders/f0482_valley_of_the_double_spirals_gpu.frag',
        );

  @override
  F0482ValleyOfTheDoubleSpiralsMetadata get metadata => F0482ValleyOfTheDoubleSpiralsMetadata.instance;

  @override
  List<F0482ValleyOfTheDoubleSpiralsPreset> get presets => F0482ValleyOfTheDoubleSpiralsPresets.all;

  @override
  List<F0482ValleyOfTheDoubleSpiralsVariant> get variants => F0482ValleyOfTheDoubleSpiralsVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
