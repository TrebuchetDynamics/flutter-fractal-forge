// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0723_ammann_rhombic_a1_presets.dart';
import 'f0723_ammann_rhombic_a1_variants.dart';
import 'f0723_ammann_rhombic_a1_metadata.dart';

/// Ammann Rhombic A1 — Tiling & Aperiodic.
class F0723AmmannRhombicA1 extends IFSModule {
  F0723AmmannRhombicA1()
      : super(
          id: 'f0723_ammann_rhombic_a1',
          shader: 'shaders/f0723_ammann_rhombic_a1_gpu.frag',
        );

  @override
  F0723AmmannRhombicA1Metadata get metadata => F0723AmmannRhombicA1Metadata.instance;

  @override
  List<F0723AmmannRhombicA1Preset> get presets => F0723AmmannRhombicA1Presets.all;

  @override
  List<F0723AmmannRhombicA1Variant> get variants => F0723AmmannRhombicA1Variants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
