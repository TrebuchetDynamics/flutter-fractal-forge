// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0617_lyapunov_abbb_presets.dart';
import 'f0617_lyapunov_abbb_variants.dart';
import 'f0617_lyapunov_abbb_metadata.dart';

/// Lyapunov ABBB — Lyapunov & Stability.
class F0617LyapunovAbbb extends EscapeTimeModule {
  F0617LyapunovAbbb()
      : super(
          id: 'f0617_lyapunov_abbb',
          shader: 'shaders/f0617_lyapunov_abbb_gpu.frag',
        );

  @override
  F0617LyapunovAbbbMetadata get metadata => F0617LyapunovAbbbMetadata.instance;

  @override
  List<F0617LyapunovAbbbPreset> get presets => F0617LyapunovAbbbPresets.all;

  @override
  List<F0617LyapunovAbbbVariant> get variants => F0617LyapunovAbbbVariants.all;

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
