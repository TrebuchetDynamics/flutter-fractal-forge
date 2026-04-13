// Base class for L-System / space-filling fractals (Hilbert, Koch, dragon).
import 'package:meta/meta.dart';
import 'shader_params.dart';

@immutable
abstract class LSystemModule {
  final String id;
  final String shader;

  const LSystemModule({
    required this.id,
    required this.shader,
  });

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;

  int get defaultDepth => 6;

  void configureShader(ShaderParams p);
}
