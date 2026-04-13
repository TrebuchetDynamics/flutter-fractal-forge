// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0249_random_bush_presets.dart';
import 'f0249_random_bush_variants.dart';
import 'f0249_random_bush_metadata.dart';

/// Random Bush — L-Systems & Space-Filling.
class F0249RandomBush extends LSystemModule {
  F0249RandomBush()
      : super(
          id: 'f0249_random_bush',
          shader: 'shaders/f0249_random_bush_gpu.frag',
        );

  @override
  F0249RandomBushMetadata get metadata => F0249RandomBushMetadata.instance;

  @override
  List<F0249RandomBushPreset> get presets => F0249RandomBushPresets.all;

  @override
  List<F0249RandomBushVariant> get variants => F0249RandomBushVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
