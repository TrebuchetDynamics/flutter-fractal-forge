// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0654_phoenix_d_2_p_0_56667195_presets.dart';
import 'f0654_phoenix_d_2_p_0_56667195_variants.dart';
import 'f0654_phoenix_d_2_p_0_56667195_metadata.dart';

/// Phoenix d=2 p=-0.56667195 — Escape-Time (Complex Plane).
class F0654PhoenixD2P056667195 extends EscapeTimeModule {
  F0654PhoenixD2P056667195()
      : super(
          id: 'f0654_phoenix_d_2_p_0_56667195',
          shader: 'shaders/f0654_phoenix_d_2_p_0_56667195_gpu.frag',
        );

  @override
  F0654PhoenixD2P056667195Metadata get metadata => F0654PhoenixD2P056667195Metadata.instance;

  @override
  List<F0654PhoenixD2P056667195Preset> get presets => F0654PhoenixD2P056667195Presets.all;

  @override
  List<F0654PhoenixD2P056667195Variant> get variants => F0654PhoenixD2P056667195Variants.all;

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
