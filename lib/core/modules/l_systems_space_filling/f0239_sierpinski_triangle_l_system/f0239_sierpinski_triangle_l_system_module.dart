// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0239_sierpinski_triangle_l_system_presets.dart';
import 'f0239_sierpinski_triangle_l_system_variants.dart';
import 'f0239_sierpinski_triangle_l_system_metadata.dart';

/// Sierpinski Triangle L-system — L-Systems & Space-Filling.
class F0239SierpinskiTriangleLSystem extends LSystemModule {
  F0239SierpinskiTriangleLSystem()
      : super(
          id: 'f0239_sierpinski_triangle_l_system',
          shader: 'shaders/f0239_sierpinski_triangle_l_system_gpu.frag',
        );

  @override
  F0239SierpinskiTriangleLSystemMetadata get metadata => F0239SierpinskiTriangleLSystemMetadata.instance;

  @override
  List<F0239SierpinskiTriangleLSystemPreset> get presets => F0239SierpinskiTriangleLSystemPresets.all;

  @override
  List<F0239SierpinskiTriangleLSystemVariant> get variants => F0239SierpinskiTriangleLSystemVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
