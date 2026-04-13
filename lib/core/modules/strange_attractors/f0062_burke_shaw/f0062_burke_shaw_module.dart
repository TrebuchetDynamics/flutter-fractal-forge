// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0062_burke_shaw_presets.dart';
import 'f0062_burke_shaw_variants.dart';
import 'f0062_burke_shaw_metadata.dart';

/// Burke-Shaw — Strange Attractors.
class F0062BurkeShaw extends AttractorModule {
  F0062BurkeShaw()
      : super(
          id: 'f0062_burke_shaw',
          shader: 'shaders/f0062_burke_shaw_gpu.frag',
        );

  @override
  F0062BurkeShawMetadata get metadata => F0062BurkeShawMetadata.instance;

  @override
  List<F0062BurkeShawPreset> get presets => F0062BurkeShawPresets.all;

  @override
  List<F0062BurkeShawVariant> get variants => F0062BurkeShawVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
