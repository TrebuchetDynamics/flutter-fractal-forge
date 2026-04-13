// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0410_gumowski_mira_shell_presets.dart';
import 'f0410_gumowski_mira_shell_variants.dart';
import 'f0410_gumowski_mira_shell_metadata.dart';

/// Gumowski-Mira Shell — Strange Attractors.
class F0410GumowskiMiraShell extends AttractorModule {
  F0410GumowskiMiraShell()
      : super(
          id: 'f0410_gumowski_mira_shell',
          shader: 'shaders/f0410_gumowski_mira_shell_gpu.frag',
        );

  @override
  F0410GumowskiMiraShellMetadata get metadata => F0410GumowskiMiraShellMetadata.instance;

  @override
  List<F0410GumowskiMiraShellPreset> get presets => F0410GumowskiMiraShellPresets.all;

  @override
  List<F0410GumowskiMiraShellVariant> get variants => F0410GumowskiMiraShellVariants.all;

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
