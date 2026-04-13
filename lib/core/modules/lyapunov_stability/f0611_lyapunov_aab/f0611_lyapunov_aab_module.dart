// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0611_lyapunov_aab_presets.dart';
import 'f0611_lyapunov_aab_variants.dart';
import 'f0611_lyapunov_aab_metadata.dart';

/// Lyapunov AAB — Lyapunov & Stability.
class F0611LyapunovAab extends EscapeTimeModule {
  F0611LyapunovAab()
      : super(
          id: 'f0611_lyapunov_aab',
          shader: 'shaders/f0611_lyapunov_aab_gpu.frag',
        );

  @override
  F0611LyapunovAabMetadata get metadata => F0611LyapunovAabMetadata.instance;

  @override
  List<F0611LyapunovAabPreset> get presets => F0611LyapunovAabPresets.all;

  @override
  List<F0611LyapunovAabVariant> get variants => F0611LyapunovAabVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 300;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
