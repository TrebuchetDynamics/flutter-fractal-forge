// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0624_lyapunov_abbbabbb_presets.dart';
import 'f0624_lyapunov_abbbabbb_variants.dart';
import 'f0624_lyapunov_abbbabbb_metadata.dart';

/// Lyapunov ABBBABBB — Lyapunov & Stability.
class F0624LyapunovAbbbabbb extends EscapeTimeModule {
  F0624LyapunovAbbbabbb()
      : super(
          id: 'f0624_lyapunov_abbbabbb',
          shader: 'shaders/f0624_lyapunov_abbbabbb_gpu.frag',
        );

  @override
  F0624LyapunovAbbbabbbMetadata get metadata => F0624LyapunovAbbbabbbMetadata.instance;

  @override
  List<F0624LyapunovAbbbabbbPreset> get presets => F0624LyapunovAbbbabbbPresets.all;

  @override
  List<F0624LyapunovAbbbabbbVariant> get variants => F0624LyapunovAbbbabbbVariants.all;

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
