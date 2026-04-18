// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1142_buddhabrot_presets.dart';
import 'f1142_buddhabrot_variants.dart';
import 'f1142_buddhabrot_metadata.dart';

/// Buddhabrot — Escape-Time (Complex Plane).
class F1142Buddhabrot extends EscapeTimeModule {
  F1142Buddhabrot()
      : super(
          id: 'f1142_buddhabrot',
          shader: 'shaders/f1142_buddhabrot_gpu.frag',
        );

  @override
  F1142BuddhabrotMetadata get metadata => F1142BuddhabrotMetadata.instance;

  @override
  List<F1142BuddhabrotPreset> get presets => F1142BuddhabrotPresets.all;

  @override
  List<F1142BuddhabrotVariant> get variants => F1142BuddhabrotVariants.all;

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
