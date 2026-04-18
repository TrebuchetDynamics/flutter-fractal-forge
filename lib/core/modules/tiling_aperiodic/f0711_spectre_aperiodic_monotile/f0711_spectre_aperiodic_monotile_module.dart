// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0711_spectre_aperiodic_monotile_presets.dart';
import 'f0711_spectre_aperiodic_monotile_variants.dart';
import 'f0711_spectre_aperiodic_monotile_metadata.dart';

/// Spectre Aperiodic Monotile — Tiling & Aperiodic.
class F0711SpectreAperiodicMonotile extends IFSModule {
  F0711SpectreAperiodicMonotile()
      : super(
          id: 'f0711_spectre_aperiodic_monotile',
          shader: 'shaders/f0711_spectre_aperiodic_monotile_gpu.frag',
        );

  @override
  F0711SpectreAperiodicMonotileMetadata get metadata => F0711SpectreAperiodicMonotileMetadata.instance;

  @override
  List<F0711SpectreAperiodicMonotilePreset> get presets => F0711SpectreAperiodicMonotilePresets.all;

  @override
  List<F0711SpectreAperiodicMonotileVariant> get variants => F0711SpectreAperiodicMonotileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
