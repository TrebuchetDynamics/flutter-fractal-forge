// Base class for 3D raymarched fractals (Mandelbulb, IFS 3D, hypercomplex).
import 'package:meta/meta.dart';
import 'shader_params.dart';

@immutable
abstract class Raymarched3DModule {
  final String id;
  final String shader;

  const Raymarched3DModule({
    required this.id,
    required this.shader,
  });

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;

  double get defaultPower => 8.0;  // mandelbulb classic
  int get defaultSteps => 120;
  int get defaultIterations => 10;

  void configureShader(ShaderParams p);
}
