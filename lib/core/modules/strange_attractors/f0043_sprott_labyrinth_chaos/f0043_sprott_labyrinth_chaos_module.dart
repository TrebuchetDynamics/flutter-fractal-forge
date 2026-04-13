// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0043_sprott_labyrinth_chaos_presets.dart';
import 'f0043_sprott_labyrinth_chaos_variants.dart';
import 'f0043_sprott_labyrinth_chaos_metadata.dart';

/// Sprott Labyrinth Chaos — Strange Attractors.
class F0043SprottLabyrinthChaos extends AttractorModule {
  F0043SprottLabyrinthChaos()
      : super(
          id: 'f0043_sprott_labyrinth_chaos',
          shader: 'shaders/f0043_sprott_labyrinth_chaos_gpu.frag',
        );

  @override
  F0043SprottLabyrinthChaosMetadata get metadata => F0043SprottLabyrinthChaosMetadata.instance;

  @override
  List<F0043SprottLabyrinthChaosPreset> get presets => F0043SprottLabyrinthChaosPresets.all;

  @override
  List<F0043SprottLabyrinthChaosVariant> get variants => F0043SprottLabyrinthChaosVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
