// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0427_elephant_valley_presets.dart';
import 'f0427_elephant_valley_variants.dart';
import 'f0427_elephant_valley_metadata.dart';

/// Elephant Valley — Escape-Time (Complex Plane).
class F0427ElephantValley extends EscapeTimeModule {
  F0427ElephantValley()
      : super(
          id: 'f0427_elephant_valley',
          shader: 'shaders/f0427_elephant_valley_gpu.frag',
        );

  @override
  F0427ElephantValleyMetadata get metadata => F0427ElephantValleyMetadata.instance;

  @override
  List<F0427ElephantValleyPreset> get presets => F0427ElephantValleyPresets.all;

  @override
  List<F0427ElephantValleyVariant> get variants => F0427ElephantValleyVariants.all;

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
