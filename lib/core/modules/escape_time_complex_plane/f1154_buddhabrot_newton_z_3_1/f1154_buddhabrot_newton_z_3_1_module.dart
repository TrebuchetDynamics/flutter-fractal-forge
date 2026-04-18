// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1154_buddhabrot_newton_z_3_1_presets.dart';
import 'f1154_buddhabrot_newton_z_3_1_variants.dart';
import 'f1154_buddhabrot_newton_z_3_1_metadata.dart';

/// Buddhabrot Newton z^3-1 — Escape-Time (Complex Plane).
class F1154BuddhabrotNewtonZ31 extends EscapeTimeModule {
  F1154BuddhabrotNewtonZ31()
      : super(
          id: 'f1154_buddhabrot_newton_z_3_1',
          shader: 'shaders/f1154_buddhabrot_newton_z_3_1_gpu.frag',
        );

  @override
  F1154BuddhabrotNewtonZ31Metadata get metadata => F1154BuddhabrotNewtonZ31Metadata.instance;

  @override
  List<F1154BuddhabrotNewtonZ31Preset> get presets => F1154BuddhabrotNewtonZ31Presets.all;

  @override
  List<F1154BuddhabrotNewtonZ31Variant> get variants => F1154BuddhabrotNewtonZ31Variants.all;

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
