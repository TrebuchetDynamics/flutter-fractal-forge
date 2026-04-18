// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1099_lozi_strange_presets.dart';
import 'f1099_lozi_strange_variants.dart';
import 'f1099_lozi_strange_metadata.dart';

/// Lozi Strange — Strange Attractors.
class F1099LoziStrange extends AttractorModule {
  F1099LoziStrange()
      : super(
          id: 'f1099_lozi_strange',
          shader: 'shaders/f1099_lozi_strange_gpu.frag',
        );

  @override
  F1099LoziStrangeMetadata get metadata => F1099LoziStrangeMetadata.instance;

  @override
  List<F1099LoziStrangePreset> get presets => F1099LoziStrangePresets.all;

  @override
  List<F1099LoziStrangeVariant> get variants => F1099LoziStrangeVariants.all;

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
