// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0242_lindenmayer_algae_1_presets.dart';
import 'f0242_lindenmayer_algae_1_variants.dart';
import 'f0242_lindenmayer_algae_1_metadata.dart';

/// Lindenmayer Algae 1 — L-Systems & Space-Filling.
class F0242LindenmayerAlgae1 extends LSystemModule {
  F0242LindenmayerAlgae1()
      : super(
          id: 'f0242_lindenmayer_algae_1',
          shader: 'shaders/f0242_lindenmayer_algae_1_gpu.frag',
        );

  @override
  F0242LindenmayerAlgae1Metadata get metadata => F0242LindenmayerAlgae1Metadata.instance;

  @override
  List<F0242LindenmayerAlgae1Preset> get presets => F0242LindenmayerAlgae1Presets.all;

  @override
  List<F0242LindenmayerAlgae1Variant> get variants => F0242LindenmayerAlgae1Variants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
