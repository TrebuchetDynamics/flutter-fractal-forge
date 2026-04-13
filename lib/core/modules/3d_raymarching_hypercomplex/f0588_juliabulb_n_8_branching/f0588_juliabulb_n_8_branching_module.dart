// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0588_juliabulb_n_8_branching_presets.dart';
import 'f0588_juliabulb_n_8_branching_variants.dart';
import 'f0588_juliabulb_n_8_branching_metadata.dart';

/// Juliabulb n=8 (branching) — 3D Raymarching & Hypercomplex.
class F0588JuliabulbN8Branching extends Raymarched3DModule {
  F0588JuliabulbN8Branching()
      : super(
          id: 'f0588_juliabulb_n_8_branching',
          shader: 'shaders/f0588_juliabulb_n_8_branching_gpu.frag',
        );

  @override
  F0588JuliabulbN8BranchingMetadata get metadata => F0588JuliabulbN8BranchingMetadata.instance;

  @override
  List<F0588JuliabulbN8BranchingPreset> get presets => F0588JuliabulbN8BranchingPresets.all;

  @override
  List<F0588JuliabulbN8BranchingVariant> get variants => F0588JuliabulbN8BranchingVariants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
