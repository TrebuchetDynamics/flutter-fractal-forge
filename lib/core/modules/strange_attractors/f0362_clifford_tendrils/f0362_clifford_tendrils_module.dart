// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0362_clifford_tendrils_presets.dart';
import 'f0362_clifford_tendrils_variants.dart';
import 'f0362_clifford_tendrils_metadata.dart';

/// Clifford Tendrils — Strange Attractors.
class F0362CliffordTendrils extends AttractorModule {
  F0362CliffordTendrils()
      : super(
          id: 'f0362_clifford_tendrils',
          shader: 'shaders/f0362_clifford_tendrils_gpu.frag',
        );

  @override
  F0362CliffordTendrilsMetadata get metadata => F0362CliffordTendrilsMetadata.instance;

  @override
  List<F0362CliffordTendrilsPreset> get presets => F0362CliffordTendrilsPresets.all;

  @override
  List<F0362CliffordTendrilsVariant> get variants => F0362CliffordTendrilsVariants.all;

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
