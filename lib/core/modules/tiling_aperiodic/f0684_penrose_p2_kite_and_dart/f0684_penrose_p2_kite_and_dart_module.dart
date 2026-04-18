// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0684_penrose_p2_kite_and_dart_presets.dart';
import 'f0684_penrose_p2_kite_and_dart_variants.dart';
import 'f0684_penrose_p2_kite_and_dart_metadata.dart';

/// Penrose P2 Kite-and-Dart — Tiling & Aperiodic.
class F0684PenroseP2KiteAndDart extends IFSModule {
  F0684PenroseP2KiteAndDart()
      : super(
          id: 'f0684_penrose_p2_kite_and_dart',
          shader: 'shaders/f0684_penrose_p2_kite_and_dart_gpu.frag',
        );

  @override
  F0684PenroseP2KiteAndDartMetadata get metadata => F0684PenroseP2KiteAndDartMetadata.instance;

  @override
  List<F0684PenroseP2KiteAndDartPreset> get presets => F0684PenroseP2KiteAndDartPresets.all;

  @override
  List<F0684PenroseP2KiteAndDartVariant> get variants => F0684PenroseP2KiteAndDartVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
