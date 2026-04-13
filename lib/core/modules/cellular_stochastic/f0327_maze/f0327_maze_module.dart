// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0327_maze_presets.dart';
import 'f0327_maze_variants.dart';
import 'f0327_maze_metadata.dart';

/// Maze — Cellular & Stochastic.
class F0327Maze extends CellularModule {
  F0327Maze()
      : super(
          id: 'f0327_maze',
          shader: 'shaders/f0327_maze_gpu.frag',
        );

  @override
  F0327MazeMetadata get metadata => F0327MazeMetadata.instance;

  @override
  List<F0327MazePreset> get presets => F0327MazePresets.all;

  @override
  List<F0327MazeVariant> get variants => F0327MazeVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
