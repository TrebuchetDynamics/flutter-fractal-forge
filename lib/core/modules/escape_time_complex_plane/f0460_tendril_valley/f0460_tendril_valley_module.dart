// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0460_tendril_valley_presets.dart';
import 'f0460_tendril_valley_variants.dart';
import 'f0460_tendril_valley_metadata.dart';

/// Tendril Valley — Escape-Time (Complex Plane).
class F0460TendrilValley extends EscapeTimeModule {
  F0460TendrilValley()
      : super(
          id: 'f0460_tendril_valley',
          shader: 'shaders/f0460_tendril_valley_gpu.frag',
        );

  @override
  F0460TendrilValleyMetadata get metadata => F0460TendrilValleyMetadata.instance;

  @override
  List<F0460TendrilValleyPreset> get presets => F0460TendrilValleyPresets.all;

  @override
  List<F0460TendrilValleyVariant> get variants => F0460TendrilValleyVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
