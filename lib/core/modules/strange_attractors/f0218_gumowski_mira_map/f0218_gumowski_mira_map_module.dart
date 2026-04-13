// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0218_gumowski_mira_map_presets.dart';
import 'f0218_gumowski_mira_map_variants.dart';
import 'f0218_gumowski_mira_map_metadata.dart';

/// Gumowski-Mira Map — Strange Attractors.
class F0218GumowskiMiraMap extends AttractorModule {
  F0218GumowskiMiraMap()
      : super(
          id: 'f0218_gumowski_mira_map',
          shader: 'shaders/f0218_gumowski_mira_map_gpu.frag',
        );

  @override
  F0218GumowskiMiraMapMetadata get metadata => F0218GumowskiMiraMapMetadata.instance;

  @override
  List<F0218GumowskiMiraMapPreset> get presets => F0218GumowskiMiraMapPresets.all;

  @override
  List<F0218GumowskiMiraMapVariant> get variants => F0218GumowskiMiraMapVariants.all;

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
