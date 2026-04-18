// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1151_buddhabrot_d_10_presets.dart';
import 'f1151_buddhabrot_d_10_variants.dart';
import 'f1151_buddhabrot_d_10_metadata.dart';

/// Buddhabrot d=10 — Escape-Time (Complex Plane).
class F1151BuddhabrotD10 extends EscapeTimeModule {
  F1151BuddhabrotD10()
      : super(
          id: 'f1151_buddhabrot_d_10',
          shader: 'shaders/f1151_buddhabrot_d_10_gpu.frag',
        );

  @override
  F1151BuddhabrotD10Metadata get metadata => F1151BuddhabrotD10Metadata.instance;

  @override
  List<F1151BuddhabrotD10Preset> get presets => F1151BuddhabrotD10Presets.all;

  @override
  List<F1151BuddhabrotD10Variant> get variants => F1151BuddhabrotD10Variants.all;

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
