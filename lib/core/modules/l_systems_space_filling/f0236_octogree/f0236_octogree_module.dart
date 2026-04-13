// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0236_octogree_presets.dart';
import 'f0236_octogree_variants.dart';
import 'f0236_octogree_metadata.dart';

/// Octogree — L-Systems & Space-Filling.
class F0236Octogree extends LSystemModule {
  F0236Octogree()
      : super(
          id: 'f0236_octogree',
          shader: 'shaders/f0236_octogree_gpu.frag',
        );

  @override
  F0236OctogreeMetadata get metadata => F0236OctogreeMetadata.instance;

  @override
  List<F0236OctogreePreset> get presets => F0236OctogreePresets.all;

  @override
  List<F0236OctogreeVariant> get variants => F0236OctogreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
