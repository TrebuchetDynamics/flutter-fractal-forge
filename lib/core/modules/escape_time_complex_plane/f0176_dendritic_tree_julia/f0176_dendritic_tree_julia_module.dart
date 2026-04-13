// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0176_dendritic_tree_julia_presets.dart';
import 'f0176_dendritic_tree_julia_variants.dart';
import 'f0176_dendritic_tree_julia_metadata.dart';

/// Dendritic Tree Julia — Escape-Time (Complex Plane).
class F0176DendriticTreeJulia extends EscapeTimeModule {
  F0176DendriticTreeJulia()
      : super(
          id: 'f0176_dendritic_tree_julia',
          shader: 'shaders/f0176_dendritic_tree_julia_gpu.frag',
        );

  @override
  F0176DendriticTreeJuliaMetadata get metadata => F0176DendriticTreeJuliaMetadata.instance;

  @override
  List<F0176DendriticTreeJuliaPreset> get presets => F0176DendriticTreeJuliaPresets.all;

  @override
  List<F0176DendriticTreeJuliaVariant> get variants => F0176DendriticTreeJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
