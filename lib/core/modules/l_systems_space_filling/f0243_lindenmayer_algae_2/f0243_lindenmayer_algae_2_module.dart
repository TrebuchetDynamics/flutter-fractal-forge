// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0243_lindenmayer_algae_2_presets.dart';
import 'f0243_lindenmayer_algae_2_variants.dart';
import 'f0243_lindenmayer_algae_2_metadata.dart';

/// Lindenmayer Algae 2 — L-Systems & Space-Filling.
class F0243LindenmayerAlgae2 extends LSystemModule {
  F0243LindenmayerAlgae2()
      : super(
          id: 'f0243_lindenmayer_algae_2',
          shader: 'shaders/f0243_lindenmayer_algae_2_gpu.frag',
        );

  @override
  F0243LindenmayerAlgae2Metadata get metadata => F0243LindenmayerAlgae2Metadata.instance;

  @override
  List<F0243LindenmayerAlgae2Preset> get presets => F0243LindenmayerAlgae2Presets.all;

  @override
  List<F0243LindenmayerAlgae2Variant> get variants => F0243LindenmayerAlgae2Variants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
