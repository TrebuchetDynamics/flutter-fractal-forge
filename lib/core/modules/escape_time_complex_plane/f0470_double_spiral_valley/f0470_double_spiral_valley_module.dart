// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0470_double_spiral_valley_presets.dart';
import 'f0470_double_spiral_valley_variants.dart';
import 'f0470_double_spiral_valley_metadata.dart';

/// Double Spiral Valley — Escape-Time (Complex Plane).
class F0470DoubleSpiralValley extends EscapeTimeModule {
  F0470DoubleSpiralValley()
      : super(
          id: 'f0470_double_spiral_valley',
          shader: 'shaders/f0470_double_spiral_valley_gpu.frag',
        );

  @override
  F0470DoubleSpiralValleyMetadata get metadata => F0470DoubleSpiralValleyMetadata.instance;

  @override
  List<F0470DoubleSpiralValleyPreset> get presets => F0470DoubleSpiralValleyPresets.all;

  @override
  List<F0470DoubleSpiralValleyVariant> get variants => F0470DoubleSpiralValleyVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 5000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
