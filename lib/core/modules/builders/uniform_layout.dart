import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';

/// Uniform slot contracts shared by fractal module builders.
///
/// Keep these indices aligned with the matching fragment shaders. Centralizing
/// them makes shader/builder drift visible during review instead of burying the
/// contract as repeated magic numbers in setUniforms closures.
abstract final class EscapeTimeUniformSlots {
  static const int time = 0;
  static const int resolutionX = 1;
  static const int resolutionY = 2;
  static const int centerX = 3;
  static const int centerY = 4;
  static const int zoom = 5;
  static const int iterations = 6;
  static const int bailout = 7;
  static const int colorScheme = 8;
  static const int transparentBackground = 9;
  static const int extraStart = 10;
}

abstract final class Raymarched3DUniformSlots {
  static const int time = 0;
  static const int resolutionX = 1;
  static const int resolutionY = 2;
  static const int panX = 3;
  static const int panY = 4;
  static const int zoom = 5;
  static const int rotationX = 6;
  static const int rotationY = 7;
  static const int rotationZ = 8;
  static const int power = 9;
  static const int iterations = 10;
  static const int steps = 11;
  static const int bailout = 12;
  static const int colorScheme = 13;
  static const int fractalType = 14;
  static const int transparentBackground = 15;
  static const int extraStart = 16;
}

/// Writes the shared frame and camera prefix used by ray-marched 3D shaders.
///
/// Keeping this mapping in one place prevents per-fractal setters from silently
/// drifting, especially for camera pan, which is stored in `uMousePos` slots.
void setRaymarched3DFrameUniforms({
  required void Function(int slot, double value) setFloat,
  required double time,
  required double width,
  required double height,
  required FractalViewState view,
}) {
  final pan = view.pan;
  final rotation = view.rotation;
  setFloat(Raymarched3DUniformSlots.time, time);
  setFloat(Raymarched3DUniformSlots.resolutionX, width);
  setFloat(Raymarched3DUniformSlots.resolutionY, height);
  setFloat(Raymarched3DUniformSlots.panX, pan.x);
  setFloat(Raymarched3DUniformSlots.panY, pan.y);
  setFloat(Raymarched3DUniformSlots.zoom, view.zoom);
  setFloat(Raymarched3DUniformSlots.rotationX, rotation.x);
  setFloat(Raymarched3DUniformSlots.rotationY, rotation.y);
  setFloat(Raymarched3DUniformSlots.rotationZ, rotation.z);
}

/// Writes the scalar parameter block shared by the standard ray-marched shaders.
void setRaymarched3DParameterUniforms({
  required void Function(int slot, double value) setFloat,
  required double power,
  required double iterations,
  required double steps,
  required double bailout,
  required double colorScheme,
  required double fractalType,
  required bool transparentBackground,
}) {
  setFloat(Raymarched3DUniformSlots.power, power);
  setFloat(Raymarched3DUniformSlots.iterations, iterations);
  setFloat(Raymarched3DUniformSlots.steps, steps);
  setFloat(Raymarched3DUniformSlots.bailout, bailout);
  setFloat(Raymarched3DUniformSlots.colorScheme, colorScheme);
  setFloat(Raymarched3DUniformSlots.fractalType, fractalType);
  setFloat(
    Raymarched3DUniformSlots.transparentBackground,
    transparentBackground ? 1.0 : 0.0,
  );
}

/// Writes module-specific numeric parameters after the shared 3D prefix.
void setRaymarched3DExtraParamUniforms({
  required void Function(int slot, double value) setFloat,
  required List<FractalParameter> parameters,
  required Map<String, Object> values,
}) {
  for (var index = 0; index < parameters.length; index++) {
    final parameter = parameters[index];
    final defaultValue = parameter.defaultValue as num;
    final value = readDouble(
      values,
      parameter.id,
      defaultValue.toDouble(),
    );
    setFloat(
      Raymarched3DUniformSlots.extraStart + index,
      value.clamp(parameter.min, parameter.max).toDouble(),
    );
  }
}

abstract final class MandelbrotDf2UniformSlots {
  static const int time = 0;
  static const int resolutionX = 1;
  static const int resolutionY = 2;
  static const int centerHiX = 3;
  static const int centerLoX = 4;
  static const int centerHiY = 5;
  static const int centerLoY = 6;
  static const int zoom = 7;
  static const int iterations = 8;
  static const int bailout = 9;
  static const int colorScheme = 10;
  static const int transparentBackground = 11;
}
