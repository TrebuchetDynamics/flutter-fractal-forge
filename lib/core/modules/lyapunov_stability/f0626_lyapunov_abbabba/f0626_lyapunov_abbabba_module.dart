// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0626_lyapunov_abbabba_presets.dart';
import 'f0626_lyapunov_abbabba_variants.dart';
import 'f0626_lyapunov_abbabba_metadata.dart';

/// Lyapunov ABBABBA — Lyapunov & Stability.
class F0626LyapunovAbbabba extends EscapeTimeModule {
  F0626LyapunovAbbabba()
      : super(
          id: 'f0626_lyapunov_abbabba',
          shader: 'shaders/f0626_lyapunov_abbabba_gpu.frag',
        );

  @override
  F0626LyapunovAbbabbaMetadata get metadata => F0626LyapunovAbbabbaMetadata.instance;

  @override
  List<F0626LyapunovAbbabbaPreset> get presets => F0626LyapunovAbbabbaPresets.all;

  @override
  List<F0626LyapunovAbbabbaVariant> get variants => F0626LyapunovAbbabbaVariants.all;

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
