// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0343_clifford_shell_presets.dart';
import 'f0343_clifford_shell_variants.dart';
import 'f0343_clifford_shell_metadata.dart';

/// Clifford Shell — Strange Attractors.
class F0343CliffordShell extends AttractorModule {
  F0343CliffordShell()
      : super(
          id: 'f0343_clifford_shell',
          shader: 'shaders/f0343_clifford_shell_gpu.frag',
        );

  @override
  F0343CliffordShellMetadata get metadata => F0343CliffordShellMetadata.instance;

  @override
  List<F0343CliffordShellPreset> get presets => F0343CliffordShellPresets.all;

  @override
  List<F0343CliffordShellVariant> get variants => F0343CliffordShellVariants.all;

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
