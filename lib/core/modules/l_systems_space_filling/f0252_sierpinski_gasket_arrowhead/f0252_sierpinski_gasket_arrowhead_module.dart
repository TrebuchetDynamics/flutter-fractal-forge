// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0252_sierpinski_gasket_arrowhead_presets.dart';
import 'f0252_sierpinski_gasket_arrowhead_variants.dart';
import 'f0252_sierpinski_gasket_arrowhead_metadata.dart';

/// Sierpinski Gasket Arrowhead — L-Systems & Space-Filling.
class F0252SierpinskiGasketArrowhead extends LSystemModule {
  F0252SierpinskiGasketArrowhead()
      : super(
          id: 'f0252_sierpinski_gasket_arrowhead',
          shader: 'shaders/f0252_sierpinski_gasket_arrowhead_gpu.frag',
        );

  @override
  F0252SierpinskiGasketArrowheadMetadata get metadata => F0252SierpinskiGasketArrowheadMetadata.instance;

  @override
  List<F0252SierpinskiGasketArrowheadPreset> get presets => F0252SierpinskiGasketArrowheadPresets.all;

  @override
  List<F0252SierpinskiGasketArrowheadVariant> get variants => F0252SierpinskiGasketArrowheadVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
