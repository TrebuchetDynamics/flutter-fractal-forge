// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0251_pentadentrite_presets.dart';
import 'f0251_pentadentrite_variants.dart';
import 'f0251_pentadentrite_metadata.dart';

/// Pentadentrite — L-Systems & Space-Filling.
class F0251Pentadentrite extends LSystemModule {
  F0251Pentadentrite()
      : super(
          id: 'f0251_pentadentrite',
          shader: 'shaders/f0251_pentadentrite_gpu.frag',
        );

  @override
  F0251PentadentriteMetadata get metadata => F0251PentadentriteMetadata.instance;

  @override
  List<F0251PentadentritePreset> get presets => F0251PentadentritePresets.all;

  @override
  List<F0251PentadentriteVariant> get variants => F0251PentadentriteVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
