// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1098_lozi_compact_presets.dart';
import 'f1098_lozi_compact_variants.dart';
import 'f1098_lozi_compact_metadata.dart';

/// Lozi Compact — Strange Attractors.
class F1098LoziCompact extends AttractorModule {
  F1098LoziCompact()
      : super(
          id: 'f1098_lozi_compact',
          shader: 'shaders/f1098_lozi_compact_gpu.frag',
        );

  @override
  F1098LoziCompactMetadata get metadata => F1098LoziCompactMetadata.instance;

  @override
  List<F1098LoziCompactPreset> get presets => F1098LoziCompactPresets.all;

  @override
  List<F1098LoziCompactVariant> get variants => F1098LoziCompactVariants.all;

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
