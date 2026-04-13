// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0235_heptigree_presets.dart';
import 'f0235_heptigree_variants.dart';
import 'f0235_heptigree_metadata.dart';

/// Heptigree — L-Systems & Space-Filling.
class F0235Heptigree extends LSystemModule {
  F0235Heptigree()
      : super(
          id: 'f0235_heptigree',
          shader: 'shaders/f0235_heptigree_gpu.frag',
        );

  @override
  F0235HeptigreeMetadata get metadata => F0235HeptigreeMetadata.instance;

  @override
  List<F0235HeptigreePreset> get presets => F0235HeptigreePresets.all;

  @override
  List<F0235HeptigreeVariant> get variants => F0235HeptigreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
