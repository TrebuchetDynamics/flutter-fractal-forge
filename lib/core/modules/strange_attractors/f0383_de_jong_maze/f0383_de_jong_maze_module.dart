// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0383_de_jong_maze_presets.dart';
import 'f0383_de_jong_maze_variants.dart';
import 'f0383_de_jong_maze_metadata.dart';

/// de Jong Maze — Strange Attractors.
class F0383DeJongMaze extends AttractorModule {
  F0383DeJongMaze()
      : super(
          id: 'f0383_de_jong_maze',
          shader: 'shaders/f0383_de_jong_maze_gpu.frag',
        );

  @override
  F0383DeJongMazeMetadata get metadata => F0383DeJongMazeMetadata.instance;

  @override
  List<F0383DeJongMazePreset> get presets => F0383DeJongMazePresets.all;

  @override
  List<F0383DeJongMazeVariant> get variants => F0383DeJongMazeVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
