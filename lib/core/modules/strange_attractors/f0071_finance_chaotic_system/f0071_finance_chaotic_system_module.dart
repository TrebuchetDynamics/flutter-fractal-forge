// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0071_finance_chaotic_system_presets.dart';
import 'f0071_finance_chaotic_system_variants.dart';
import 'f0071_finance_chaotic_system_metadata.dart';

/// Finance Chaotic System — Strange Attractors.
class F0071FinanceChaoticSystem extends AttractorModule {
  F0071FinanceChaoticSystem()
      : super(
          id: 'f0071_finance_chaotic_system',
          shader: 'shaders/f0071_finance_chaotic_system_gpu.frag',
        );

  @override
  F0071FinanceChaoticSystemMetadata get metadata => F0071FinanceChaoticSystemMetadata.instance;

  @override
  List<F0071FinanceChaoticSystemPreset> get presets => F0071FinanceChaoticSystemPresets.all;

  @override
  List<F0071FinanceChaoticSystemVariant> get variants => F0071FinanceChaoticSystemVariants.all;

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
