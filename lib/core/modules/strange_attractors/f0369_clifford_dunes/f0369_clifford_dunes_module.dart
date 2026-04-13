// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0369_clifford_dunes_presets.dart';
import 'f0369_clifford_dunes_variants.dart';
import 'f0369_clifford_dunes_metadata.dart';

/// Clifford Dunes — Strange Attractors.
class F0369CliffordDunes extends AttractorModule {
  F0369CliffordDunes()
      : super(
          id: 'f0369_clifford_dunes',
          shader: 'shaders/f0369_clifford_dunes_gpu.frag',
        );

  @override
  F0369CliffordDunesMetadata get metadata => F0369CliffordDunesMetadata.instance;

  @override
  List<F0369CliffordDunesPreset> get presets => F0369CliffordDunesPresets.all;

  @override
  List<F0369CliffordDunesVariant> get variants => F0369CliffordDunesVariants.all;

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
