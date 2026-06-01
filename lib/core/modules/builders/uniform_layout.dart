/// Uniform slot contracts shared by declarative module builders.
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
  static const int mouseX = 3;
  static const int mouseY = 4;
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
}
