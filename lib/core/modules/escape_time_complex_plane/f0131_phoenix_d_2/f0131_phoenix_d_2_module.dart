// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0131_phoenix_d_2_presets.dart';
import 'f0131_phoenix_d_2_variants.dart';
import 'f0131_phoenix_d_2_metadata.dart';

/// Phoenix d=2 — Escape-Time (Complex Plane).
class F0131PhoenixD2 extends EscapeTimeModule {
  F0131PhoenixD2()
      : super(
          id: 'f0131_phoenix_d_2',
          shader: 'shaders/f0131_phoenix_d_2_gpu.frag',
        );

  @override
  F0131PhoenixD2Metadata get metadata => F0131PhoenixD2Metadata.instance;

  @override
  List<F0131PhoenixD2Preset> get presets => F0131PhoenixD2Presets.all;

  @override
  List<F0131PhoenixD2Variant> get variants => F0131PhoenixD2Variants.all;

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
