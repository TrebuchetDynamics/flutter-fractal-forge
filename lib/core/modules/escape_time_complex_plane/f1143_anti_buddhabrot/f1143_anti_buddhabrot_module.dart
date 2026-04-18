// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1143_anti_buddhabrot_presets.dart';
import 'f1143_anti_buddhabrot_variants.dart';
import 'f1143_anti_buddhabrot_metadata.dart';

/// Anti-Buddhabrot — Escape-Time (Complex Plane).
class F1143AntiBuddhabrot extends EscapeTimeModule {
  F1143AntiBuddhabrot()
      : super(
          id: 'f1143_anti_buddhabrot',
          shader: 'shaders/f1143_anti_buddhabrot_gpu.frag',
        );

  @override
  F1143AntiBuddhabrotMetadata get metadata => F1143AntiBuddhabrotMetadata.instance;

  @override
  List<F1143AntiBuddhabrotPreset> get presets => F1143AntiBuddhabrotPresets.all;

  @override
  List<F1143AntiBuddhabrotVariant> get variants => F1143AntiBuddhabrotVariants.all;

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
