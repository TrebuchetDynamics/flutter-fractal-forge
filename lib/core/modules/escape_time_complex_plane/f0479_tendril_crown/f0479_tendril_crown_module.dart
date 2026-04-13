// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0479_tendril_crown_presets.dart';
import 'f0479_tendril_crown_variants.dart';
import 'f0479_tendril_crown_metadata.dart';

/// Tendril Crown — Escape-Time (Complex Plane).
class F0479TendrilCrown extends EscapeTimeModule {
  F0479TendrilCrown()
      : super(
          id: 'f0479_tendril_crown',
          shader: 'shaders/f0479_tendril_crown_gpu.frag',
        );

  @override
  F0479TendrilCrownMetadata get metadata => F0479TendrilCrownMetadata.instance;

  @override
  List<F0479TendrilCrownPreset> get presets => F0479TendrilCrownPresets.all;

  @override
  List<F0479TendrilCrownVariant> get variants => F0479TendrilCrownVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 15000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
