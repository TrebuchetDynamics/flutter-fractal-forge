// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0348_clifford_crystal_presets.dart';
import 'f0348_clifford_crystal_variants.dart';
import 'f0348_clifford_crystal_metadata.dart';

/// Clifford Crystal — Strange Attractors.
class F0348CliffordCrystal extends AttractorModule {
  F0348CliffordCrystal()
      : super(
          id: 'f0348_clifford_crystal',
          shader: 'shaders/f0348_clifford_crystal_gpu.frag',
        );

  @override
  F0348CliffordCrystalMetadata get metadata => F0348CliffordCrystalMetadata.instance;

  @override
  List<F0348CliffordCrystalPreset> get presets => F0348CliffordCrystalPresets.all;

  @override
  List<F0348CliffordCrystalVariant> get variants => F0348CliffordCrystalVariants.all;

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
