// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0630_lyapunov_bbbaaa_presets.dart';
import 'f0630_lyapunov_bbbaaa_variants.dart';
import 'f0630_lyapunov_bbbaaa_metadata.dart';

/// Lyapunov BBBAAA — Lyapunov & Stability.
class F0630LyapunovBbbaaa extends EscapeTimeModule {
  F0630LyapunovBbbaaa()
      : super(
          id: 'f0630_lyapunov_bbbaaa',
          shader: 'shaders/f0630_lyapunov_bbbaaa_gpu.frag',
        );

  @override
  F0630LyapunovBbbaaaMetadata get metadata => F0630LyapunovBbbaaaMetadata.instance;

  @override
  List<F0630LyapunovBbbaaaPreset> get presets => F0630LyapunovBbbaaaPresets.all;

  @override
  List<F0630LyapunovBbbaaaVariant> get variants => F0630LyapunovBbbaaaVariants.all;

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
