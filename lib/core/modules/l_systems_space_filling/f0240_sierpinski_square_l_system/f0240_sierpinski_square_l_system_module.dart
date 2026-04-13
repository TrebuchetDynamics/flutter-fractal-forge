// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0240_sierpinski_square_l_system_presets.dart';
import 'f0240_sierpinski_square_l_system_variants.dart';
import 'f0240_sierpinski_square_l_system_metadata.dart';

/// Sierpinski Square L-system — L-Systems & Space-Filling.
class F0240SierpinskiSquareLSystem extends LSystemModule {
  F0240SierpinskiSquareLSystem()
      : super(
          id: 'f0240_sierpinski_square_l_system',
          shader: 'shaders/f0240_sierpinski_square_l_system_gpu.frag',
        );

  @override
  F0240SierpinskiSquareLSystemMetadata get metadata => F0240SierpinskiSquareLSystemMetadata.instance;

  @override
  List<F0240SierpinskiSquareLSystemPreset> get presets => F0240SierpinskiSquareLSystemPresets.all;

  @override
  List<F0240SierpinskiSquareLSystemVariant> get variants => F0240SierpinskiSquareLSystemVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
