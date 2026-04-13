// Base class for Iterated Function Systems (Barnsley fern, Sierpinski, Cantor).
import 'package:meta/meta.dart';
import 'shader_params.dart';

@immutable
abstract class IFSModule {
  final String id;
  final String shader;

  const IFSModule({
    required this.id,
    required this.shader,
  });

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;

  int get defaultIterations => 50000;

  void configureShader(ShaderParams p);
}
