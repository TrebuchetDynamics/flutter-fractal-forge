// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0338_clifford_tornado_presets.dart';
import 'f0338_clifford_tornado_variants.dart';
import 'f0338_clifford_tornado_metadata.dart';

/// Clifford Tornado — Strange Attractors.
class F0338CliffordTornado extends AttractorModule {
  F0338CliffordTornado()
      : super(
          id: 'f0338_clifford_tornado',
          shader: 'shaders/f0338_clifford_tornado_gpu.frag',
        );

  @override
  F0338CliffordTornadoMetadata get metadata => F0338CliffordTornadoMetadata.instance;

  @override
  List<F0338CliffordTornadoPreset> get presets => F0338CliffordTornadoPresets.all;

  @override
  List<F0338CliffordTornadoVariant> get variants => F0338CliffordTornadoVariants.all;

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
