// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1148_buddhabrot_d_6_presets.dart';
import 'f1148_buddhabrot_d_6_variants.dart';
import 'f1148_buddhabrot_d_6_metadata.dart';

/// Buddhabrot d=6 — Escape-Time (Complex Plane).
class F1148BuddhabrotD6 extends EscapeTimeModule {
  F1148BuddhabrotD6()
      : super(
          id: 'f1148_buddhabrot_d_6',
          shader: 'shaders/f1148_buddhabrot_d_6_gpu.frag',
        );

  @override
  F1148BuddhabrotD6Metadata get metadata => F1148BuddhabrotD6Metadata.instance;

  @override
  List<F1148BuddhabrotD6Preset> get presets => F1148BuddhabrotD6Presets.all;

  @override
  List<F1148BuddhabrotD6Variant> get variants => F1148BuddhabrotD6Variants.all;

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
