// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0774_rudin_shapiro_sequence_presets.dart';
import 'f0774_rudin_shapiro_sequence_variants.dart';
import 'f0774_rudin_shapiro_sequence_metadata.dart';

/// Rudin-Shapiro Sequence — Number-Theory Fractals.
class F0774RudinShapiroSequence extends CellularModule {
  F0774RudinShapiroSequence()
      : super(
          id: 'f0774_rudin_shapiro_sequence',
          shader: 'shaders/f0774_rudin_shapiro_sequence_gpu.frag',
        );

  @override
  F0774RudinShapiroSequenceMetadata get metadata => F0774RudinShapiroSequenceMetadata.instance;

  @override
  List<F0774RudinShapiroSequencePreset> get presets => F0774RudinShapiroSequencePresets.all;

  @override
  List<F0774RudinShapiroSequenceVariant> get variants => F0774RudinShapiroSequenceVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
