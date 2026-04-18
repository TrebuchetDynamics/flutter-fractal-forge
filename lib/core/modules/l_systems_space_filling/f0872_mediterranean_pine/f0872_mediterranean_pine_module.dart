// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0872_mediterranean_pine_presets.dart';
import 'f0872_mediterranean_pine_variants.dart';
import 'f0872_mediterranean_pine_metadata.dart';

/// Mediterranean Pine — L-Systems & Space-Filling.
class F0872MediterraneanPine extends LSystemModule {
  F0872MediterraneanPine()
      : super(
          id: 'f0872_mediterranean_pine',
          shader: 'shaders/f0872_mediterranean_pine_gpu.frag',
        );

  @override
  F0872MediterraneanPineMetadata get metadata => F0872MediterraneanPineMetadata.instance;

  @override
  List<F0872MediterraneanPinePreset> get presets => F0872MediterraneanPinePresets.all;

  @override
  List<F0872MediterraneanPineVariant> get variants => F0872MediterraneanPineVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
