// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0192_maze_julia_presets.dart';
import 'f0192_maze_julia_variants.dart';
import 'f0192_maze_julia_metadata.dart';

/// Maze Julia — Escape-Time (Complex Plane).
class F0192MazeJulia extends EscapeTimeModule {
  F0192MazeJulia()
      : super(
          id: 'f0192_maze_julia',
          shader: 'shaders/f0192_maze_julia_gpu.frag',
        );

  @override
  F0192MazeJuliaMetadata get metadata => F0192MazeJuliaMetadata.instance;

  @override
  List<F0192MazeJuliaPreset> get presets => F0192MazeJuliaPresets.all;

  @override
  List<F0192MazeJuliaVariant> get variants => F0192MazeJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
