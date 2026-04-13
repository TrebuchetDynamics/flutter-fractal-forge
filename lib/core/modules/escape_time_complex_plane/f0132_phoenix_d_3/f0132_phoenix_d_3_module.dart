// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0132_phoenix_d_3_presets.dart';
import 'f0132_phoenix_d_3_variants.dart';
import 'f0132_phoenix_d_3_metadata.dart';

/// Phoenix d=3 — Escape-Time (Complex Plane).
class F0132PhoenixD3 extends EscapeTimeModule {
  F0132PhoenixD3()
      : super(
          id: 'f0132_phoenix_d_3',
          shader: 'shaders/f0132_phoenix_d_3_gpu.frag',
        );

  @override
  F0132PhoenixD3Metadata get metadata => F0132PhoenixD3Metadata.instance;

  @override
  List<F0132PhoenixD3Preset> get presets => F0132PhoenixD3Presets.all;

  @override
  List<F0132PhoenixD3Variant> get variants => F0132PhoenixD3Variants.all;

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
