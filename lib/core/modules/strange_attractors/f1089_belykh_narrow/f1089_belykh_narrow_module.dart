// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1089_belykh_narrow_presets.dart';
import 'f1089_belykh_narrow_variants.dart';
import 'f1089_belykh_narrow_metadata.dart';

/// Belykh Narrow — Strange Attractors.
class F1089BelykhNarrow extends AttractorModule {
  F1089BelykhNarrow()
      : super(
          id: 'f1089_belykh_narrow',
          shader: 'shaders/f1089_belykh_narrow_gpu.frag',
        );

  @override
  F1089BelykhNarrowMetadata get metadata => F1089BelykhNarrowMetadata.instance;

  @override
  List<F1089BelykhNarrowPreset> get presets => F1089BelykhNarrowPresets.all;

  @override
  List<F1089BelykhNarrowVariant> get variants => F1089BelykhNarrowVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
