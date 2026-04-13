// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0079_genesio_tesi_presets.dart';
import 'f0079_genesio_tesi_variants.dart';
import 'f0079_genesio_tesi_metadata.dart';

/// Genesio-Tesi — Strange Attractors.
class F0079GenesioTesi extends AttractorModule {
  F0079GenesioTesi()
      : super(
          id: 'f0079_genesio_tesi',
          shader: 'shaders/f0079_genesio_tesi_gpu.frag',
        );

  @override
  F0079GenesioTesiMetadata get metadata => F0079GenesioTesiMetadata.instance;

  @override
  List<F0079GenesioTesiPreset> get presets => F0079GenesioTesiPresets.all;

  @override
  List<F0079GenesioTesiVariant> get variants => F0079GenesioTesiVariants.all;

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
