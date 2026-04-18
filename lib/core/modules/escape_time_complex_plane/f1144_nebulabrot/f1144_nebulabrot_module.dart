// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1144_nebulabrot_presets.dart';
import 'f1144_nebulabrot_variants.dart';
import 'f1144_nebulabrot_metadata.dart';

/// Nebulabrot — Escape-Time (Complex Plane).
class F1144Nebulabrot extends EscapeTimeModule {
  F1144Nebulabrot()
      : super(
          id: 'f1144_nebulabrot',
          shader: 'shaders/f1144_nebulabrot_gpu.frag',
        );

  @override
  F1144NebulabrotMetadata get metadata => F1144NebulabrotMetadata.instance;

  @override
  List<F1144NebulabrotPreset> get presets => F1144NebulabrotPresets.all;

  @override
  List<F1144NebulabrotVariant> get variants => F1144NebulabrotVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
