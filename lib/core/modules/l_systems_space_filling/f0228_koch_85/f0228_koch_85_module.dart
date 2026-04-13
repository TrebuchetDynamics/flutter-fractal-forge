// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0228_koch_85_presets.dart';
import 'f0228_koch_85_variants.dart';
import 'f0228_koch_85_metadata.dart';

/// Koch 85° — L-Systems & Space-Filling.
class F0228Koch85 extends LSystemModule {
  F0228Koch85()
      : super(
          id: 'f0228_koch_85',
          shader: 'shaders/f0228_koch_85_gpu.frag',
        );

  @override
  F0228Koch85Metadata get metadata => F0228Koch85Metadata.instance;

  @override
  List<F0228Koch85Preset> get presets => F0228Koch85Presets.all;

  @override
  List<F0228Koch85Variant> get variants => F0228Koch85Variants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
