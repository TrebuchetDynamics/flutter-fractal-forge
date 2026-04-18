// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1100_lozi_wide_presets.dart';
import 'f1100_lozi_wide_variants.dart';
import 'f1100_lozi_wide_metadata.dart';

/// Lozi Wide — Strange Attractors.
class F1100LoziWide extends AttractorModule {
  F1100LoziWide()
      : super(
          id: 'f1100_lozi_wide',
          shader: 'shaders/f1100_lozi_wide_gpu.frag',
        );

  @override
  F1100LoziWideMetadata get metadata => F1100LoziWideMetadata.instance;

  @override
  List<F1100LoziWidePreset> get presets => F1100LoziWidePresets.all;

  @override
  List<F1100LoziWideVariant> get variants => F1100LoziWideVariants.all;

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
