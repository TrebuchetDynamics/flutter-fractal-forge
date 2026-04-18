// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1005_maze_with_mice_b37_s12345_presets.dart';
import 'f1005_maze_with_mice_b37_s12345_variants.dart';
import 'f1005_maze_with_mice_b37_s12345_metadata.dart';

/// Maze with Mice (B37/S12345) — Cellular & Stochastic.
class F1005MazeWithMiceB37S12345 extends CellularModule {
  F1005MazeWithMiceB37S12345()
      : super(
          id: 'f1005_maze_with_mice_b37_s12345',
          shader: 'shaders/f1005_maze_with_mice_b37_s12345_gpu.frag',
        );

  @override
  F1005MazeWithMiceB37S12345Metadata get metadata => F1005MazeWithMiceB37S12345Metadata.instance;

  @override
  List<F1005MazeWithMiceB37S12345Preset> get presets => F1005MazeWithMiceB37S12345Presets.all;

  @override
  List<F1005MazeWithMiceB37S12345Variant> get variants => F1005MazeWithMiceB37S12345Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
