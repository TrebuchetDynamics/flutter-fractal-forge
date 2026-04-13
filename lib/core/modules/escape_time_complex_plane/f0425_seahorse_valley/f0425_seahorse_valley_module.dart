// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0425_seahorse_valley_presets.dart';
import 'f0425_seahorse_valley_variants.dart';
import 'f0425_seahorse_valley_metadata.dart';

/// Seahorse Valley — Escape-Time (Complex Plane).
class F0425SeahorseValley extends EscapeTimeModule {
  F0425SeahorseValley()
      : super(
          id: 'f0425_seahorse_valley',
          shader: 'shaders/f0425_seahorse_valley_gpu.frag',
        );

  @override
  F0425SeahorseValleyMetadata get metadata => F0425SeahorseValleyMetadata.instance;

  @override
  List<F0425SeahorseValleyPreset> get presets => F0425SeahorseValleyPresets.all;

  @override
  List<F0425SeahorseValleyVariant> get variants => F0425SeahorseValleyVariants.all;

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
