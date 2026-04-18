// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0811_sawtooth_map_alpha_1_5_presets.dart';
import 'f0811_sawtooth_map_alpha_1_5_variants.dart';
import 'f0811_sawtooth_map_alpha_1_5_metadata.dart';

/// Sawtooth Map (alpha=1.5) — Strange Attractors.
class F0811SawtoothMapAlpha15 extends AttractorModule {
  F0811SawtoothMapAlpha15()
      : super(
          id: 'f0811_sawtooth_map_alpha_1_5',
          shader: 'shaders/f0811_sawtooth_map_alpha_1_5_gpu.frag',
        );

  @override
  F0811SawtoothMapAlpha15Metadata get metadata => F0811SawtoothMapAlpha15Metadata.instance;

  @override
  List<F0811SawtoothMapAlpha15Preset> get presets => F0811SawtoothMapAlpha15Presets.all;

  @override
  List<F0811SawtoothMapAlpha15Variant> get variants => F0811SawtoothMapAlpha15Variants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
