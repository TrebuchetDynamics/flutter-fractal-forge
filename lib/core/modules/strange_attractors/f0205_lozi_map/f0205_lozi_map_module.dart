// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0205_lozi_map_presets.dart';
import 'f0205_lozi_map_variants.dart';
import 'f0205_lozi_map_metadata.dart';

/// Lozi Map — Strange Attractors.
class F0205LoziMap extends AttractorModule {
  F0205LoziMap()
      : super(
          id: 'f0205_lozi_map',
          shader: 'shaders/f0205_lozi_map_gpu.frag',
        );

  @override
  F0205LoziMapMetadata get metadata => F0205LoziMapMetadata.instance;

  @override
  List<F0205LoziMapPreset> get presets => F0205LoziMapPresets.all;

  @override
  List<F0205LoziMapVariant> get variants => F0205LoziMapVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
