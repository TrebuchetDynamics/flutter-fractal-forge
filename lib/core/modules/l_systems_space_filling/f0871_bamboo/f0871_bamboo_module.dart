// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0871_bamboo_presets.dart';
import 'f0871_bamboo_variants.dart';
import 'f0871_bamboo_metadata.dart';

/// Bamboo — L-Systems & Space-Filling.
class F0871Bamboo extends LSystemModule {
  F0871Bamboo()
      : super(
          id: 'f0871_bamboo',
          shader: 'shaders/f0871_bamboo_gpu.frag',
        );

  @override
  F0871BambooMetadata get metadata => F0871BambooMetadata.instance;

  @override
  List<F0871BambooPreset> get presets => F0871BambooPresets.all;

  @override
  List<F0871BambooVariant> get variants => F0871BambooVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
