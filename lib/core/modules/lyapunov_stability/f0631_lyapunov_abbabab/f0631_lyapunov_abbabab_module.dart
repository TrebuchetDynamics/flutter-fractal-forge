// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0631_lyapunov_abbabab_presets.dart';
import 'f0631_lyapunov_abbabab_variants.dart';
import 'f0631_lyapunov_abbabab_metadata.dart';

/// Lyapunov ABBABAB — Lyapunov & Stability.
class F0631LyapunovAbbabab extends EscapeTimeModule {
  F0631LyapunovAbbabab()
      : super(
          id: 'f0631_lyapunov_abbabab',
          shader: 'shaders/f0631_lyapunov_abbabab_gpu.frag',
        );

  @override
  F0631LyapunovAbbababMetadata get metadata => F0631LyapunovAbbababMetadata.instance;

  @override
  List<F0631LyapunovAbbababPreset> get presets => F0631LyapunovAbbababPresets.all;

  @override
  List<F0631LyapunovAbbababVariant> get variants => F0631LyapunovAbbababVariants.all;

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
