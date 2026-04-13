// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0227_koch_triangle_island_presets.dart';
import 'f0227_koch_triangle_island_variants.dart';
import 'f0227_koch_triangle_island_metadata.dart';

/// Koch Triangle Island — L-Systems & Space-Filling.
class F0227KochTriangleIsland extends LSystemModule {
  F0227KochTriangleIsland()
      : super(
          id: 'f0227_koch_triangle_island',
          shader: 'shaders/f0227_koch_triangle_island_gpu.frag',
        );

  @override
  F0227KochTriangleIslandMetadata get metadata => F0227KochTriangleIslandMetadata.instance;

  @override
  List<F0227KochTriangleIslandPreset> get presets => F0227KochTriangleIslandPresets.all;

  @override
  List<F0227KochTriangleIslandVariant> get variants => F0227KochTriangleIslandVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
